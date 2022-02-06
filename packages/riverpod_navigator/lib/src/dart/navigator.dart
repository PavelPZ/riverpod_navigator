part of 'index.dart';

// ********************************************
//   RiverpodNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
abstract class RiverpodNavigator extends RiverpodNavigatorFlutter {
  RiverpodNavigator(
    this.ref, {
    required this.initPath,
    List<AlwaysAliveProviderListenable>? dependsOn,
    Json2Segment? json2Segment,
    Segment2AsyncScreenActions? segment2AsyncScreenActions,
    this.router,
    // flutter part
    Screen2Page? screen2Page,
    ScreenBuilder? screenBuilder,
    NavigatorWidgetBuilder? navigatorWidgetBuilder,
    SplashBuilder? splashBuilder,
  })  : assert((json2Segment != null) != (router != null), 'json2Segment or router required, but not both'),
        assert(router == null || segment2AsyncScreenActions == null, 'segment2AsyncScreenActions is ignored when a router is provided'),
        json2Segment = json2Segment ?? (router as TypedRouter).json2Segment,
        segment2AsyncScreenActions = segment2AsyncScreenActions ?? router?.segment2AsyncScreenActions,
        flutterConfig = Object(),
        routerDelegate = RouterDelegate4Dart(),
        super(
          router: router,
          screen2Page: screen2Page,
          screenBuilder: screenBuilder,
          navigatorWidgetBuilder: navigatorWidgetBuilder,
          splashBuilder: splashBuilder,
        ) {
    routerDelegate.navigator = this;

    _defer2NextTickLow = Defer2NextTick(runNextTick: _runNavigation);
    final allDepends = <AlwaysAliveProviderListenable>[ongoingPathProvider, if (dependsOn != null) ...dependsOn];
    for (final depend in allDepends) _unlistens.add(ref.listen<dynamic>(depend, (previous, next) => _defer2NextTick.start()));
    // ignore: avoid_function_literals_in_foreach_calls
    ref.onDispose(() => _unlistens.forEach((f) => f()));
  }

  /// initial screen
  final TypedPath initPath;

  /// screen async-navigation actions
  final Segment2AsyncScreenActions? segment2AsyncScreenActions;

  /// [JsonMap] to [TypedSegment] converter.
  /// It is used as the basis for the PathParser.
  Json2Segment json2Segment;

  /// properties which needs Flutter library
  Object flutterConfig = Object();

  TypedRouter? router;

  /// Overwrite for another [PathParser]
  PathParser pathParserCreator() => SimplePathParser(json2Segment);

  /// When changing navigation state: completed after Flutter navigation stack is actual
  Future<void> get navigationCompleted => _defer2NextTick.future;

  /// Put all change-route application logic here (redirects, logged in test etc.)
  FutureOr<void> appNavigationLogic(Ref ref, TypedPath currentPath) => null;

  /// depends on the used platform: flutter (= [RiverpodRouterDelegate]) x dart only (= [RouterDelegate4Dart])
  IRouterDelegate routerDelegate = RouterDelegate4Dart();

  @protected
  Ref ref;

  /// Main [RiverpodNavigator] method. Provides navigation to the new [TypedPath].
  @nonVirtual
  Future<void> navigate(TypedPath newPath) async {
    ref.read(ongoingPathProvider.notifier).state = newPath;
    return navigationCompleted;
  }

  @nonVirtual
  TypedPath get currentTypedPath => routerDelegate.currentConfiguration;

  @nonVirtual
  String debugTypedPath2String() => pathParser.debugTypedPath2String(currentTypedPath);

  PathParser get pathParser => _pathParser ?? (_pathParser = pathParserCreator());
  PathParser? _pathParser;

  Defer2NextTick get _defer2NextTick => _defer2NextTickLow as Defer2NextTick;
  Defer2NextTick? _defer2NextTickLow;
  final List<Function> _unlistens = [];

  /// synchronize [ongoingPathProvider] with [RiverpodRouterDelegate.currentConfiguration]
  Future<void> _runNavigation() async {
    final appLogic = appNavigationLogic(ref, currentTypedPath);
    if (appLogic is Future) await appLogic;
    // when ongoingPath[i] == currentTypedPath[i], set currentTypedPath[i] = ongoingPath[i]
    final ongoingPath = eq2Identical(currentTypedPath, ref.read(ongoingPathProvider));
    if (ongoingPath == currentTypedPath) return;

    // Wait for async screen actions.
    if (segment2AsyncScreenActions != null) await wait4AsyncScreenActions(currentTypedPath, ongoingPath);
    // actualize flutter navigation stack
    routerDelegate.currentConfiguration = ongoingPath;
    routerDelegate.notifyListeners();
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
