import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app/app.dart';
import 'navigator.dart';
import 'widgets/widgets.dart';

class RiverpodRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath> {
  RiverpodRouterDelegate(this.ref, this._navigator);

  final RiverpodNavigator _navigator;
  final Ref ref;

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
        pages: actPath.map((segment) => MaterialPage(key: ValueKey(segment.asJson), child: screenBuilder(segment as ExampleSegments))).toList(),
        onPopPage: (route, result) {
          _navigator.onPopRoute();
          return false;
        });
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) async => _navigator.navigate(configuration);

  @override
  Future<void> setInitialRoutePath(TypedPath configuration) async => _navigator.navigate([HomeSegment()]);
}
