part of 'riverpod_navigator_core.dart';

// wait for https://github.com/flutter/flutter/pull/97394 error fix

// ********************************************
//   Defer2NextTick
// ********************************************

/// helper class that solves two problems:
///
/// 1. two providers (on which navigation depends) change in one tick
/// eg. if after a successful login:
///   - change the login state to true
///   - change the intendedPath state to a screen requiring a login
///
/// in this case, without the Defer2NextTick class, [navigationStackProvider] is changed twice
///
/// 2. state on which navigation depends changed during [RNavigatorCore.appNavigationLogicCore].
///
/// then [navigationStackProvider] and [intendedPathProvider] are not synchronized
class Defer2NextTick {
  Defer2NextTick();

  late RNavigatorCore navigator;

  /// called when changed some of providers on which navigation stack depends
  void providerChanged() {
    // jist synchronizing navigation stack and intendedPath
    if (_intendedPathChanging) return;
    assert(_p('providerChanged start'));
    // the following is UNDO-ed in _refreshStack-finally block
    if (_resultCompleter == null) {
      navigator.setIsNavigating(true); // notify navigator (e.g. show waiting cursor)
      _resultCompleter = Completer(); // alow waiting for async navigation completed
      _resultFuture = _resultCompleter!.future; // _resultCompleter can be changed
    }
    // this flag blocks calling _refreshStack's while-cycle more than once
    _refreshStackWhileCalled = true;
    // this flag blocks calling scheduleMicrotask(_refreshStack) more than once
    // UNDO-ed in _refreshStack-finally block
    if (_refreshStackCalled) return;
    _refreshStackCalled = true;
    scheduleMicrotask(_refreshStack);
  }

  /// async navigation completed
  Future<void> get asyncNavigationCompleted => _resultFuture ?? Future.value();

  /// refister future which must be completed before the next navigation starts
  void registerProtectedFuture(Future future) {
    _protectedFutures.add(future);
    future.whenComplete(() => _protectedFutures.remove(future));
  }

  // *********************** private

  /// during _refreshStack running, another providerChanged() called
  var _refreshStackWhileCalled = false;

  /// _refreshStack is running
  var _refreshStackCalled = false;

  /// for intendedPathNotifier.state syncing: ignore providerChanged call
  var _intendedPathChanging = false;

  /// exist till [_refreshStack] is working
  Completer? _resultCompleter;

  /// registered futures, which must be completed before next navigation starts
  final _protectedFutures = <Future>[];

  /// last [_resultCompleter].future.
  /// Needed because [_resultCompleter] is set to null at the end of navigation roundtrip
  Future? _resultFuture;

  Future _refreshStack() async {
    try {
      try {
        while (_refreshStackWhileCalled) {
          _refreshStackWhileCalled = false;
          final navigationStackNotifier = navigator.ref.read(navigationStackProvider.notifier);
          final intendedPathNotifier = navigator.ref.read(intendedPathProvider.notifier);
          assert(_p('appLogic start'));
          if (_protectedFutures.isNotEmpty) {
            await Future.wait(_protectedFutures);
          }
          assert(_p('_protectedFutures'));
          assert(_protectedFutures.isEmpty);
          final futureOr = navigator.appNavigationLogicCore(navigationStackNotifier.state, intendedPathNotifier.state);
          final newPath = futureOr is Future<TypedPath?> ? await futureOr : futureOr;
          // during async appNavigationLogicCore state another providerChanged called
          // do not finish _refreshStack but run its while cycle again
          if (_refreshStackWhileCalled) {
            assert(_p('_providerChangedCalled'));
            continue;
          }
          // synchronize navigation stack and intendedPath with appNavigationLogic result
          _intendedPathChanging = true;
          try {
            intendedPathNotifier.state = navigationStackNotifier.state = newPath;
            assert(_p('synchronized: $newPath'));
          } finally {
            _intendedPathChanging = false;
          }
          // remember last navigation stack for restorePath
          navigator._restorePath?.saveLastKnownStack(newPath);
        }
        // completed
        _resultCompleter!.complete(null);
      } catch (e, s) {
        // or sync exception or appNavigationLogicCore future error
        _resultCompleter!.completeError(e, s);
      }
    } finally {
      _refreshStackCalled = false;
      _resultCompleter = null;
      navigator.setIsNavigating(false);
    }
  }
}
