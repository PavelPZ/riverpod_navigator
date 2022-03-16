part of 'index.dart';

class RRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath> {
  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late RNavigator navigator;

  @override
  TypedPath get currentConfiguration => navigator.getNavigationStack();

  @override
  Widget build(BuildContext context) {
    final navigationStack = currentConfiguration;

    return navigationStack.isEmpty
        ? navigator.splashBuilder(navigator)
        : navigator.navigatorWraperBuilder(
            navigator,
            Navigator(
                key: navigatorKey,
                // segment => Page(child:screen)
                pages: navigationStack.map((segment) => navigator.segment2Page(segment)).toList(),
                onPopPage: (route, result) {
                  // cannot be used when navigation is async
                  if (!route.didPop(result)) return false;
                  return navigator.onPopRoute();
                }),
          );
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) {
    if (configuration.isEmpty) configuration = navigator.initPath;
    return navigator.navigate(configuration);
  }

  void doNotifyListeners() => notifyListeners();
}

class RouteInformationParserImpl implements RouteInformationParser<TypedPath> {
  RouteInformationParserImpl(this._pathParser);

  final IPathParser _pathParser;

  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) =>
      Future.value(_pathParser.fromUrl(routeInformation.location));

  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) => RouteInformation(location: _pathParser.toUrl(configuration));
}
