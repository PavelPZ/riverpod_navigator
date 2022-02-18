part of 'index.dart';

// ********************************************
//   RNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RNavigatorCore {
  RNavigatorCore(
    this.ref,
    List<RRoutes> groups, {
    PathParser pathParserCreator(Json2Segment json2Segment)?,
  })  : router = RRouter(groups),
        pathParserCreator = pathParserCreator ?? ((json2Segment) => SimplePathParser(json2Segment)) {
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
  FutureOr<TypedPath?> appNavigationLogicCore(TypedPath oldNavigationStack, TypedPath ongoingPath) {
    var newOngoingPath = appNavigationLogic(ongoingPath);

    // in ongoingPath, when ongoingPath[i] == currentTypedPath[i], set ongoingPath[i] = currentTypedPath[i]
    final navigationStack = getNavigationStack();
    newOngoingPath = eq2Identical(navigationStack, newOngoingPath);
    if (newOngoingPath == navigationStack) return null;

    final asyncResult = wait4AsyncScreenActions(router, navigationStack, newOngoingPath);
    if (asyncResult is Future) return asyncResult.then((_) => newOngoingPath);
    return newOngoingPath;
  }

  void registerProtectedFuture(Future future) => _defer2NextTick.registerProtectedFuture(future);

  late TypedPath initPath;
  final RRouter router;

  final PathParser Function(Json2Segment json2Segment) pathParserCreator;
  PathParser get pathParser => _pathParser ?? (_pathParser = pathParserCreator(router.json2Segment));
  PathParser? _pathParser;

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

  String get debugNavigationStack2String => pathParser.typedPath2Path(getNavigationStack());
  String debugSegmentSubpath(TypedSegment s) => pathParser.typedPath2Path(segmentSubpath(s));

  /// Wait for the asynchronous screen actions. The action is waiting in parallel
  ///- rewrite, when other waiting strategy is needed.
  static FutureOr<void> wait4AsyncScreenActions(RRouter router, TypedPath oldPath, TypedPath newPath) {
    final minLen = min(oldPath.length, newPath.length);
    final futures = <Tuple2<Future?, TypedSegment>>[];
    // merge old and new
    for (var i = 0; i < minLen; i++) {
      final o = oldPath[i];
      final n = newPath[i];
      // nothing to merge
      if (identical(o, n)) continue;
      if (o.runtimeType == n.runtimeType)
        // old and new has the same runtimeType => merging
        futures.add(Tuple2(router.segment2Route(n).callReplacing(o, n), n));
      else {
        // old and new has different runtimeType => deactivanting old, creating new
        futures.add(Tuple2(router.segment2Route(o).callClosing(o), o));
        futures.add(Tuple2(router.segment2Route(n).callOpening(n), n));
      }
    }
    // deactivating the rest of old segments
    if (oldPath.length > minLen)
      for (var i = minLen; i < oldPath.length; i++) futures.add(Tuple2(router.segment2Route(oldPath[i]).callClosing(oldPath[i]), oldPath[i]));
    // creating the rest of new segments
    if (newPath.length > minLen)
      for (var i = minLen; i < newPath.length; i++) futures.add(Tuple2(router.segment2Route(newPath[i]).callOpening(newPath[i]), newPath[i]));
    // remove empty futures
    final notEmptyFutures = [
      for (final f in futures)
        if (f.item1 != null) f
    ];
    if (notEmptyFutures.isEmpty) return null;

    return Future.wait(notEmptyFutures.map((fs) => fs.item1 as Future)).then((asyncResults) {
      assert(asyncResults.length == notEmptyFutures.length);
      // Save the result of the async action
      for (var i = 0; i < asyncResults.length; i++) notEmptyFutures[i].item2.asyncActionResult = asyncResults[i];
    });
  }

  TypedPath getNavigationStack() => ref.read(navigationStackProvider);

  void _setdependsOn(List<AlwaysAliveProviderListenable> value) {
    _dependsOn = [...value, if (!value.contains(ongoingPathProvider)) ongoingPathProvider];
    assert(_dependsOn.every((p) => p is Override));

    // 1. Listen to the riverpod providers. If any change, call _defer2NextTick.start().
    // 2. [providerChanged] ensures that _runNavigation is called only once the next tick
    // 3. Add RemoveListener's to unlistens
    // 4. Use unlistens in ref.onDispose
    _unlistens = _dependsOn.map((depend) => ref.listen<dynamic>(depend, (previous, next) => _defer2NextTick.providerChanged())).toList();
  }

  late List<AlwaysAliveProviderListenable> _dependsOn;
  late List<Function> _unlistens;

  /// for nested navigator: keep state of nested navigator in flutter tabs widget
  late RestorePath? _restorePath;

  @protected
  final Ref ref;
  late Defer2NextTick _defer2NextTick;

  /// replaces "eq" segments with "identical" ones
  @protected
  static TypedPath eq2Identical(TypedPath oldPath, TypedPath newPath) {
    var pathsEqual = oldPath.length == newPath.length;
    for (var i = 0; i < min(oldPath.length, newPath.length); i++) {
      if (oldPath[i] == newPath[i])
        newPath[i] = oldPath[i]; // "eq"  => "identical"
      else
        pathsEqual = false; // same of the state[i] is not equal
    }
    return pathsEqual ? oldPath : newPath;
  }

  // *** common navigation-agnostic app actions ***

  @nonVirtual
  Future<void> pop() {
    final navigationStack = getNavigationStack();
    return navigationStack.length <= 1 ? Future.value() : navigate([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i]]);
  }

  @nonVirtual
  Future<void> push(TypedSegment segment) => navigate([...getNavigationStack(), segment]);

  @nonVirtual
  Future<void> replaceLast<TOld extends TypedSegment, TNew extends TypedSegment>(TNew replace(TOld old)) {
    final navigationStack = getNavigationStack();
    return navigate([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i], replace(navigationStack.last as TOld)]);
  }

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
          .._setdependsOn(dependsOn))),
      ];
}
