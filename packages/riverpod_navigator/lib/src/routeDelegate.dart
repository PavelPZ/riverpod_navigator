part of 'index.dart';

class RRouterDelegate extends RouterDelegate<TypedPath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath> {
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
        : navigator.navigatorWrapperBuilder(
            navigator,
            Navigator(
                key: navigatorKey,
                pages: navigationStack
                    .map((segment) => navigator.segment2Page(segment))
                    .toList(),
                onPopPage: (route, result) {
                  if (!route.didPop(result)) return false;
                  navigator.onPopRoute();
                  return true;
                }),
          );
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) {
    if (configuration.isEmpty) return Future.value();
    //configuration = navigator.initPath;
    return navigator.navigate(configuration);
  }

  void doNotifyListeners() => notifyListeners();
}

class RouteInformationParserImpl extends RouteInformationParser<TypedPath> {
  RouteInformationParserImpl(this._pathParser);

  final IPathParser _pathParser;

  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) =>
      SynchronousFuture(_pathParser.fromUrl(routeInformation.uri) ?? []);

  // @override
  // Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) =>
  //     Future.value(_pathParser.fromUrl(routeInformation.location) ?? []);

  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) =>
      RouteInformation(uri: _pathParser.toUrl(configuration));
}
