part of 'riverpod_navigator_core.dart';

// ********************************************
//   RNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RNavigatorCore {
  RNavigatorCore(
    this.ref,
    List<RRoute4Dart> routes,
  ) : router = RRouter(routes) {
    pathParser = PathParser(router);

    // see Defer2NextTick doc
    _defer2NextTick = Defer2NextTick()..navigator = this;

    ref.onDispose(() {
      // ignore: avoid_function_literals_in_foreach_calls
      _unlistens.forEach((f) => f());
    });

    // start navigation
    _defer2NextTick.providerChanged();
  }

  /// Enter application navigation logic here (redirection, login, etc.).
  /// No need to override (eg when the navigation status depends only on the ongoingPathProvider and no redirects or route guards are needed)
  TypedPath appNavigationLogic(TypedPath ongoingPath) => ongoingPath;

  /// Enter application navigation logic here (redirection, login, etc.).
  /// No need to override (eg when the navigation status depends only on the ongoingPathProvider and no redirects or route guard is needed)
  FutureOr<TypedPath?> appNavigationLogicCore(
      TypedPath oldNavigationStack, TypedPath ongoingPath) {
    var newOngoingPath = appNavigationLogic(ongoingPath);

    // in ongoingPath, when ongoingPath[i] == currentTypedPath[i], set ongoingPath[i] = currentTypedPath[i]
    final navigationStack = getNavigationStack();
    newOngoingPath = eq2Identical(navigationStack, newOngoingPath);
    if (newOngoingPath == navigationStack) return null;

    final todo = waitStart(router, navigationStack, newOngoingPath);
    if (todo.isEmpty) return newOngoingPath;
    return waitEnd(todo).then((_) => newOngoingPath);
  }

  void registerProtectedFuture(Future future) =>
      _defer2NextTick.registerProtectedFuture(future);

  late TypedPath initPath;
  final RRouter router;

  late PathParser pathParser;

  /// Main [RNavigator] method. Provides navigation to newPath.
  Future<void> navigate(TypedPath newPath) async {
    ref.read(ongoingPathProvider.notifier).state = newPath;
    return navigationCompleted;
  }

  /// When changing navigation state: completed after navigationStackProvider is actual
  Future<void> get navigationCompleted => _defer2NextTick.future;

  TypedPath segmentSubpath(TypedSegment s) {
    final navigationStack = getNavigationStack();

    final res = <TypedSegment>[];
    for (var i = 0; i < navigationStack.length; i++) {
      res.add(navigationStack[i]);
      if (navigationStack[i] == s) break;
    }
    return res;
  }

  String get navigationStack2Url => pathParser.toUrl(getNavigationStack());
  String debugSegmentSubpath(TypedSegment s) =>
      pathParser.toUrl(segmentSubpath(s));

  /// Wait for the asynchronous screen actions. The action is waiting in parallel
  ///- rewrite, when other waiting strategy is needed.
  static List<Tuple2<AsyncOper, TypedSegment>> waitStart(
      RRouter router, TypedPath oldPath, TypedPath newPath) {
    final todo = <Tuple2<AsyncOper, TypedSegment>>[];
    void add(AsyncOper? oper, TypedSegment segment) {
      if (oper == null) return;
      todo.add(Tuple2(oper, segment));
    }

    // close olds
    for (var i = oldPath.length - 1; i >= 0; i--) {
      final o = oldPath[i];
      final n = i >= newPath.length ? null : newPath[i];
      if (n == null || o.runtimeType != n.runtimeType) {
        add(router.segment2Route(o).callClosing(o), o);
      } else if (identical(o, n)) {
        continue;
      }
    }
    // open or replace new
    for (var i = 0; i < newPath.length; i++) {
      final n = newPath[i];
      final o = i >= oldPath.length ? null : oldPath[i];
      if (o == null || o.runtimeType != n.runtimeType) {
        add(router.segment2Route(n).callOpening(n), n);
      } else if (identical(o, n)) {
        continue;
      } else {
        // not identical and the same runtimeType
        add(router.segment2Route(n).callReplacing(o, n), n);
      }
    }
    return todo;
  }

  Future waitEnd(List<Tuple2<AsyncOper, TypedSegment>> todo) async {
    for (final fs in todo) {
      final asyncRes = await fs.item1();
      if (fs.item2.asyncHolder == null) throw 'fs.item2.asyncHolder == null';
      fs.item2.asyncHolder!.value = asyncRes;
    }
  }

  TypedPath getNavigationStack() => ref.read(navigationStackProvider);

  void _setdependsOn(List<AlwaysAliveProviderListenable> value) {
    _dependsOn = [
      ...value,
      if (!value.contains(ongoingPathProvider)) ongoingPathProvider
    ];
    assert(_dependsOn.every((p) => p is Override));

    // 1. Listen to the riverpod providers. If any change, call _defer2NextTick.start().
    // 2. [providerChanged] ensures that _runNavigation is called only once the next tick
    // 3. Add RemoveListener's to unlistens
    // 4. Use unlistens in ref.onDispose
    _unlistens = _dependsOn
        .map((depend) => ref.listen<dynamic>(
            depend, (previous, next) => _defer2NextTick.providerChanged()))
        .toList();
  }

  late List<AlwaysAliveProviderListenable> _dependsOn;
  late List<Function> _unlistens;

  /// for nested navigator: keep state of nested navigator in flutter tabs widget
  late RestorePath? _restorePath;

  @protected
  final Ref ref;
  late Defer2NextTick _defer2NextTick;

  /// replaces "eq" segments with "identical" ones
  TypedPath eq2Identical(TypedPath oldPath, TypedPath newPath) {
    var pathsEqual = oldPath.length == newPath.length;
    for (var i = 0; i < min(oldPath.length, newPath.length); i++) {
      if (router.segmentEq(oldPath[i], newPath[i])) {
        newPath[i] = oldPath[i]; // "eq"  => "identical"
      } else {
        pathsEqual = false; // same of the segment is not equal
      }
    }
    return pathsEqual ? oldPath : newPath;
  }

  // *** common navigation-agnostic app actions ***

  Future<void> pop() {
    final navigationStack = getNavigationStack();
    return navigationStack.length <= 1
        ? Future.value()
        : navigate([
            for (var i = 0; i < navigationStack.length - 1; i++)
              navigationStack[i]
          ]);
  }

  Future<void> push(TypedSegment segment) =>
      navigate([...getNavigationStack(), segment]);

  Future<void> replaceLast<T extends TypedSegment>(T replace(T old)) {
    final navigationStack = getNavigationStack();
    return navigate([
      for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i],
      replace(navigationStack.last as T)
    ]);
  }

  static List<Override> providerOverrides(
    TypedPath initPath,
    RNavigatorCore navigator(Ref ref), {
    RestorePath? restorePath,
    List<AlwaysAliveProviderListenable> dependsOn = const [],
  }) =>
      [
        ...dependsOn.map((e) => e as Override),
        ongoingPathProvider.overrideWithValue(StateController<TypedPath>(
            restorePath == null
                ? initPath
                : restorePath.getInitialPath(initPath))),
        navigationStackProvider,
        navigatorProvider.overrideWithProvider(Provider((ref) => navigator(ref)
          .._restorePath = restorePath
          ..initPath = initPath
          .._setdependsOn(dependsOn))),
      ];
}
