import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

import 'route.dart';

typedef NavigatorWidgetBuilder = Widget Function(BuildContext, Navigator);

class RiverpodRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath> {
  RiverpodRouterDelegate(this._navigator, {required this.initPath, this.navigatorWidgetBuilder});

  final NavigatorWidgetBuilder? navigatorWidgetBuilder;
  final TypedPath initPath;
  final INavigator _navigator;

  @override
  TypedPath get currentConfiguration => _navigator.actualTypedPath;

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // final navigator = _ref.read(_navigatorProvider.notifier);
    final typedPath = _navigator.actualTypedPath;
    if (typedPath.isEmpty) return SizedBox();
    final navigatorWidget = Navigator(
        key: navigatorKey,
        // segment => route => route.build(segment)
        pages: typedPath.map((segment) {
          final route = _navigator.getRouteWithSegment(segment).route as NavigRoute;
          return MaterialPage(key: ValueKey(segment.key), child: route.buildPage(segment));
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
