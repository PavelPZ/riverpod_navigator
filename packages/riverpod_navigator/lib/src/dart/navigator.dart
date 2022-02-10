part of 'index.dart';

// ********************************************
//   RiverpodNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RiverpodNavigator {
  RiverpodNavigator(
    Ref ref, {
    required TypedPath initPath,
    // required Json2Segment json2Segment,
    required TypedSegment Function(JsonMap json) fromJson,
    required ScreenBuilder screenBuilder,
    List<AlwaysAliveProviderListenable>? dependsOn,
    Segment2AsyncScreenActions? segment2AsyncScreenActions,
    Screen2Page? screen2Page,
    NavigatorWidgetBuilder? navigatorWidgetBuilder,
    SplashBuilder? splashBuilder,
    bool isDebugRouteDelegate = false,
  }) : this._(
          ref,
          initPath,
          (json, _) => fromJson(json),
          dependsOn: dependsOn,
          segment2AsyncScreenActions: segment2AsyncScreenActions,
          screen2Page: screen2Page,
          screenBuilder: screenBuilder,
          navigatorWidgetBuilder: navigatorWidgetBuilder,
          splashBuilder: splashBuilder,
          isDebugRouteDelegate: isDebugRouteDelegate,
        );

  RiverpodNavigator._(
    this.ref,
    this.initPath,
    this._json2Segment, {
    // by group replaced props
    this.segment2AsyncScreenActions,
    this.screen2Page,
    this.screenBuilder,
    // ...
    this.navigatorWidgetBuilder,
    this.splashBuilder,
    this.router,
    RGroup? routerGroup,
    List<AlwaysAliveProviderListenable>? dependsOn,
    bool isDebugRouteDelegate = false,
  }) {
    routerDelegate4Dart = isDebugRouteDelegate ? RouterDelegate4Dart() : RiverpodRouterDelegate();
    routerDelegate4Dart.navigator = this;

    if (routerGroup != null) router = RRouter([routerGroup]);
    if (router != null) {
      _json2Segment = router?.json2Segment;
      segment2AsyncScreenActions = router?.segment2AsyncScreenActions;
      screen2Page = router?.screen2Page();
      screenBuilder = router?.screenBuilder();
    }

    screen2Page ??= screen2PageDefault;

    _defer2NextTickLow = Defer2NextTick(runNextTick: _runNavigation);
    final allDepends = <AlwaysAliveProviderListenable>[ongoingPathProvider, if (dependsOn != null) ...dependsOn];
    for (final depend in allDepends) _unlistens.add(ref.listen<dynamic>(depend, (previous, next) => _defer2NextTick.start()));
    // ignore: avoid_function_literals_in_foreach_calls
    ref.onDispose(() => _unlistens.forEach((f) => f()));
  }
  RiverpodNavigator.router(
    Ref ref,
    TypedPath initPath,
    RGroup routerGroup, {
    List<AlwaysAliveProviderListenable>? dependsOn,
    NavigatorWidgetBuilder? navigatorWidgetBuilder,
    SplashBuilder? splashBuilder,
  }) : this._(
          ref,
          initPath,
          null,
          dependsOn: dependsOn,
          routerGroup: routerGroup,
          navigatorWidgetBuilder: navigatorWidgetBuilder,
          splashBuilder: splashBuilder,
        );

  RiverpodNavigator.routers(
    Ref ref,
    TypedPath initPath,
    RRouter router, {
    List<AlwaysAliveProviderListenable>? dependsOn,
    NavigatorWidgetBuilder? navigatorWidgetBuilder,
    SplashBuilder? splashBuilder,
  }) : this._(
          ref,
          initPath,
          null,
          dependsOn: dependsOn,
          router: router,
          navigatorWidgetBuilder: navigatorWidgetBuilder,
          splashBuilder: splashBuilder,
        );

  /// initial screen
  final TypedPath initPath;

  /// screen async-navigation actions
  ///
  /// Navigation is delayed until the asynchronous actions are performed. These actions are:
  ///- **creating** (before inserting a new screen into the navigation stack)
  /// - **deactivating** (before removing the old screen from the navigation stack)
  /// - **merging** (before screen replacement with the same segment type in the navigation stack)
  Segment2AsyncScreenActions? segment2AsyncScreenActions;

  /// [JsonMap] to [TypedSegment] converter.
  /// It is used as the basis for the PathParser.
  Json2Segment? _json2Segment;
  Json2Segment get json2Segment => _json2Segment as Json2Segment;

  /// [router] is mutually exclusive with [json2Segment], [screen2Page], [segment2AsyncScreenActions], [screen2Page]
  RRouter? router;

  Screen2Page? screen2Page;
  ScreenBuilder? screenBuilder;
  final NavigatorWidgetBuilder? navigatorWidgetBuilder;
  final SplashBuilder? splashBuilder;

  /// Overwrite for another [PathParser]
  PathParser pathParserCreator() => SimplePathParser(json2Segment);

  /// When changing navigation state: completed after Flutter navigation stack is actual
  Future<void> get navigationCompleted => _defer2NextTick.future;

  /// Enter application navigation logic here (redirection, login, etc.).
  /// No need to override (eg when the navigation status depends only on the ongoingPathProvider and no redirects or route guard is needed)
  TypedPath appNavigationLogic(TypedPath ongoingPath) => ongoingPath;

  /// depends on the used platform: flutter (= [RiverpodRouterDelegate]) x dart only (= [RouterDelegate4Dart])
  IRouterDelegate routerDelegate4Dart = RouterDelegate4Dart();
  RiverpodRouterDelegate get routerDelegate => routerDelegate4Dart as RiverpodRouterDelegate;

  RouteInformationParserImpl get routeInformationParser =>
      _routeInformationParser ?? (_routeInformationParser = RouteInformationParserImpl(pathParser));
  RouteInformationParserImpl? _routeInformationParser;

  @protected
  Ref ref;

  /// Main [RiverpodNavigator] method. Provides navigation to the new [TypedPath].
  @nonVirtual
  Future<void> navigate(TypedPath newPath) async {
    ref.read(ongoingPathProvider.notifier).state = newPath;
    return navigationCompleted;
  }

  @nonVirtual
  TypedPath get currentTypedPath => routerDelegate4Dart.currentConfiguration;

  String get debugCurrentPath2String => pathParser.typedPath2Path(currentTypedPath);
  String debugSegmentSubpath(TypedSegment s) => pathParser.typedPath2Path(segmentSubpath(s));

  TypedPath segmentSubpath(TypedSegment s) {
    final res = <TypedSegment>[];
    for (var i = 0; i < currentTypedPath.length; i++) {
      res.add(currentTypedPath[i]);
      if (currentTypedPath[i] == s) break;
    }
    return res;
  }

  @nonVirtual
  String debugTypedPath2String() => pathParser.debugTypedPath2String(currentTypedPath);

  PathParser get pathParser => _pathParser ?? (_pathParser = pathParserCreator());
  PathParser? _pathParser;

  Defer2NextTick get _defer2NextTick => _defer2NextTickLow as Defer2NextTick;
  Defer2NextTick? _defer2NextTickLow;
  final List<Function> _unlistens = [];

  /// synchronize [ongoingPathProvider] with [RiverpodRouterDelegate.currentConfiguration]
  Future<void> _runNavigation() async {
    var ongoingPath = appNavigationLogic(ref.read(ongoingPathProvider));
    // in ongoingPath, when ongoingPath[i] == currentTypedPath[i], set ongoingPath[i] = currentTypedPath[i]
    ongoingPath = eq2Identical(currentTypedPath, ongoingPath);
    if (ongoingPath == currentTypedPath) return;

    // Wait for async screen actions.
    if (segment2AsyncScreenActions != null) await wait4AsyncScreenActions(currentTypedPath, ongoingPath);
    // actualize flutter navigation stack
    routerDelegate4Dart.currentConfiguration = ongoingPath;
    routerDelegate4Dart.notifyListeners();
  }

  /// for [Navigator.onPopPage] in [RiverpodRouterDelegate.build]
  @nonVirtual
  bool onPopRoute() {
    final actPath = currentTypedPath;
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
  Future<void> wait4AsyncScreenActions(TypedPath oldPath, TypedPath newPath) async {
    final minLen = min(oldPath.length, newPath.length);
    final futures = <Tuple2<Future?, TypedSegment>>[];
    final actions = segment2AsyncScreenActions as Segment2AsyncScreenActions;
    // merge old and new
    for (var i = 0; i < minLen; i++) {
      final o = oldPath[i];
      final n = newPath[i];
      // nothing to merge
      if (identical(o, n)) continue;
      if (o.runtimeType == n.runtimeType)
        // old and new has the same route => merging
        futures.add(Tuple2(actions(n)?.callMerging(o, n), n));
      else {
        // old and new has different route => deactivanting old, creating new
        futures.add(Tuple2(actions(o)?.callDeactivating(o), o));
        futures.add(Tuple2(actions(n)?.callCreating(n), n));
      }
    }
    // deactivating the rest of old segments
    if (oldPath.length > minLen)
      for (var i = minLen; i < oldPath.length; i++) futures.add(Tuple2(actions(oldPath[i])?.callDeactivating(oldPath[i]), oldPath[i]));
    // creating the rest of new segments
    if (newPath.length > minLen)
      for (var i = minLen; i < newPath.length; i++) futures.add(Tuple2(actions(newPath[i])?.callCreating(newPath[i]), newPath[i]));
    // remove empty futures
    final notEmptyFutures = [
      for (final f in futures)
        if (f.item1 != null) f
    ];
    if (notEmptyFutures.isEmpty) return;

    final asyncResults = await Future.wait(notEmptyFutures.map((fs) => fs.item1 as Future));
    assert(asyncResults.length == notEmptyFutures.length);

    // Save the result of the async action
    for (var i = 0; i < asyncResults.length; i++) notEmptyFutures[i].item2.asyncActionResult = asyncResults[i];
  }

  // *** common navigation-agnostic app actions ***

  @nonVirtual
  Future<void> pop() =>
      currentTypedPath.length <= 1 ? Future.value() : navigate([for (var i = 0; i < currentTypedPath.length - 1; i++) currentTypedPath[i]]);

  @nonVirtual
  Future<void> push(TypedSegment segment) => navigate([...currentTypedPath, segment]);

  @nonVirtual
  Future<void> replaceLast(TypedSegment segment) => navigate([for (var i = 0; i < currentTypedPath.length - 1; i++) currentTypedPath[i], segment]);
}

// ********************************************
//   Defer2NextTick
// ********************************************

/// helper class that solves the problem where two providers (on which navigation depends) change in one tick, e.g.
///
/// ```
/// ref.read(userIsLoggedProvider.notifier).update((s) => !s)
/// ref.read(ongoingTypedPath.notifier).state = [HomeSegment(), BooksSegment()];
/// ```
/// without the Defer2NextTick class, [RouterDelegate.notifyListeners] is called twice:
/// ```
/// routerDelegate.currentConfiguration = ref.read(ongoingTypedPath);
/// routerDelegate.doNotifyListener();
/// ```
class Defer2NextTick {
  Defer2NextTick({required this.runNextTick});
  Completer? _completer;
  FutureOr<void> Function() runNextTick;

  void start() {
    if (_completer != null) return;
    _completer = Completer();
    scheduleMicrotask(() async {
      try {
        final value = runNextTick();
        if (value is Future) await value;
        _completer?.complete();
      } catch (e, s) {
        _completer?.completeError(e, s);
      }
      _completer = null;
    });
  }

  Future<void> get future => _completer != null ? (_completer as Completer).future : Future.value();
}
