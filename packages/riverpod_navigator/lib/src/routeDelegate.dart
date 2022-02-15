part of 'index.dart';

class RiverpodRouterDelegate extends RouterDelegate<TypedPath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath>
    implements IRouterDelegate {
  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  late RNavigator navigator;

  @override
  TypedPath get currentConfiguration => navigator.getNavigationStack();

  @override
  Widget build(BuildContext context) {
    final navigationStack = currentConfiguration;
    if (navigationStack.isEmpty) {
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
  Future<void> setNewRoutePath(TypedPath configuration) {
    if (configuration.isEmpty) configuration = navigator.initPath;
    return navigator.navigate(configuration);
    // return SynchronousFuture(null);
  }
}
