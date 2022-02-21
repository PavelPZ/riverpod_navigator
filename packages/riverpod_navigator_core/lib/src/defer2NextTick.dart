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
    assert(_p('providerChanged start'));
    _resultCompleter ??= Completer();
    _resultFuture = _resultCompleter!.future;
    _ignoreNext = true;
    if (_isRunning) return;
    _isRunning = true;
    scheduleMicrotask(() {
      _refreshStack();
      // if (!_running) {
      //   assert(_p('providerChanged _refreshStack'));
      //   _refreshStack();
      // } else
      //   assert(_p('providerChanged _running'));
    });
  }

  void registerProtectedFuture(Future future) {
    protectedFutures.add(future);
    future.whenComplete(() => protectedFutures.remove(future));
  }

  final protectedFutures = <Future>[];

  // *********************** private

  // during _refreshStack running, another providerChanged() raises
  var _ignoreNext = false;

  // _refreshStack is running
  var _isRunning = false;

  var ignoreNextProviderChange = false;

  // exist till _refreshStack is working
  Completer? _resultCompleter;
  // (last _resultCompleter).future. Needed because _resultCompleter is set to null at the end of navigation roundtrip
  Future? _resultFuture;

  Future<void> get future => _resultFuture ?? Future.value();

  Future _refreshStack() async {
    try {
      try {
        while (_ignoreNext) {
          _ignoreNext = false;
          final navigationStackNotifier = navigator.ref.read(navigationStackProvider.notifier);
          final ongoingPathNotifier = navigator.ref.read(ongoingPathProvider.notifier);
          if (protectedFutures.isNotEmpty) await Future.wait(protectedFutures);
          assert(protectedFutures.isEmpty);
          assert(_p('appLogic start'));
          final futureOr = navigator.appNavigationLogicCore(navigationStackNotifier.state, ongoingPathNotifier.state);
          final newPath = futureOr is Future<TypedPath?> ? await futureOr : futureOr;
          // during async appNavigationLogicCore state change come (in providerChanged)
          // run another cycle (appNavigationLogicCore for fresh input navigation state)
          if (_ignoreNext) {
            assert(_p('_needRefresh'));
            continue;
          }
          // appNavigationLogicCore recognize no change to navig stack
          if (newPath == null) {
            assert(_p('newPath == null'));
            continue;
          }
          // synchronize navigation stack and ongoingPath
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
        _resultCompleter!.complete(null);
      } catch (e, s) {
        // or sync exception or appNavigationLogicCore future error
        _resultCompleter!.completeError(e, s);
      }
    } finally {
      _isRunning = false;
      _resultCompleter = null;
    }
  }
}

bool _p(String title) {
  if (!_ignorePrint) print(title);
  return true;
}

var _ignorePrint = true;
