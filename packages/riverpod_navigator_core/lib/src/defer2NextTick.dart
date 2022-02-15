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

  // cancelable appNavigationLogicCore return value
  CancelableCompleter<TypedPath>? _appLogicCompleter;
  CToken? _cToken;
  // exist till scheduleMicrotask finish without cancel (exists for one navigation roundtrip)
  Completer? _resultCompleter;
  // (last _resultCompleter).future. Needed because _resultCompleter is set to null at the end of navigation roundtrip
  Future? _resultFuture;
  // only single enter to scheduleMicrotask
  bool waitForMicrotaskEnter = false;

  bool ignoreNextStateChange = false;

  /// called in every state change
  void providerChanged() {
    if (ignoreNextStateChange) return;
    // state changed during navigator.appNavigationLogicCore computing => cancel its CancelableCompleter
    if (_appLogicCompleter != null) {
      assert(_cToken != null);
      _cToken!.isCanceled = true;
      _appLogicCompleter!.operation.cancel();

      _appLogicCompleter = null;
      _cToken = null;
    }
    if (waitForMicrotaskEnter) return;

    _resultCompleter ??= Completer();
    _resultFuture = _resultCompleter!.future;

    waitForMicrotaskEnter = true;
    scheduleMicrotask(() async {
      waitForMicrotaskEnter = false;

      final ongoingNotifier = navigator.ref.read(ongoingPathProvider.notifier);
      TypedPath? newPath;
      try {
        final futureOr = navigator.appNavigationLogicCore(ongoingNotifier.state, cToken: _cToken = CToken());

        if (futureOr is Future<TypedPath?>) {
          final compl = _appLogicCompleter = CancelableCompleter<TypedPath>();
          // futureOr to CancelableCompleter
          unawaited(futureOr.then((value) => compl.complete(value), onError: compl.completeError));
          // wait for value, error and CANCEL (futureOr cannot wait for cancel)
          final res = await compl.operation.valueOrCancellation(canceledPath);
          if (res == canceledPath) {
            // canceled => no navigationStack change
            _cToken = null;
            _appLogicCompleter = null;
            return;
          }
          newPath = res;
        } else
          newPath = futureOr;

        _resultCompleter!.complete(newPath);

        // res==null for path does not change
        if (newPath == null) {
          _cToken = null;
          _appLogicCompleter = null;
          // one navigation roundtrip finished => set null
          _resultCompleter = null;
          return;
        }

        // synchronize ongoingPath with navigationStack
        ignoreNextStateChange = true;
        try {
          ongoingNotifier.state = navigator.ref.read(navigationStackProvider.notifier).state = newPath!;
        } finally {
          ignoreNextStateChange = false;
        }
      } catch (e, s) {
        // or sync exception or appNavigationLogicCore future error
        _resultCompleter!.completeError(e, s);
      }
      _cToken = null;
      _appLogicCompleter = null;
      // one navigation roundtrip finished => set null
      _resultCompleter = null;
    });
  }

  Future<void> get future => _resultFuture ?? Future.value();
}

class CanceledSegment with TypedSegment {}

final TypedPath canceledPath = [CanceledSegment()];
