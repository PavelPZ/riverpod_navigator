part of 'riverpod_navigator_core.dart';

// ********************************************
//   RNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RNavigatorCore {
  RNavigatorCore(
    this.ref,
    List<RRouteCore> routes, {
    IPathParser pathParserCreator(RRouter router)?,
  }) : router = RRouter(routes) {
    pathParser = pathParserCreator == null ? PathParser(router) : pathParserCreator(router);

    // see Defer2NextTick doc
    _defer2NextTick = Defer2NextTick()..navigator = this;

    ref.onDispose(() {
      // ignore: avoid_function_literals_in_foreach_calls
      _unlistens.forEach((f) => f());
    });

    // start navigation
    _defer2NextTick.providerChanged();
  }

  /// home path
  late TypedPath initPath;

  /// router
  final RRouter router;

  /// path parser
  late IPathParser pathParser;

  /// for nested navigator: keep state of nested navigator eg. in flutter tabs widget
  late RestorePath? _restorePath;

  final Ref ref;

  late List<AlwaysAliveProviderListenable> _dependsOn;
  late List<Function> _unlistens;
  late Defer2NextTick _defer2NextTick;

  /// Enter application navigation logic here (redirection, login, etc.).
  /// No need to override, eg. when the navigation status depends only on the ongoingPathProvider
  /// and no redirects or route guards are needed.
  /// Returns ongoingPath or other redirection path.
  TypedPath appNavigationLogic(TypedPath ongoingPath) => ongoingPath;

  /// low level app logic
  FutureOr<TypedPath> appNavigationLogicCore(TypedPath oldNavigationStack, TypedPath ongoingPath) {
    final newOngoingPath = appNavigationLogic(ongoingPath);

    final navigationStack = getNavigationStack();
    // when navigationStack[i] == newOngoingPath[i], set newOngoingPath[i] = navigationStack[i]
    eq2Identical(navigationStack, newOngoingPath);

    final todo = waitStart(router, navigationStack, newOngoingPath);
    // no async actions:
    if (todo.item1.isEmpty && todo.item2.isEmpty) return newOngoingPath;
    // wait for async actions:
    return waitEnd(todo).then((_) => newOngoingPath);
  }

  /// Navigation is delayed until [future] is completed.
  /// This allows the global state to be synchronized
  /// (for example, when [future] is storing data that can be used by another screen).
  Future registerProtectedFuture(Future future) {
    _defer2NextTick.registerProtectedFuture(future);
    return future;
  }

  /// Main [RNavigator] method. Provides navigation to the newPath.
  /// Used in e.g RLinkbutton
  NavigatePath navigatePath(TypedPath newPath) => NavigatePath(() {
        ref.read(ongoingPathProvider.notifier).state = newPath;
        return navigationCompleted;
      }, screenTitle(newPath.last));

  /// Main [RNavigator] method. Provides navigation to the newPath.
  Future navigate(TypedPath newPath) => navigatePath(newPath).onPressed();

  /// wrap your async actions:
  /// ```
  /// setIsNavigating(true);
  /// try {
  ///   // async action
  /// } finally {
  ///   setIsNavigating(false);
  /// }
  /// ```
  void setIsNavigating(bool isNavigating) =>
      ref.read(isNavigatingProvider.notifier).update((state) => isNavigating ? state + 1 : state - 1);

  /// When changing navigation state: completed after [navigationStackProvider] is actual
  Future<void> get navigationCompleted => _defer2NextTick.future;

  String screenTitle(TypedSegment segment) => router.segment2Route(segment).getScreenTitle(segment);

  String get navigationStack2Url => pathParser.toUrl(getNavigationStack());
  String debugSegmentSubpath(TypedSegment s) => pathParser.toUrl(segmentSubpath(s));

  TypedPath segmentSubpath(TypedSegment s) {
    final navigationStack = getNavigationStack();

    final res = <TypedSegment>[];
    for (var i = 0; i < navigationStack.length; i++) {
      res.add(navigationStack[i]);
      if (navigationStack[i] == s) break;
    }
    return res;
  }

  /// asynchronous screen actions, start
  static Tuple2<List<GetFuture>, List<GetFuture>> waitStart(RRouter router, TypedPath oldPath, TypedPath newPath) {
    final oldTodo = <GetFuture>[];
    final newTodo = <GetFuture>[];
    void add(bool isOld, GetFuture? oper) {
      if (oper == null) return;
      (isOld ? oldTodo : newTodo).add(oper);
    }

    // close olds
    for (var i = oldPath.length - 1; i >= 0; i--) {
      final o = oldPath[i];
      final n = i >= newPath.length ? null : newPath[i];
      if (n == null || o.runtimeType != n.runtimeType) {
        add(true, router.segment2Route(o).callClosing(o));
      } else if (identical(o, n)) {
        continue;
      }
    }
    // open or replace new
    for (var i = 0; i < newPath.length; i++) {
      final n = newPath[i];
      final o = i >= oldPath.length ? null : oldPath[i];
      if (o == null || o.runtimeType != n.runtimeType) {
        add(false, router.segment2Route(n).callOpening(n));
      } else if (identical(o, n)) {
        continue;
      } else {
        // not identical and the same runtimeType
        add(false, router.segment2Route(n).callReplacing(o, n));
      }
    }
    return Tuple2(oldTodo, newTodo);
  }

  /// asynchronous screen actions, waiting and collectiong result
  Future waitEnd(Tuple2<List<GetFuture>, List<GetFuture>> todo) async {
    // first, close old stack:
    for (final fs in todo.item1) {
      await fs();
    }
    // than, open new stack:
    for (final fs in todo.item2) {
      await fs();
    }
  }

  TypedPath getNavigationStack() => ref.read(navigationStackProvider);

  void _setdependsOn(List<AlwaysAliveProviderListenable> value) {
    assert(!value.contains(ongoingPathProvider));
    _dependsOn = [...value, ongoingPathProvider];
    assert(_dependsOn.every((p) => p is Override));

    // 1. Listen to the riverpod providers. If any change, call _defer2NextTick.start().
    // 2. [_defer2NextTick.providerChanged] ensures that _runNavigation is called only once the next tick
    _unlistens = _dependsOn.map((depend) => ref.listen<dynamic>(depend, (previous, next) => _defer2NextTick.providerChanged())).toList();
  }

  /// replaces "eq" segments with "identical" ones
  void eq2Identical(TypedPath oldPath, TypedPath newPath) {
    for (var i = 0; i < min(oldPath.length, newPath.length); i++) {
      if (router.segmentEq(oldPath[i], newPath[i])) {
        newPath[i] = oldPath[i]; // "eq"  => "identical"
      }
    }
  }

  // *** common navigation-agnostic app actions ***

  NavigatePath popPath() {
    final navigationStack = getNavigationStack();
    assert(navigationStack.length > 1);
    return navigatePath([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i]]);
  }

  Future<void> pop() => popPath().onPressed();

  NavigatePath replaceLastPath<T extends TypedSegment>(T replace(T old)) {
    final navigationStack = getNavigationStack();
    return navigatePath(
      [for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i], replace(navigationStack.last as T)],
    );
  }

  Future replaceLast<T extends TypedSegment>(T replace(T old)) => replaceLastPath<T>(replace).onPressed();

  NavigatePath pushPath(TypedSegment segment) => navigatePath([...getNavigationStack(), segment]);

  Future<void> push(TypedSegment segment) => pushPath(segment).onPressed();
}
