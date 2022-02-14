part of 'index.dart';

// ********************************************
//   RiverpodNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RNavigatorCore {
  RNavigatorCore(
    this.ref, {
    List<AlwaysAliveProviderListenable>? dependsOn,
    this.restorePath,
  }) {
    ref.onDispose(() => restorePath?.onPathChanged(ref.read(navigationStackProvider)));

    // _runNavigation only once on the next tick
    _defer2NextTick = Defer2NextTick()..navigator = this;

    this.dependsOn.add(ongoingPathProvider);
    if (dependsOn != null) this.dependsOn.addAll(dependsOn);
    assert(this.dependsOn.every((p) => p is Override));

    // 1. Listen to the riverpod providers. If any change, call _defer2NextTick.start().
    // 2. _defer2NextTick ensures that _runNavigation is called only once the next tick
    // 3. Add RemoveListener's to unlistens
    // 4. Use unlistens in ref.onDispose
    final unlistens = this.dependsOn.map((depend) => ref.listen<dynamic>(depend, (previous, next) => _defer2NextTick!.providerChanged())).toList();

    // ignore: avoid_function_literals_in_foreach_calls
    ref.onDispose(() => unlistens.forEach((f) => f()));

    // load init path
    _defer2NextTick!.providerChanged();
  }

  /// When changing navigation state: completed after Flutter navigation stack is actual
  Future<void> get navigationCompleted => _defer2NextTick!.future;

  final List<AlwaysAliveProviderListenable> dependsOn = [];

  final RestorePath? restorePath;

  @protected
  Ref ref;
  Defer2NextTick? _defer2NextTick;

  /// Main [RNavigatorCore] method. Provides navigation to the new [TypedPath].
  Future<void> navigate(TypedPath newPath) async {
    ref.read(ongoingPathProvider.notifier).state = newPath;
    return navigationCompleted;
  }

  /// Enter application navigation logic here (redirection, login, etc.).
  /// No need to override (eg when the navigation status depends only on the ongoingPathProvider and no redirects or route guard is needed)
  FutureOr<TypedPath> appNavigationLogicCore(TypedPath ongoingPath, bool isCanceled()) => ongoingPath;

  static List<Override> initProviders(TypedPath initPath, RNavigatorCore navigator(Ref ref)) => [
        ongoingPathProvider.overrideWithValue(StateController<TypedPath>(initPath)),
        riverpodNavigatorProvider.overrideWithProvider(Provider(navigator)),
      ];

  // /// synchronize [ongoingPathProvider] with [navigationStackProvider]
  // Future<void> computeNavigation() async {
  //   final ongoingNotifier = ref.read(ongoingPathProvider.notifier);
  //   final ongoingPath = await appNavigationLogicCore(ongoingNotifier.state);

  //   // checking _defer2NextTick!.runnerActive is not required
  //   _defer2NextTick!.runnerActive = false;

  //   // actualize navigationStackProvider and ongoingPathProvider
  //   ongoingNotifier.state = ref.read(navigationStackProvider.notifier).state = ongoingNotifier.state = ongoingPath;
  // }

  // @nonVirtual
  // Future<void> pop() =>
  //     navigationStack.length <= 1 ? Future.value() : navigate([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i]]);

  // @nonVirtual
  // Future<void> push(TypedSegment segment) => navigate([...navigationStack, segment]);

  // @nonVirtual
  // Future<void> replaceLast(TypedSegment segment) => navigate([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i], segment]);
}
