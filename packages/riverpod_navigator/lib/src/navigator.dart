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
    InitAppWithRef initAppWithRef,
    this.onPathChanged,
  })  : navigatorWraperBuilder = navigatorWraperBuilder ?? NavigatorWraper.new,
        splashBuilder = splashBuilder ?? SplashScreen.new,
        progressIndicatorBuilder =
            progressIndicatorBuilder ?? CircularProgressIndicator.new,
        routerDelegate = RRouterDelegate(),
        super(
          ref,
          routes,
          initAppWithRef: initAppWithRef,
        ) {
    routeInformationParser = RouteInformationParserImpl(pathParser);

    routerDelegate.navigator = this;
    final callInDispose = ref.listen(navigationStackProvider, (_, __) {
      routerDelegate.doNotifyListeners();
      onPathChanged?.call(ref.read(navigationStackProvider));
    });
    ref.onDispose(callInDispose.close);
  }

  final NavigatorWraperBuilder navigatorWraperBuilder;
  final SplashBuilder splashBuilder;
  final WidgetBuilder progressIndicatorBuilder;
  final RRouterDelegate routerDelegate;
  late RouteInformationParserImpl routeInformationParser;
  final void Function(TypedPath path)? onPathChanged;

  Page segment2Page(TypedSegment segment) {
    final route = router.segment2Route<RRoute>(segment);
    final screen2Page = route.screen2Page ?? screen2PageDefault;
    return screen2Page(segment, (segment) => route.buildScreen(segment));
  }

  IconButton? getAppBarLeading() => getNavigationStack().length > 1
      ? IconButton(icon: Icon(Icons.arrow_back), onPressed: onPopRoute)
      : null;
}
