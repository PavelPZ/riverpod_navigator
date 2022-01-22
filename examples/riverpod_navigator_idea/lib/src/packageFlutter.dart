import 'dart:async';

import 'package:flutter/material.dart';
import 'packageDart.dart';

typedef PageBuilder = Widget Function(TypedSegment segment);

/// Flutter 2.0 [RouterDelegate] override
class RiverpodRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath> {
  RiverpodRouterDelegate(this._navigator, {required this.pageBuilder, required this.initPath});

  final TypedPath initPath;
  final RiverpodNavigator _navigator;
  final PageBuilder pageBuilder;

  @override
  TypedPath get currentConfiguration => _navigator.actualTypedPath;

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final typedPath = _navigator.actualTypedPath;
    if (typedPath.isEmpty) return SizedBox();
    return Navigator(
        key: navigatorKey,
        pages: [for (final segment in typedPath) MaterialPage(key: ValueKey(segment.key), child: pageBuilder(segment))],
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          return _navigator.pop(); // remove last segment from path
        });
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) async => _navigator.navigate(configuration);

  @override
  Future<void> setInitialRoutePath(TypedPath configuration) async => _navigator.navigate(initPath);

  @override
  // ignore: unnecessary_overrides
  void notifyListeners() => super.notifyListeners();
}

/// Wrap [PathParser] to [RouteInformationParser]. [RouteInformationParser] is required for [MaterialApp.router] constructor.
class RouteInformationParserImpl implements RouteInformationParser<TypedPath> {
  RouteInformationParserImpl(Json2Segment json2Segment) : _pathParser = PathParser(json2Segment);
  final PathParser _pathParser;
  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) => Future.value(_pathParser.path2TypedPath(routeInformation.location));
  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) => RouteInformation(location: _pathParser.typedPath2Path(configuration));
}
