part of 'index.dart';

// ********************************************
//   RNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RNavigatorCore {
  RNavigatorCore(this.ref) {
    // see Defer2NextTick doc
    // _defer2NextTick = Defer2NextTick()..navigator = this;
    _defer2NextTick = Defer2NextTickNew()..navigator = this;

    ref.onDispose(() {
      // ignore: avoid_function_literals_in_foreach_calls
      _unlistens.forEach((f) => f());
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

  late TypedPath initPath;

  void set dependsOn(List<AlwaysAliveProviderListenable> value) {
    _dependsOn = [...value, if (!_dependsOn.contains(ongoingPathProvider)) ongoingPathProvider];
    assert(_dependsOn.every((p) => p is Override));

    // 1. Listen to the riverpod providers. If any change, call _defer2NextTick.start().
    // 2. _defer2NextTick ensures that _runNavigation is called only once the next tick
    // 3. Add RemoveListener's to unlistens
    // 4. Use unlistens in ref.onDispose
    _unlistens = _dependsOn.map((depend) => ref.listen<dynamic>(depend, (previous, next) => _defer2NextTick!.providerChanged())).toList();
  }

  List<AlwaysAliveProviderListenable> _dependsOn = [];
  List<Function> _unlistens = [];

  /// for nested navigator: keep state of nested navigator in flutter tabs widget
  RestorePath? _restorePath;

  static bool kIsWeb = false;

  @protected
  Ref ref;
  Defer2NextTickNew? _defer2NextTick;

  static List<Override> providerOverrides(
    TypedPath initPath,
    RNavigatorCore navigator(Ref ref), {
    RestorePath? restorePath,
    List<AlwaysAliveProviderListenable> dependsOn = const [],
  }) =>
      [
        ...dependsOn.map((e) => e as Override),
        ongoingPathProvider.overrideWithValue(StateController<TypedPath>(restorePath == null ? initPath : restorePath.getInitialPath(initPath))),
        navigationStackProvider,
        riverpodNavigatorProvider.overrideWithProvider(Provider((ref) => navigator(ref)
          .._restorePath = restorePath
          ..initPath = initPath
          ..dependsOn = dependsOn)),
      ];
}
