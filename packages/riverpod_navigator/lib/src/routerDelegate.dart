import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

import 'route.dart';

typedef NavigatorWidgetBuilder = Widget Function(BuildContext, Navigator);

class RiverpodRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath> {
  RiverpodRouterDelegate(this._navigator, {required this.initPath, this.navigatorWidgetBuilder});

  final NavigatorWidgetBuilder? navigatorWidgetBuilder;
  final TypedPath initPath;
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
        // segment => route => route.build(segment)
        pages: actPath.map((segment) {
          final route = _navigator.getRouteWithSegment(segment).route as NavigRoute;
          return _TypedSegmentPage(segment, route.buildPage);
        }).toList(),
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          // remove last segment from path
          return _navigator.onPopRoute();
        });
    return navigatorWidgetBuilder == null ? navigatorWidget : navigatorWidgetBuilder!(context, navigatorWidget);
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) => _navigator.navigate(configuration);

  @override
  Future<void> setInitialRoutePath(TypedPath configuration) => _navigator.navigate(initPath);

  /// override to be public
  @override
  // ignore: unnecessary_overrides
  void notifyListeners() => super.notifyListeners();
}

class RouteInformationParserImpl implements RouteInformationParser<TypedPath> {
  RouteInformationParserImpl(this._pathParser);
  final PathParser _pathParser;
  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) => Future.value(_pathParser.path2TypedPath(routeInformation.location));

  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) => RouteInformation(location: _pathParser.typedPath2Path(configuration));
}

typedef _PageBuilder = Widget Function(TypedSegment segment);

class _TypedSegmentPage extends Page {
  _TypedSegmentPage(this._typedSegment, this._pageBuilder) : super(key: ValueKey(_typedSegment.key));

  final TypedSegment _typedSegment;
  final _PageBuilder _pageBuilder;

  @override
  Route createRoute(BuildContext context) {
    // this line solved https://github.com/PavelPZ/riverpod_navigator/issues/2
    // https://github.com/flutter/flutter/issues/11655#issuecomment-469221502
    final child = _pageBuilder(_typedSegment);
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => child,
    );
  }
}
