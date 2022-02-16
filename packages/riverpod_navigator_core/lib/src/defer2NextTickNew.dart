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
class Defer2NextTickNew {
  Defer2NextTickNew();

  late RNavigatorCore navigator;

  void providerChanged() {
    scheduleMicrotask(() {
      _needRefresh = true;
      if (!_running) _refreshStack();
    });
  }

  // *********************** private

  var _needRefresh = false;
  var _running = false;

  // exist till _refreshStack is working
  Completer? _resultCompleter;
  // (last _resultCompleter).future. Needed because _resultCompleter is set to null at the end of navigation roundtrip
  Future? _resultFuture;

  Future<void> get future => _resultFuture ?? Future.value();

  Future _refreshStack() async {
    _resultCompleter = Completer();
    _resultFuture = _resultCompleter!.future;
    _running = true;
    try {
      while (_needRefresh) {
        _needRefresh = false;
        final futureOr = navigator.appNavigationLogicCore(navigator.ref.read(ongoingPathProvider));
        final newPath = futureOr is Future<TypedPath?> ? await futureOr : futureOr;
        // appNavigationLogicCore recognize no change to navig stack
        if (newPath == null) continue;
        // change navigation stack
        navigator.ref.read(navigationStackProvider.notifier).state = newPath;
        // remember last navigation stack for restorePath
        navigator._restorePath?.saveLastKnownStack(newPath);
      }
      _resultCompleter!.complete(null);
    } finally {
      _running = false;
      _resultCompleter = null;
      _resultFuture = null;
    }
  }
}
