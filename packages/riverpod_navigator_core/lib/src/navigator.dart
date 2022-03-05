part of 'riverpod_navigator_core.dart';

// ********************************************
//   RNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RNavigatorCore {
  RNavigatorCore(
    this.ref,
    List<RRouteCore> routes,
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

  /// home path
  late TypedPath initPath;

  /// router
  final RRouter router;

  /// path parser
  late PathParser pathParser;

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
    // in ongoingPath, when ongoingPath[i] == currentTypedPath[i], set ongoingPath[i] = currentTypedPath[i]
    eq2Identical(navigationStack, newOngoingPath);

    final todo = waitStart(router, navigationStack, newOngoingPath);
    if (todo.isEmpty) return newOngoingPath;
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
  Future navigate(TypedPath newPath) {
    ref.read(ongoingPathProvider.notifier).state = newPath;
    return navigationCompleted;
  }

  /// Main [RNavigator] method. Provides navigation to the newPath.
  NavigatePath navigatePath(TypedPath newPath) => NavigatePath(() {
        ref.read(ongoingPathProvider.notifier).state = newPath;
        return navigationCompleted;
      }, newPath);

  /// wrap your async actions:
  /// ```
  /// isNavigating(true);
  /// try {
  ///   // async action
  /// } finally {
  ///   isNavigating(false);
  /// }
  /// ```
  void isNavigating(bool isNavigatingStart) =>
      ref.read(isNavigatingProvider.notifier).update((state) => isNavigatingStart ? state + 1 : state - 1);

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
  static List<Tuple2<AsyncOper, TypedSegment>> waitStart(RRouter router, TypedPath oldPath, TypedPath newPath) {
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

  /// asynchronous screen actions, waiting and collectiong result
  Future waitEnd(List<Tuple2<AsyncOper, TypedSegment>> todo) async {
    for (final fs in todo) {
      final asyncRes = await fs.item1();
      if (fs.item2.asyncHolder == null) throw 'fs.item2.asyncHolder == null';
      fs.item2.asyncHolder!.value = asyncRes;
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

  Future<void> pop() {
    final navigationStack = getNavigationStack();
    return navigationStack.length <= 1
        ? Future.value()
        : navigate([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i]]);
  }

  Future<void> push(TypedSegment segment) => navigate([...getNavigationStack(), segment]);

  Future<void> replaceLast<T extends TypedSegment>(T replace(T old)) {
    final navigationStack = getNavigationStack();
    return navigate(
      [for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i], replace(navigationStack.last as T)],
    );
  }
}
