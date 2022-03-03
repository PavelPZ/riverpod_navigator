part of 'index.dart';

// ********************************************
//   RNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RNavigator extends RNavigatorCore {
  RNavigator(
    Ref ref,
    List<RRoute> routes, {
    this.navigatorWidgetBuilder,
    this.splashBuilder,
  })  : routerDelegate = RRouterDelegate(),
        super(ref, routes) {
    routerDelegate.navigator = this;

    final callInDispose = ref.listen(navigationStackProvider, (previous, next) => routerDelegate.doNotifyListeners());
    ref.onDispose(callInDispose);
  }

  final NavigatorWidgetBuilder? navigatorWidgetBuilder;
  final SplashBuilder? splashBuilder;

  final RRouterDelegate routerDelegate;

  RouteInformationParserImpl get routeInformationParser =>
      _routeInformationParser ?? (_routeInformationParser = RouteInformationParserImpl(pathParser));
  RouteInformationParserImpl? _routeInformationParser;

  Page screen2Page(TypedSegment segment) {
    final route = router.segment2Route<RRoute>(segment);
    final screen2Page = route.screen2Page ?? screen2PageDefault;
    return screen2Page(segment, (segment) => route.buildScreen(segment));
  }

  /// for [Navigator.onPopPage] in [RRouterDelegate.build]
  @nonVirtual
  bool onPopRoute() {
    final navigationStack = getNavigationStack();
    if (navigationStack.length <= 1) return false;
    navigate([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i]]);
    return false;
  }
}
