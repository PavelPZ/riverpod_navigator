import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tuple/tuple.dart';

import '../riverpod_navigator_dart.dart';
import 'route.dart';

/// one of the strategies for responding to an asynchronous TypeedPath change
abstract class AsyncRiverpodNavigator extends RiverpodNavigator {
  AsyncRiverpodNavigator(Ref ref) : super(ref);

  /// start- and end-navigation callback (with possible error at the end)
  void Function(bool inStart, [Object? error])? onAsyncChange;

  /// put all change-route application logic here
  @override
  TypedPath appNavigationLogic(TypedPath oldPath, TypedPath newPath) {
    onAsyncChange?.call(true);
    try {
      // normalize newPath
      newPath = eq2Identical(oldPath, newPath);
      if (identical(getActualTypedPath, newPath)) return newPath;

      // wait for async actions: creating, deactivating, merging
      // await waitForRouteChanging(oldPath, newPath);

      // state change => flutter navigation
      final routerDelegate = ref.read(routerDelegateProvider);
      routerDelegate.currentConfiguration = newPath;
      routerDelegate.notifyListeners();

      onAsyncChange?.call(false);
      return newPath;
    } catch (e) {
      // show error (no state changed)
      onAsyncChange?.call(false, e);
      rethrow;
    }
  }

  /// navigate to newPath
  // @override
  // Future<TypedPath> navigate(TypedPath newPath) async {
  //   final actPath = getActualTypedPath();
  //   onAsyncChange?.call(true);
  //   try {
  //     // app logic (e.g. redirect to other page when user is not logged)
  //     newPath = appNavigationLogic(actPath, newPath);

  //     // normalize newPath
  //     newPath = _eq2Identical(actPath, newPath);
  //     if (identical(getActualTypedPath, newPath)) return newPath;

  //     // wait for async actions: creating, deactivating, merging
  //     await waitForRouteChanging(actPath, newPath);

  //     // state change => flutter navigation
  //     setActualTypedPath(newPath);

  //     onAsyncChange?.call(false);
  //     return newPath;
  //   } catch (e) {
  //     // show error (no state changed)
  //     onAsyncChange?.call(false, e);
  //     rethrow;
  //   }
  // }

  /// navigate to the same [TypedPath]
  ///
  /// call this helper method after some global app states change
  /// (e.g. login x logoff)
  /// [appNavigationLogic] can than respond to them
//  Future<void> refresh() => navigate([...getActualTypedPath()]);

  /* ******************************************** */
  /*   @protected                                 */
  /* ******************************************** */

  /// all async route operations ([Route4Dart.creating], [Route4Dart.deactivating], [Route4Dart.merging]) run in parallel
  /// other scenario is possible
  @protected
  Future<void> waitForRouteChanging(TypedPath oldPath, TypedPath newPath) async {
    final minLen = min(oldPath.length, newPath.length);
    final futures = <Tuple2<Future?, TypedSegment>>[];
    // merge old and new
    for (var i = 0; i < minLen; i++) {
      final o = oldPath[i];
      final n = newPath[i];
      // nothing to merge
      if (identical(o, n)) continue;
      final oAsyncs = config.segment2AsyncScreenActions!(o);
      final nAsyncs = config.segment2AsyncScreenActions!(n);
      if (o.runtimeType == n.runtimeType)
        // old and new has the same route => merging
        futures.add(Tuple2(nAsyncs?.callMerging(o, n), n));
      else {
        // old and new has different route => deactivanting old, creating new
        futures.add(Tuple2(oAsyncs?.callDeactivating(o), o));
        futures.add(Tuple2(nAsyncs?.callCreating(n), n));
      }
    }
    // deactivating the rest of old routes
    if (oldPath.length > minLen)
      for (var i = minLen; i < oldPath.length; i++)
        futures.add(Tuple2(config.segment2AsyncScreenActions!(oldPath[i])?.callDeactivating(oldPath[i]), oldPath[i]));
    // creating the rest of new routes
    if (newPath.length > minLen)
      for (var i = minLen; i < newPath.length; i++)
        futures.add(Tuple2(config.segment2AsyncScreenActions!(newPath[i])?.callCreating(newPath[i]), newPath[i]));
    // remove empty futures
    final notEmptyFutures = <Tuple2<Future?, TypedSegment>>[
      for (final f in futures)
        if (f.item1 != null) f
    ];
    // wait
    if (notEmptyFutures.isEmpty) return;

    // if (config.splashPath != null && oldPath.isEmpty) setActualTypedPath(config.splashPath as TypedPath);

    final asyncResults = await Future.wait(notEmptyFutures.map((fs) => fs.item1 as Future));
    assert(asyncResults.length == notEmptyFutures.length);

    for (var i = 0; i < asyncResults.length; i++) notEmptyFutures[i].item2.asyncActionResult = asyncResults[i];

    return;
  }
}
