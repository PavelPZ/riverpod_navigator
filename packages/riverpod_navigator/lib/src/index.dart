import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:tuple/tuple.dart';

part 'navigator.dart';
part 'pathParser.dart';
part 'routes.dart';
part 'routeDelegate.dart';
part 'screenWrappers.dart';

// ********************************************
// Basic types
// ********************************************

typedef Json2Segment = TypedSegment Function(JsonMap, String unionKey);
typedef RiverpodNavigatorCreator = RNavigator Function(Ref);
typedef NavigatorWidgetBuilder = Widget Function(BuildContext, Navigator);
typedef ScreenBuilder<T extends TypedSegment> = Widget Function(T);
typedef SplashBuilder = Widget Function();
typedef Screen2Page<T extends TypedSegment> = Page Function(T, ScreenBuilder<T>);
typedef NavigatorDispose = void Function(RNavigator);

// ********************************************
// RouterDelegate abstraction
// ********************************************

// RouterDelegate interface for both tests and flutter app
abstract class IRouterDelegate {
  RNavigator get navigator;
  void set navigator(RNavigator value);
  void notifyListeners();
}

// RouterDelegate interface for tests
class RouterDelegate4Dart implements IRouterDelegate {
  @override
  late RNavigator navigator;
  @override
  void notifyListeners() {}
}

extension RefEx on Ref {
  RNavigator get navigator => read(riverpodNavigatorProvider) as RNavigator;
}

extension WidgetRefEx on WidgetRef {
  RNavigator get navigator => read(riverpodNavigatorProvider) as RNavigator;
}
