import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

typedef NavigatorWidgetBuilder = Widget Function(BuildContext, Navigator);
typedef ScreenBuilder = Widget Function(TypedSegment segment);

class RiverpodRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath> {
  RiverpodRouterDelegate(this._navigator);

  final RiverpodNavigator _navigator;

  @override
  TypedPath get currentConfiguration => _navigator.getActualTypedPath();

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final actPath = _navigator.getActualTypedPath();
    if (actPath.isEmpty) return SizedBox();
    final navigatorWidget = Navigator(
        key: navigatorKey,
        // segment => screen
        pages: actPath.map((segment) => config.screen2Page(segment, config.screenBuilder)).toList(),
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          // remove last segment from path
          return _navigator.onPopRoute();
        });
    return config.navigatorWidgetBuilder == null ? navigatorWidget : config.navigatorWidgetBuilder!(context, navigatorWidget);
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) => _navigator.navigate(configuration);

  @override
  Future<void> setInitialRoutePath(TypedPath configuration) => _navigator.navigate(config.initPath);

  /// override, to be public
  @override
  // ignore: unnecessary_overrides
  void notifyListeners() => super.notifyListeners();
}

class RouteInformationParserImpl implements RouteInformationParser<TypedPath> {
  RouteInformationParserImpl();
  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) =>
      Future.value(config4Dart.pathParser.path2TypedPath(routeInformation.location));

  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) =>
      RouteInformation(location: config4Dart.pathParser.typedPath2Path(configuration));
}

// class _TypedSegmentScreen extends Page {
//   _TypedSegmentScreen(this._typedSegment, this._pageBuilder) : super(key: ValueKey(_typedSegment.key));

//   final TypedSegment _typedSegment;
//   final ScreenBuilder _pageBuilder;

//   @override
//   Route createRoute(BuildContext context) {
//     // this line solved https://github.com/PavelPZ/riverpod_navigator/issues/2
//     // https://github.com/flutter/flutter/issues/11655#issuecomment-469221502
//     final child = _pageBuilder(_typedSegment);
//     return MaterialPageRoute(
//       settings: this,
//       builder: (BuildContext context) => child,
//     );
//   }
// }
