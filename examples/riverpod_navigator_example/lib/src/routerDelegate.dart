import 'dart:async';

import 'package:flutter/material.dart';

import 'navigator.dart';
import 'widgets.dart';

class RRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath> {
  RRouterDelegate();

  RNavigator? navigator;
  RNavigator get _navigator => navigator as RNavigator;

  @override
  TypedPath currentConfiguration = [];

  TypedPath get navigationStack => currentConfiguration;

  void set navigationStack(TypedPath path) {
    currentConfiguration = path;
    notifyListeners();
  }

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    if (navigationStack.isEmpty) return SizedBox();

    final screenBuilder = (Segments segment) => segment.map(
          home: (homeSegment) => HomeScreen(homeSegment),
          books: (booksSegment) => BooksScreen(booksSegment),
          book: (bookSegment) => BookScreen(bookSegment),
        );
    return Navigator(
        key: navigatorKey,
        pages: navigationStack.map((segment) => MaterialPage(key: ValueKey(segment.toString), child: screenBuilder(segment))).toList(),
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          // remove last segment from path
          return _navigator.onPopRoute();
        });
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) async => _navigator.navigate(configuration);

  @override
  Future<void> setInitialRoutePath(TypedPath configuration) async => _navigator.navigate([HomeSegment()]);
}
