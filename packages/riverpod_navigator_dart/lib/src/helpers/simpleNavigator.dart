import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../model.dart';
import '../pathParser.dart';
import '../route.dart';

/// one of the strategy how to react to state change
abstract class SimpleNavigator extends RiverpodNavigator {
  SimpleNavigator(Ref ref, GetRoute4Segment getRouteForSegment, PathParser pathParser) : super(ref, getRouteForSegment, pathParser);

  /// state change is doing ONLY here
  @override
  Future<void> navigate(TypedPath newTypedPath) async {
    final actPath = getActualTypedPath();
    onAsyncChange?.call(true);
    try {
      // app logic
      newTypedPath = appNavigationLogic(actPath, newTypedPath);

      // normalize newTypedPath
      newTypedPath = _eq2Identical(actPath, newTypedPath);
      if (identical(getActualTypedPath, newTypedPath)) return;

      // call async route action: Route4Model.creating, Route4Model.deactivating, Route4Model.merging
      await waitForRouteChanging(actPath, newTypedPath);
      // unawaited(Future.delayed(Duration(milliseconds: 300)).then((_) => onAsyncChangeEnd()));

      // state change => flutter navigation
      setActualTypedPath(newTypedPath);
      onAsyncChange?.call(false);
    } catch (e) {
      // show error (no state changed)
      onAsyncChange?.call(false, e);
      rethrow;
    }
  }

  /// start- and end-navigation callback (with possible error at the end)
  void Function(bool inStart, [Object? error])? onAsyncChange;

  Future<void> refresh() => navigate([...getActualTypedPath()]); // navigate to self

  /// all async route operations ([Route4Model.creating], [Route4Model.deactivating], [Route4Model.merging]) run in parallel
  /// other scenario is possible
  @protected
  Future<void> waitForRouteChanging(TypedPath oldSegment, TypedPath newSegment) async {
    final minLen = min(oldSegment.length, newSegment.length);
    final futures = <Future?>[];
    // get routes from segments
    final olds = oldSegment.map((s) => getRouteWithSegment(s)).toList();
    final news = newSegment.map((s) => getRouteWithSegment(s)).toList();
    // merge old and new
    for (var i = 0; i < minLen; i++) {
      final o = olds[i];
      final n = news[i];
      // nothing to merge
      if (identical(o.segment, n.segment)) continue;
      if (o.route == n.route)
        // old and new has the same route => merging
        futures.add(o.route.merging(o.segment, n.segment));
      else {
        // old and new has different route => deactivanting old, creating new
        futures.add(o.route.deactivating(o.segment));
        futures.add(n.route.creating(n.segment));
      }
    }
    // deactivating the rest of old routes
    if (olds.length > minLen) for (var i = minLen; i < olds.length; i++) futures.add(olds[i].route.deactivating(olds[i].segment));
    // creating the rest of new routes
    if (news.length > minLen) for (var i = minLen; i < news.length; i++) futures.add(news[i].route.creating(news[i].segment));
    // remove empty futures
    final notEmptyFutures = <Future>[
      for (final f in futures)
        if (f != null) f
    ];
    // wait
    if (notEmptyFutures.isNotEmpty) await Future.wait(notEmptyFutures);
  }

  /// put all change-route application logic here (guards, redirect, ...)
  @protected
  TypedPath appNavigationLogic(TypedPath oldPath, TypedPath newPath);

  /// replaces "eq" routes with "identical" ones
  TypedPath _eq2Identical(TypedPath oldSegment, TypedPath newSegment) {
    final newStateCopy = [...newSegment];
    var stateEqual = oldSegment.length == newStateCopy.length;
    for (var i = 0; i < min(oldSegment.length, newStateCopy.length); i++) {
      if (oldSegment[i] == newStateCopy[i])
        newStateCopy[i] = oldSegment[i]; // "eq"  => "identical"
      else
        stateEqual = false; // same of the state[i] is not equal
    }
    return stateEqual ? oldSegment : newStateCopy;
  }
}
