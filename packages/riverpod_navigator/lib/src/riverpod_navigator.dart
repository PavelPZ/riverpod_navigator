import 'dart:async';

import 'package:flutter/material.dart';
// import 'riverpod_navigator_dart.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

typedef NavigatorWidgetBuilder = Widget Function(BuildContext, Navigator);
typedef ScreenBuilder = Widget Function(TypedSegment segment);
typedef SplashBuilder = Widget Function();

//final riverpodRouterDelegate = Provider<RiverpodRouterDelegate>((_) => throw UnimplementedError());

class RiverpodRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath>, IRouterDelegate {
  RiverpodRouterDelegate();

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // final actPath = _navigator.getActualTypedPath();
    final actPath = currentConfiguration;
    if (actPath.isEmpty) return navigator.flutter.splashBuilder?.call() ?? SizedBox();
    final navigatorWidget = Navigator(
        key: navigatorKey,
        // segment => screen
        pages: actPath.map((segment) => navigator.flutter.screen2Page(segment, navigator.flutter.screenBuilder)).toList(),
        onPopPage: (route, result) {
          //if (!route.didPop(result)) return false;
          // remove last segment from path
          navigator.onPopRoute();
          return false;
        });
    return navigator.flutter.navigatorWidgetBuilder == null ? navigatorWidget : navigator.flutter.navigatorWidgetBuilder!(context, navigatorWidget);
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

typedef Screen2Page = Page Function(TypedSegment segment, ScreenBuilder screenBuilder);

class FlutterConfig {
  FlutterConfig({
    required this.screenBuilder,
    Screen2Page? screen2Page,
    this.navigatorWidgetBuilder,
    this.splashBuilder,
  }) : screen2Page = screen2Page ?? screen2PageDefault;
  final Screen2Page screen2Page;
  final ScreenBuilder screenBuilder;
  final NavigatorWidgetBuilder? navigatorWidgetBuilder;
  final SplashBuilder? splashBuilder;
}

extension RiverpodNavigatorEx on RiverpodNavigator {
  void flutterInit({
    required ScreenBuilder screenBuilder,
    Screen2Page? screen2Page,
    NavigatorWidgetBuilder? navigatorWidgetBuilder,
    SplashBuilder? splashBuilder,
  }) {
    routerDelegate = RiverpodRouterDelegate();
    flutterConfig = FlutterConfig(
        screenBuilder: screenBuilder, screen2Page: screen2Page, navigatorWidgetBuilder: navigatorWidgetBuilder, splashBuilder: splashBuilder);
  }

  FlutterConfig get flutter => flutterConfig as FlutterConfig;
}

final Screen2Page screen2PageDefault = (segment, screenBuilder) => _Screen2PageDefault(segment, screenBuilder);

class _Screen2PageDefault extends Page {
  _Screen2PageDefault(this._typedSegment, this._screenBuilder) : super(key: ValueKey(_typedSegment.toString()));

  final TypedSegment _typedSegment;
  final ScreenBuilder _screenBuilder;

  @override
  Route createRoute(BuildContext context) {
    // this line solved https://github.com/PavelPZ/riverpod_navigator/issues/2
    // https://github.com/flutter/flutter/issues/11655#issuecomment-469221502
    final child = _screenBuilder(_typedSegment);
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => child,
    );
  }
}
