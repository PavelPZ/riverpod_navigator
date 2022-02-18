part of 'index.dart';

// wait for https://github.com/flutter/flutter/pull/97394 error fix

// ********************************************
//   Defer2NextTick
// ********************************************

/// helper class that solves two problems:
///
/// 1. two providers (on which navigation depends) change in one tick
/// eg. if after a successful login:
///
///   - change the login state to true
///   - change the ongoingPath state to a screen requiring a login
///
/// in this case, without the Defer2NextTick class, [navigationStackProvider] is changed twice
///
/// 2. state on which navigation depends changed during [RNavigatorCore.computeNavigation].
///
/// then [NavigationComputingException] is raised and [navigationStackProvider] and [ongoingPathProvider]
/// are not synchronized
class Defer2NextTick {
  Defer2NextTick();

  late RNavigatorCore navigator;

  void providerChanged() {
    // synchronize navigation stack and ongoingPath
    if (ignoreNextProviderChange) return;
    scheduleMicrotask(() {
      _needRefresh = true;
      if (!_running) _refreshStack();
    });
  }

  void registerProtectedFuture(Future future) {
    protectedFutures.add(future);
    future.whenComplete(() => protectedFutures.remove(future));
  }

  final protectedFutures = <Future>[];

  // *********************** private

  var _needRefresh = false;
  var _running = false;
  var ignoreNextProviderChange = false;

  // exist till _refreshStack is working
  Completer? _resultCompleter;
  // (last _resultCompleter).future. Needed because _resultCompleter is set to null at the end of navigation roundtrip
  Future? _resultFuture;

  Future<void> get future => _resultFuture ?? Future.value();

  Future _refreshStack() async {
    try {
      try {
        _running = true;
        _resultCompleter = Completer();
        _resultFuture = _resultCompleter!.future;
        while (_needRefresh) {
          _needRefresh = false;
          final navigationStackNotifier = navigator.ref.read(navigationStackProvider.notifier);
          final ongoingPathNotifier = navigator.ref.read(ongoingPathProvider.notifier);
          if (protectedFutures.isNotEmpty) await Future.wait(protectedFutures);
          assert(protectedFutures.isEmpty);
          final futureOr = navigator.appNavigationLogicCore(navigationStackNotifier.state, ongoingPathNotifier.state);
          final newPath = futureOr is Future<TypedPath?> ? await futureOr : futureOr;
          // during async appNavigationLogicCore state change come (in providerChanged)
          // run another cycle (appNavigationLogicCore for fresh input navigation state)
          if (_needRefresh) continue;
          // appNavigationLogicCore recognize no change to navig stack
          if (newPath == null) continue;
          // synchronize navigation stack and ongoingPath
          ignoreNextProviderChange = true;
          try {
            ongoingPathNotifier.state = navigationStackNotifier.state = newPath;
          } finally {
            ignoreNextProviderChange = false;
          }
          // remember last navigation stack for restorePath
          navigator._restorePath?.saveLastKnownStack(newPath);
        }
        _resultCompleter!.complete(null);
      } catch (e, s) {
        // or sync exception or appNavigationLogicCore future error
        _resultCompleter!.completeError(e, s);
      }
    } finally {
      _running = false;
      _resultCompleter = null;
    }
  }
}
