part of 'index.dart';

// ********************************************
//   RNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RNavigator extends RNavigatorCore {
  RNavigator(
    Ref ref,
    List<RRoutes> groups, {
    // List<AlwaysAliveProviderListenable>? dependsOn,
    this.navigatorWidgetBuilder,
    this.splashBuilder,
    bool isDebugRouteDelegate = false,
    // RestorePath? restorePath,
  })  : router = RRouter(groups),
        _routerDelegate = isDebugRouteDelegate ? RouterDelegate4Dart() : RiverpodRouterDelegate(),
        super(ref) {
    _routerDelegate.navigator = this;

    final callInDispose = ref.listen(navigationStackProvider, (previous, next) => _routerDelegate.notifyListeners());
    ref.onDispose(callInDispose);

    RNavigatorCore.kIsWeb = kIsWeb;
  }

  /// Enter application navigation logic here (redirection, login, etc.).
  /// No need to override (eg when the navigation status depends only on the ongoingPathProvider and no redirects or route guards are needed)
  TypedPath appNavigationLogic(TypedPath ongoingPath, {CToken? cToken}) => ongoingPath;

  final NavigatorWidgetBuilder? navigatorWidgetBuilder;
  final SplashBuilder? splashBuilder;

  final RRouter router;

  /// Overwrite for another [PathParser]
  PathParser pathParserCreator() => SimplePathParser(router.json2Segment);

  /// for app
  RiverpodRouterDelegate get routerDelegate => _routerDelegate as RiverpodRouterDelegate;

  /// depends on the use: in app = RiverpodRouterDelegate(), in tests = RouterDelegate4Dart()
  final IRouterDelegate _routerDelegate;

  RouteInformationParserImpl get routeInformationParser =>
      _routeInformationParser ?? (_routeInformationParser = RouteInformationParserImpl(pathParser));
  RouteInformationParserImpl? _routeInformationParser;

  /// Main [RNavigator] method. Provides navigation to newPath.
  Future<void> navigate(TypedPath newPath) async {
    ref.read(ongoingPathProvider.notifier).state = newPath;
    return navigationCompleted;
  }

  String get debugNavigationStack2String => pathParser.typedPath2Path(getNavigationStack());
  String debugSegmentSubpath(TypedSegment s) => pathParser.typedPath2Path(segmentSubpath(s));

  TypedPath segmentSubpath(TypedSegment s) {
    final navigationStack = getNavigationStack();

    final res = <TypedSegment>[];
    for (var i = 0; i < navigationStack.length; i++) {
      res.add(navigationStack[i]);
      if (navigationStack[i] == s) break;
    }
    return res;
  }

  Page screen2Page(TypedSegment segment) {
    final route = router.segment2Route(segment);
    final screen2Page = route.screen2Page ?? screen2PageDefault;
    return screen2Page(segment, (segment) => route.buildScreen(segment));
  }

  PathParser get pathParser => _pathParser ?? (_pathParser = pathParserCreator());
  PathParser? _pathParser;

  @override
  FutureOr<TypedPath?> appNavigationLogicCore(TypedPath ongoingPath, {CToken? cToken}) {
    var newOngoingPath = appNavigationLogic(ongoingPath, cToken: cToken);

    // in ongoingPath, when ongoingPath[i] == currentTypedPath[i], set ongoingPath[i] = currentTypedPath[i]
    final navigationStack = getNavigationStack();
    newOngoingPath = eq2Identical(navigationStack, newOngoingPath);
    if (newOngoingPath == navigationStack) return null;

    final asyncResult = wait4AsyncScreenActions(navigationStack, newOngoingPath);
    if (asyncResult is Future)
      return asyncResult.then((_) {
        if (cToken?.isCancelling == true) return [];
        return newOngoingPath;
      });
    return newOngoingPath;
  }

  /// for [Navigator.onPopPage] in [RiverpodRouterDelegate.build]
  @nonVirtual
  bool onPopRoute() {
    final navigationStack = getNavigationStack();
    if (navigationStack.length <= 1) return false;
    navigate([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i]]);
    return true;
  }

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

  /// Wait for the asynchronous screen actions. The action is waiting in parallel
  ///- rewrite, when other waiting strategy is needed.
  @protected
  FutureOr<void> wait4AsyncScreenActions(TypedPath oldPath, TypedPath newPath) {
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
        futures.add(Tuple2(router.segment2Route(n).callMerging(o, n), n));
      else {
        // old and new has different runtimeType => deactivanting old, creating new
        futures.add(Tuple2(router.segment2Route(o).callDeactivating(o), o));
        futures.add(Tuple2(router.segment2Route(n).callCreating(n), n));
      }
    }
    // deactivating the rest of old segments
    if (oldPath.length > minLen)
      for (var i = minLen; i < oldPath.length; i++) futures.add(Tuple2(router.segment2Route(oldPath[i]).callDeactivating(oldPath[i]), oldPath[i]));
    // creating the rest of new segments
    if (newPath.length > minLen)
      for (var i = minLen; i < newPath.length; i++) futures.add(Tuple2(router.segment2Route(newPath[i]).callCreating(newPath[i]), newPath[i]));
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

    // // wait for async actions
    // final asyncResults = await Future.wait(notEmptyFutures.map((fs) => fs.item1 as Future));
    // assert(asyncResults.length == notEmptyFutures.length);

    // // Save the result of the async action
    // for (var i = 0; i < asyncResults.length; i++) notEmptyFutures[i].item2.asyncActionResult = asyncResults[i];
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
  Future<void> replaceLast(TypedSegment segment) {
    final navigationStack = getNavigationStack();
    return navigate([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i], segment]);
  }
}
