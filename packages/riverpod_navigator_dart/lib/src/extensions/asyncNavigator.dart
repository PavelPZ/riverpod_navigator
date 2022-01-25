import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../model.dart';
import '../route.dart';

/// one of the strategies for responding to an asynchronous TypeedPath change
abstract class AsyncRiverpodNavigator extends RiverpodNavigator {
  AsyncRiverpodNavigator(Ref ref, GetRoute4Segment getRouteForSegment) : super(ref, getRouteForSegment);

  /// put all change-route application logic here
  /// (redirect to other page during login x logoff, other guards, redirect, ...)
  @protected
  TypedPath appNavigationLogic(TypedPath oldPath, TypedPath newPath);

  /// start- and end-navigation callback (with possible error at the end)
  void Function(bool inStart, [Object? error])? onAsyncChange;

  /// navigate to newPath
  @override
  Future<void> navigate(TypedPath newPath) async {
    final actPath = getActualTypedPath();
    onAsyncChange?.call(true);
    try {
      // app logic (e.g. redirect to other page when user is not logged)
      newPath = appNavigationLogic(actPath, newPath);

      // normalize newPath
      newPath = _eq2Identical(actPath, newPath);
      if (identical(getActualTypedPath, newPath)) return;

      // wait for async actions: creating, deactivating, merging
      await waitForRouteChanging(actPath, newPath);

      // state change => flutter navigation
      setActualTypedPath(newPath);

      onAsyncChange?.call(false);
    } catch (e) {
      // show error (no state changed)
      onAsyncChange?.call(false, e);
      rethrow;
    }
  }

  /// navigate to the same [TypedPath]
  ///
  /// call this helper method after some global app states change
  /// (e.g. login x logoff)
  /// [appNavigationLogic] can than respond to them
  Future<void> refresh() => navigate([...getActualTypedPath()]);

  /* ******************************************** */
  /*   @protected                                 */
  /* ******************************************** */

  /// all async route operations ([Route4Model.creating], [Route4Model.deactivating], [Route4Model.merging]) run in parallel
  /// other scenario is possible
  @protected
  Future<void> waitForRouteChanging(TypedPath oldPath, TypedPath newPath) async {
    final minLen = min(oldPath.length, newPath.length);
    final futures = <Future?>[];
    // get routes from segments
    final olds = oldPath.map((s) => getRouteWithSegment(s)).toList();
    final news = newPath.map((s) => getRouteWithSegment(s)).toList();
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

  /// replaces "eq" routes with "identical" ones
  TypedPath _eq2Identical(TypedPath oldPath, TypedPath newPath) {
    final newPathCopy = [...newPath];
    var pathsEqual = oldPath.length == newPathCopy.length;
    for (var i = 0; i < min(oldPath.length, newPathCopy.length); i++) {
      if (oldPath[i] == newPathCopy[i])
        newPathCopy[i] = oldPath[i]; // "eq"  => "identical"
      else
        pathsEqual = false; // same of the state[i] is not equal
    }
    return pathsEqual ? oldPath : newPathCopy;
  }
}
