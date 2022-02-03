import 'dart:async';

import 'package:flutter/material.dart';

import 'navigator.dart';
import 'widgets.dart';

class RiverpodRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath> {
  RiverpodRouterDelegate();

  RiverpodNavigatorLow? navigator;

  // make [notifyListeners] public
  void doNotifyListener() => notifyListeners();

  @override
  TypedPath currentConfiguration = [];

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final actPath = currentConfiguration;
    if (actPath.isEmpty) return SizedBox();

    final screenBuilder = (ExampleSegments segment) => segment.map(
          home: (homeSegment) => HomeScreen(homeSegment),
          books: (booksSegment) => BooksScreen(booksSegment),
          book: (bookSegment) => BookScreen(bookSegment),
        );
    return Navigator(
        key: navigatorKey,
        pages: actPath.map((segment) => MaterialPage(key: ValueKey(segment.toString), child: screenBuilder(segment))).toList(),
        onPopPage: (route, result) {
          navigator?.onPopRoute();
          return false;
        });
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) async => navigator?.navigate(configuration);

  @override
  Future<void> setInitialRoutePath(TypedPath configuration) async => navigator?.navigate([HomeSegment()]);
}
