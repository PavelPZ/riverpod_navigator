part of 'index.dart';

// ********************************************
//   RNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RNavigator extends RNavigatorCore {
  RNavigator(
    Ref ref,
    List<RRoute> routes, {
    NavigatorWraperBuilder? navigatorWraperBuilder,
    SplashBuilder? splashBuilder,
    WidgetBuilder? progressIndicatorBuilder,
  })  : navigatorWraperBuilder = navigatorWraperBuilder ?? NavigatorWraper.new,
        splashBuilder = splashBuilder ?? SplashScreen.new,
        progressIndicatorBuilder = progressIndicatorBuilder ?? CircularProgressIndicator.new,
        routerDelegate = RRouterDelegate(),
        super(ref, routes) {
    routeInformationParser = RouteInformationParserImpl(pathParser);

    routerDelegate.navigator = this;
    final callInDispose = ref.listen(
      navigationStackProvider,
      (_, __) => routerDelegate.doNotifyListeners(),
    );
    ref.onDispose(callInDispose);
  }

  final NavigatorWraperBuilder navigatorWraperBuilder;
  final SplashBuilder splashBuilder;
  final WidgetBuilder progressIndicatorBuilder;
  final RRouterDelegate routerDelegate;
  late RouteInformationParserImpl routeInformationParser;

  Page segment2Page(TypedSegment segment) {
    final route = router.segment2Route<RRoute>(segment);
    final screen2Page = route.screen2Page ?? screen2PageDefault;
    return screen2Page(segment, (segment) => route.buildScreen(segment));
  }

  /// for [Navigator.onPopPage] in [RRouterDelegate.build]
  bool onPopRoute() {
    final navigationStack = getNavigationStack();
    if (navigationStack.length <= 1) return false;
    navigate([for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i]]);
    return true;
  }
}
