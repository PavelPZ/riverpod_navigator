import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tuple/tuple.dart';

part 'navigator.dart';
part 'pathParser.dart';
part 'providers.dart';
part 'routes.dart';
part 'routeDelegate.dart';
part 'screenWrappers.dart';

// ********************************************
// Basic types
// ********************************************

typedef JsonMap = Map<String, dynamic>;
typedef Json2Segment = TypedSegment Function(JsonMap, String unionKey);
typedef AsyncActionResult = dynamic;
typedef RiverpodNavigatorCreator = RiverpodNavigator Function(Ref);
typedef NavigatorWidgetBuilder = Widget Function(BuildContext, Navigator);
typedef ScreenBuilder<T extends TypedSegment> = Widget Function(T);
typedef SplashBuilder = Widget Function();
typedef Screen2Page<T extends TypedSegment> = Page Function(T, ScreenBuilder<T>);
typedef NavigatorDispose = void Function(RiverpodNavigator);

// ********************************************
// TypedSegment & TypedPath
// ********************************************

/// Abstract interface for typed variant of path's segment.
///
/// Instead of three-segment url path 'home/books/$bookId' we can use
/// e.g. navigate([Home(), Books(), Book(id: bookId)]);
abstract class TypedSegment {
  /// temporary field. Transmits result of async action to screen
  @JsonKey(ignore: true)
  AsyncActionResult asyncActionResult;
  JsonMap toJson();

  @override
  String toString() => _toString ?? (_toString = jsonEncode(toJson()));
  String? _toString;
}

/// Typed variant of whole url path (which consists of [TypedSegment]s)
typedef TypedPath = List<TypedSegment>;

// ********************************************
// RouterDelegate abstraction
// ********************************************

// RouterDelegate interface for both tests and flutter app
abstract class IRouterDelegate {
  RiverpodNavigator get navigator;
  void set navigator(RiverpodNavigator value);
  TypedPath get navigationStack;
  void set navigationStack(TypedPath value);
}

// RouterDelegate interface for tests
class RouterDelegate4Dart implements IRouterDelegate {
  @override
  late RiverpodNavigator navigator;
  @override
  TypedPath navigationStack = [];
}
// ********************************************
// RestorePath
// ********************************************

class RestorePath {
  RestorePath();
  TypedPath? path;
  void onPathChanged(TypedPath navigationStack) => path = navigationStack;
  TypedPath getInitialPath(TypedPath initPath) => path ?? initPath;
}
