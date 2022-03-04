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
///   - change the ongoingPath state to a screen requiring a login
///
/// in this case, without the Defer2NextTick class, [navigationStackProvider] is changed twice
///
/// 2. state on which navigation depends changed during [RNavigatorCore.appNavigationLogicCore].
///
/// then [navigationStackProvider] and [ongoingPathProvider] are not synchronized
class Defer2NextTick {
  Defer2NextTick();

  late RNavigatorCore navigator;

  void registerProtectedFuture(Future future) {
    _protectedFutures.add(future);
    future.whenComplete(() => _protectedFutures.remove(future));
  }

  final _protectedFutures = <Future>[];

  void providerChanged() {
    // synchronize navigation stack and ongoingPath
    if (ignoreNextProviderChange) return;
    assert(_p('providerChanged start'));
    if (_resultCompleter == null) {
      navigator.blockGui(true);
      _resultCompleter = Completer();
      _resultFuture = _resultCompleter!.future;
    }
    _providerChangedCalled = true;
    if (_isRunning) return;
    _isRunning = true;
    scheduleMicrotask(_refreshStack);
  }

  // *********************** private

  /// during _refreshStack running, another providerChanged() called
  var _providerChangedCalled = false;

  /// _refreshStack is running
  var _isRunning = false;

  /// for ongoingPathNotifier.state syncing: ignore providerChanged call
  var ignoreNextProviderChange = false;

  /// exist till [_refreshStack] is working
  Completer? _resultCompleter;

  /// (last [_resultCompleter]).future.
  /// Needed because [_resultCompleter] is set to null at the end of navigation roundtrip
  Future? _resultFuture;

  Future<void> get future => _resultFuture ?? Future.value();

  Future _refreshStack() async {
    try {
      try {
        while (_providerChangedCalled) {
          _providerChangedCalled = false;
          final navigationStackNotifier = navigator.ref.read(navigationStackProvider.notifier);
          final ongoingPathNotifier = navigator.ref.read(ongoingPathProvider.notifier);
          assert(_p('appLogic start'));
          if (_protectedFutures.isNotEmpty) {
            await Future.wait(_protectedFutures);
          }
          assert(_p('_protectedFutures'));
          assert(_protectedFutures.isEmpty);
          final futureOr = navigator.appNavigationLogicCore(navigationStackNotifier.state, ongoingPathNotifier.state);
          final newPath = futureOr is Future<TypedPath?> ? await futureOr : futureOr;
          // during async appNavigationLogicCore state another providerChanged called
          // do not finish _refreshStack but run its while cycle again
          if (_providerChangedCalled) {
            assert(_p('_providerChangedCalled'));
            continue;
          }
          // synchronize stack and ongoingPath
          ignoreNextProviderChange = true;
          try {
            ongoingPathNotifier.state = navigationStackNotifier.state = newPath;
            assert(_p('synchronized: $newPath'));
          } finally {
            ignoreNextProviderChange = false;
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
      _isRunning = false;
      _resultCompleter = null;
      navigator.blockGui(false);
    }
  }
}
