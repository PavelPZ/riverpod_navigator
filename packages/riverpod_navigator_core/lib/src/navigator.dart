part of 'index.dart';

// ********************************************
//   RNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RNavigatorCore {
  RNavigatorCore(
    this.ref, {
    List<AlwaysAliveProviderListenable>? dependsOn,
    this.restorePath,
  }) {
    // see Defer2NextTick doc
    _defer2NextTick = Defer2NextTick()..navigator = this;

    if (!this.dependsOn.contains(ongoingPathProvider)) this.dependsOn.add(ongoingPathProvider);
    if (dependsOn != null) this.dependsOn.addAll(dependsOn);
    assert(this.dependsOn.every((p) => p is Override));

    // 1. Listen to the riverpod providers. If any change, call _defer2NextTick.start().
    // 2. _defer2NextTick ensures that _runNavigation is called only once the next tick
    // 3. Add RemoveListener's to unlistens
    // 4. Use unlistens in ref.onDispose
    final unlistens = this.dependsOn.map((depend) => ref.listen<dynamic>(depend, (previous, next) => _defer2NextTick!.providerChanged())).toList();

    ref.onDispose(() {
      // remember last state for restorePath
      restorePath?.saveLastKnownStack(ref.read(navigationStackProvider));
      // ignore: avoid_function_literals_in_foreach_calls
      unlistens.forEach((f) => f());
      //ref.onDispose(() => unlistens.forEach((f) => f()));
    });

    // load init path
    _defer2NextTick!.providerChanged();
  }

  /// Enter application navigation logic here (redirection, login, etc.).
  /// No need to override (eg when the navigation status depends only on the ongoingPathProvider and no redirects or route guard is needed)
  FutureOr<TypedPath?> appNavigationLogicCore(TypedPath ongoingPath, {CToken? cToken}) => ongoingPath;

  /// When changing navigation state: completed after Flutter navigation stack is actual
  Future<void> get navigationCompleted => _defer2NextTick!.future;

  TypedPath getNavigationStack() => ref.read(navigationStackProvider);
  TypedPath getOngoingPath() => ref.read(ongoingPathProvider);

  final List<AlwaysAliveProviderListenable> dependsOn = [];

  /// for nested navigator: e.g. keep state of nested navigator in flutter tabs widget
  final RestorePath? restorePath;

  @protected
  Ref ref;
  Defer2NextTick? _defer2NextTick;

  static List<Override> providerOverrides(TypedPath initPath, RNavigatorCore navigator(Ref ref), {RestorePath? restorePath}) => [
        ongoingPathProvider.overrideWithValue(StateController<TypedPath>(restorePath == null ? initPath : restorePath.getInitialPath(initPath))),
        riverpodNavigatorProvider.overrideWithProvider(Provider(navigator)),
      ];
}
