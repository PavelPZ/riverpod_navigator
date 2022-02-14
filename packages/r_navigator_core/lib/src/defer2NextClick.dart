part of 'index.dart';

class NavigationComputingException {}

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
  // called once in the next tick
  late RNavigatorCore navigator;

  Completer? _completer;
  bool runnerActive = false;

  /// called in every state change
  void start() {
    if (_completer != null) {
      // state changed during navigator.computeNavigation computing
      if (runnerActive) {
        _completer!.completeError(NavigationComputingException());
        start();
      }
      return;
    }
    _completer = Completer();
    scheduleMicrotask(() async {
      runnerActive = true;
      try {
        try {
          final ongoingNotifier = navigator.ref.read(ongoingPathProvider.notifier);
          final ongoingPath = await navigator.appNavigationLogicCore(ongoingNotifier.state);

          await navigator.computeNavigation();
          _completer!.complete();
        } on NavigationComputingException {
          // state changed during navigator.computeNavigation computing
          _completer = null;
          runnerActive = false;
        } catch (e, s) {
          _completer!.completeError(e, s);
        }
      } finally {
        runnerActive = false;
        _completer = null;
      }
    });
  }

  Future<void> get future => _completer != null ? _completer!.future : Future.value();
}
