part of 'index.dart';

class RiverpodRouterDelegate extends RouterDelegate<TypedPath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath>
    implements IRouterDelegate {
  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  late RNavigator navigator;

  @override
  TypedPath get navigationStack => currentConfiguration;

  @override
  void set navigationStack(TypedPath path) {
    currentConfiguration = path;
    notifyListeners();
  }

  @override
  TypedPath currentConfiguration = [];

  @override
  Widget build(BuildContext context) {
    if (navigationStack.isEmpty) {
      scheduleMicrotask(() => navigator.navigate(navigator.initPath));
      return navigator.splashBuilder?.call() ?? SizedBox();
    }
    final navigatorWidget = Navigator(
        key: navigatorKey,
        // segment => Page(child:screen)
        pages: navigationStack.map((segment) => navigator.screen2Page(segment)).toList(),
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          return navigator.onPopRoute();
        });

    return navigator.navigatorWidgetBuilder == null ? navigatorWidget : navigator.navigatorWidgetBuilder!(context, navigatorWidget);
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) => navigator.navigate(configuration);
}

class RouteInformationParserImpl implements RouteInformationParser<TypedPath> {
  RouteInformationParserImpl(this._pathParser);

  final PathParser _pathParser;

  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) => Future.value(_pathParser.path2TypedPath(routeInformation.location));

  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) => RouteInformation(location: _pathParser.typedPath2Path(configuration));
}
