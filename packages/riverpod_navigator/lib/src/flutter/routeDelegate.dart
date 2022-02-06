part of 'index.dart';

class RiverpodRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath>, IRouterDelegate {
  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final actPath = currentConfiguration;
    if (actPath.isEmpty) return navigator.splashBuilder?.call() ?? SizedBox();
    final navigatorWidget = Navigator(
        key: navigatorKey,
        // segment => screen
        pages: actPath.map((segment) => navigator.screen2Page!(segment, navigator.screenBuilder!)).toList(),
        onPopPage: (route, result) {
          //if (!route.didPop(result)) return false;
          // remove last segment from path
          navigator.onPopRoute();
          return false;
        });
    return navigator.navigatorWidgetBuilder == null ? navigatorWidget : navigator.navigatorWidgetBuilder!(context, navigatorWidget);
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) => navigator.navigate(configuration);

  @override
  Future<void> setInitialRoutePath(TypedPath configuration) => navigator.navigate(navigator.initPath);
}

class RouteInformationParserImpl implements RouteInformationParser<TypedPath> {
  RouteInformationParserImpl(this._pathParser);

  final PathParser _pathParser;

  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) => Future.value(_pathParser.path2TypedPath(routeInformation.location));

  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) => RouteInformation(location: _pathParser.typedPath2Path(configuration));
}
