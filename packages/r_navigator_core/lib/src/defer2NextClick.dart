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

  CancelableCompleter<TypedPath>? _completer;
  Completer? _futureCompleter;
  bool runnerActive = false;

  /// called in every state change
  void providerChanged() {
    if (_completer != null) {
      // state changed during navigator.appNavigationLogicCore computing
      if (runnerActive) _completer!.operation.cancel();
      return;
    }
    _completer = CancelableCompleter();
    _futureCompleter = Completer();
    scheduleMicrotask(() {
      runnerActive = true;
      final ongoingNotifier = navigator.ref.read(ongoingPathProvider.notifier);
      try {
        final futureOr = navigator.appNavigationLogicCore(ongoingNotifier.state, _completer!);
        if (futureOr is Future)
          futureOr.then((value) => _completer!.complete(value)).onError(_futureCompleter!.completeError);
        else
          _completer!.complete(futureOr);
      } catch (e, s) {
        if (!_completer!.isCanceled) _completer!.completeError(e, s);
      }
      _completer!.operation.then(
        (finalPath) {
          ongoingNotifier.state = navigator.ref.read(navigationStackProvider.notifier).state = finalPath;
          _futureCompleter!.complete();
          _futureCompleter = null;
          runnerActive = false;
          _completer = null;
        },
        onError: (e, s) {
          runnerActive = false;
          _completer = null;
          _futureCompleter!.completeError(e, s);
          _futureCompleter = null;
        },
        onCancel: () {
          runnerActive = false;
          _completer = null;
          // rerun appNavigationLogicCore for fresh (last) input providers
          providerChanged();
        },
      );
    });
  }

  Future<void> get future => _futureCompleter != null ? _futureCompleter!.future.whenComplete(() => null) : Future.value();
}
