part of 'index.dart';

class RiverpodRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath>, IRouterDelegate {
  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  TypedPath get navigatorStack => currentConfiguration;

  void set navigatorStack(TypedPath path) {
    currentConfiguration = path;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    if (currentConfiguration.isEmpty) {
      if (navigator.isNested)
        scheduleMicrotask(() {
          currentConfiguration = navigator.initPath;
          notifyListeners();
        }); //=> navigator.navigate(navigator.initPath));
      return navigator.splashBuilder?.call() ?? SizedBox();
    }
    final navigatorWidget = Navigator(
        key: navigatorKey,
        // segment => screen
        pages: currentConfiguration.map((segment) => navigator.screen2Page(segment)).toList(),
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          // remove last segment from path
          return navigator.onPopRoute();
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
