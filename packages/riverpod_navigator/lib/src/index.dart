import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';

part 'navigator.dart';
part 'routes.dart';
part 'routeDelegate.dart';
part 'widgets.dart';

// ********************************************
// Basic types
// ********************************************

typedef RiverpodNavigatorCreator = RNavigator Function(Ref);
typedef NavigatorWidgetBuilder = Widget Function(BuildContext, Navigator);
typedef ScreenBuilder<T extends TypedSegment> = Widget Function(T);
typedef SplashBuilder = Widget Function();
typedef Screen2Page<T extends TypedSegment> = Page Function(T, ScreenBuilder<T>);

extension RefEx on Ref {
  RNavigator get navigator => read(navigatorProvider) as RNavigator;
}

// extension WidgetRefEx on WidgetRef {
//   RNavigator get navigator => read(navigatorProvider) as RNavigator;
// }
