import 'dart:async';

import 'package:flutter/material.dart';
// import 'riverpod_navigator_dart.dart';
import 'package:riverpod_navigator/riverpod_navigator_dart.dart';

part 'routeDelegate.dart';
part 'navigator.dart';
part 'screenWrappers.dart';

typedef NavigatorWidgetBuilder = Widget Function(BuildContext, Navigator);
typedef ScreenBuilder = Widget Function(TypedSegment segment);
typedef SplashBuilder = Widget Function();
typedef Screen2Page = Page Function(TypedSegment segment, ScreenBuilder screenBuilder);
final Screen2Page screen2PageDefault = (segment, screenBuilder) => _Screen2PageDefault(segment, screenBuilder);

abstract class RouteFlutter<T extends TypedSegment> {
  Widget screenBuilder(T segment);
  Screen2Page? screen2Page;
}

// /// flutter extension for RiverpodNavigator
// extension RiverpodNavigatorEx on RiverpodNavigator {
//   void flutterInit({
//     required ScreenBuilder screenBuilder,
//     Screen2Page? screen2Page,
//     NavigatorWidgetBuilder? navigatorWidgetBuilder,
//     SplashBuilder? splashBuilder,
//   }) {
//     routerDelegate = RiverpodRouterDelegate()..navigator = this;
//     flutterConfig = RiverpodNavigatorFlutter(this,
//         screenBuilder: screenBuilder, screen2Page: screen2Page, navigatorWidgetBuilder: navigatorWidgetBuilder, splashBuilder: splashBuilder);
//   }

//   RiverpodNavigatorFlutter get flutter => flutterConfig as RiverpodNavigatorFlutter;
// }

// /// flutter extension for TypedRoute
// extension TypedRouteEx<T extends TypedSegment> on TypedRoute<T> {
//   void flutterInit({required ScreenBuilder screenBuilder, Screen2Page? screen2Page}) {
//     flutterConfig = FlutterRoute<T>(screenBuilder: screenBuilder, screen2Page: screen2Page);
//   }
// }

// mixin TypedRouteMixin<T extends TypedSegment> on TypedRoute<T> {
//   Widget screenBuilder(T segment);
//   Page screen2Page(T segment, ScreenBuilder screenBuilder) => _Screen2PageDefault(segment, screenBuilder);
// }

