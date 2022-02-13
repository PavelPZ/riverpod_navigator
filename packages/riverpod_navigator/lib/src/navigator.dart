part of 'index.dart';

// ********************************************
//   RiverpodNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RiverpodNavigator {
  RiverpodNavigator(
    this.ref,
    TypedPath initPath,
    List<RRoutes> groups, {
    List<AlwaysAliveProviderListenable>? dependsOn,
    this.navigatorWidgetBuilder,
    this.splashBuilder,
    bool isDebugRouteDelegate = false,
    this.restorePath,
  })  : router = RRouter(groups),
        initPath = restorePath == null ? initPath : restorePath.getInitialPath(initPath),
        _routerDelegate = isDebugRouteDelegate ? RouterDelegate4Dart() : RiverpodRouterDelegate() {
    _routerDelegate.navigator = this;

    ref.onDispose(() => restorePath?.onPathChanged(navigationStack));

    // _runNavigation only once on the next tick
    _defer2NextTick = Defer2NextTick(nextTickRunner: _runNavigation);
    this.dependsOn.add(ongoingPathProvider);
    if (dependsOn != null) this.dependsOn.addAll(dependsOn);
    assert(this.dependsOn.every((p) => p is Override));

    // 1. Listen to the riverpod providers. If any change, call _defer2NextTick.start().
    // 2. _defer2NextTick ensures that _runNavigation is called only once the next tick
    // 3. Add RemoveListener's to unlistens
    // 4. Use unlistens in ref.onDispose
    final unlistens = this.dependsOn.map((depend) => ref.listen<dynamic>(depend, (previous, next) => _defer2NextTick!.start())).toList();

    // ignore: avoid_function_literals_in_foreach_calls
    ref.onDispose(() => unlistens.forEach((f) => f()));
  }

  /// initial screen
  final TypedPath initPath;

  final RRouter router;

  /// current navigationStack
  TypedPath get navigationStack => _routerDelegate.navigationStack;

  /// Enter application navigation logic here (redirection, login, etc.).
  /// No need to override (eg when the navigation status depends only on the ongoingPathProvider and no redirects or route guard is needed)
  TypedPath appNavigationLogic(TypedPath ongoingPath) => ongoingPath;

  /// When changing navigation state: completed after Flutter navigation stack is actual
  Future<void> get navigationCompleted => _defer2NextTick!.future;

  final NavigatorWidgetBuilder? navigatorWidgetBuilder;
  final SplashBuilder? splashBuilder;

  /// Overwrite for another [PathParser]
  PathParser pathParserCreator() => SimplePathParser(router.json2Segment);

  /// for app
  RiverpodRouterDelegate get routerDelegate => _routerDelegate as RiverpodRouterDelegate;

  /// depends on the use: in app = RiverpodRouterDelegate(), in tests = RouterDelegate4Dart()
  final IRouterDelegate _routerDelegate;

  RouteInformationParserImpl get routeInformationParser =>
      _routeInformationParser ?? (_routeInformationParser = RouteInformationParserImpl(pathParser));
  RouteInformationParserImpl? _routeInformationParser;

  final List<AlwaysAliveProviderListenable> dependsOn = [];

  final RestorePath? restorePath;

  @protected
  Ref ref;

  /// Main [RiverpodNavigator] method. Provides navigation to the new [TypedPath].
  Future<void> navigate(TypedPath newPath) async {
    ref.read(ongoingPathProvider.notifier).state = newPath;
    return navigationCompleted;
  }

  String get debugNavigationStack2String => pathParser.typedPath2Path(navigationStack);
  String debugSegmentSubpath(TypedSegment s) => pathParser.typedPath2Path(segmentSubpath(s));

  TypedPath segmentSubpath(TypedSegment s) {
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

  Defer2NextTick? _defer2NextTick;

  /// synchronize [ongoingPathProvider] with [navigationStack]
  Future<void> _runNavigation() async {
    final ongoingNotifier = ref.read(ongoingPathProvider.notifier);
    var ongoingPath = appNavigationLogic(ongoingNotifier.state);
    // in ongoingPath, when ongoingPath[i] == currentTypedPath[i], set ongoingPath[i] = currentTypedPath[i]
    ongoingPath = eq2Identical(navigationStack, ongoingPath);
    if (ongoingPath == navigationStack) return;

    // Wait for async screen actions.
    await wait4AsyncScreenActions(navigationStack, ongoingPath);

    // checking _defer2NextTick!.runnerActive is not required
    _defer2NextTick!.runnerActive = false;

    // actualize flutter navigation stack and ongoingPathProvider
    _routerDelegate.navigationStack = ongoingNotifier.state = ongoingPath;
  }

  /// for [Navigator.onPopPage] in [RiverpodRouterDelegate.build]
  @nonVirtual
  bool onPopRoute() {
    final actPath = navigationStack;
    if (actPath.length <= 1) return false;
    navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
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
  ///- rewrite, when other waiting strategies are needed.
  @protected
  FutureOr<void> wait4AsyncScreenActions(TypedPath oldPath, TypedPath newPath) async {
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
    if (notEmptyFutures.isEmpty) return;

    // wait for async actions
    final asyncResults = await Future.wait(notEmptyFutures.map((fs) => fs.item1 as Future));
    assert(asyncResults.length == notEmptyFutures.length);

    // Save the result of the async action
    for (var i = 0; i < asyncResults.length; i++) notEmptyFutures[i].item2.asyncActionResult = asyncResults[i];
  }

  // *** common navigation-agnostic app actions ***

  @nonVirtual
  Future<void> pop() =>
      navigationStack.length <= 1 ? Future.value() : navigate([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i]]);

  @nonVirtual
  Future<void> push(TypedSegment segment) => navigate([...navigationStack, segment]);

  @nonVirtual
  Future<void> replaceLast(TypedSegment segment) => navigate([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i], segment]);
}

// ********************************************
//   Defer2NextTick
// ********************************************

/// helper class that solves the problem where two providers (on which navigation depends) change in one tick
///
/// eg. if after a successful login:
///   1. change the login state to true
///   2. change the ongoingPath state to a screen requiring a login
/// in this case, without the Defer2NextTick class, [RouterDelegate.navigationStack] is changed twice
class Defer2NextTick {
  Defer2NextTick({required this.nextTickRunner});
  // called once in the next tick
  FutureOr<void> Function() nextTickRunner;

  Completer? _completer;
  bool runnerActive = false;

  /// called in every state change
  void start() {
    if (_completer != null) {
      if (runnerActive) _completer!.completeError('State changed during running Defer2NextTick.nextTickRunner');
      return;
    }
    _completer = Completer();
    scheduleMicrotask(() async {
      runnerActive = true;
      try {
        try {
          final value = nextTickRunner();
          if (value is Future) await value;
          _completer!.complete();
        } catch (e, s) {
          _completer!.completeError(e, s);
        }
      } finally {
        runnerActive = false;
        _completer = null;
      }
    });
  }

  Future<void> get future => _completer != null ? _completer!.future : Future.value();
}
