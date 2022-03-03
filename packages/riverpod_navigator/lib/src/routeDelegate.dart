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
    if (navigationStack.isEmpty) {
      if (navigator.splashBuilder == null) {
        return SizedBox.expand(child: Container(color: Colors.white, child: Center(child: CircularProgressIndicator())));
      }
      return navigator.splashBuilder!();
    }
    final navigatorWidget = Navigator(
        key: navigatorKey,
        // segment => Page(child:screen)
        pages: navigationStack.map((segment) => navigator.screen2Page(segment)).toList(),
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          return navigator.onPopRoute();
        });

    return navigator.navigatorWidgetBuilder == null
        ? Consumer(builder: (_, ref, __) {
            final navigating = ref.watch(appLogicRunningProvider);
            return Stack(children: [
              SizedBox.expand(child: AbsorbPointer(child: navigatorWidget, absorbing: navigating > 0)),
              if (navigating > 0)
                FutureBuilder(
                  future: Future.delayed(Duration(milliseconds: 250)),
                  builder: (_, snapshot) => SizedBox.expand(
                    child: snapshot.connectionState == ConnectionState.waiting ? SizedBox() : Center(child: CircularProgressIndicator()),
                  ),
                ),
            ]);
          })
        : navigator.navigatorWidgetBuilder!(context, navigatorWidget);
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

  final PathParser _pathParser;

  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) =>
      Future.value(_pathParser.fromUrl(routeInformation.location));

  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) => RouteInformation(location: _pathParser.toUrl(configuration));
}
