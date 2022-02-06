// ignore: unused_import
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screens.dart';

part 'lesson05.freezed.dart';
part 'lesson05.g.dart';

// *************************************
// Example05
// *************************************
// 
// *** 1. classes for typed path segments (TypedSegment)

// Terminology:
// - string path:
// ```
// final stringPath = 'home/books/book;id=2';
// ```
// - the string path consists of three string segments: 'home', 'books', 'book;id=2'
// - typed path:
// ```
// final typedPath = <ExampleSegments>[HomeSegment(), BooksSegment(), BookSegment(id:2)];
// ```
// - the typed path consists of three typed segments: HomeSegment(), BooksSegment(), BookSegment(id:2)
// ---------------------
// From the following definition, [Freezed](https://github.com/rrousselGit/freezed) generates three typed segment classes,
// HomeSegment, BooksSegment and BookSegment.
// 
// See [Freezed](https://github.com/rrousselGit/freezed) for details.
@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
}

// *** 2. Specify navigation-aware actions in the navigator. The actions are then used in the screen widgets.

const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          json2Segment: (jsonMap, _) => AppSegments.fromJson(jsonMap),
          screenBuilder: appSegmentsScreenBuilder,
        );

  Future<void> toHome() => navigate([HomeSegment()]);
  Future<void> toBooks() => navigate([HomeSegment(), BooksSegment()]);
  Future<void> toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  Future<void> bookNextPrevButton({bool? isPrev}) {
    assert(currentTypedPath.last is BookSegment);
    var id = (currentTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    return toBook(id: id);
  }
}

// *** 3. Root widget and entry point (same for all examples)

// Root app widget
// 
// To make it less verbose, we use the functional_widget package to generate widgets.
// See *.g.dart file for details.
@cwidget
Widget booksExampleApp(WidgetRef ref) {
  final navigator = ref.read(riverpodNavigatorProvider);
  return MaterialApp.router(
    title: 'Books App',
    routerDelegate: navigator.routerDelegate as RiverpodRouterDelegate,
    routeInformationParser: RouteInformationParserImpl(navigator.pathParser),
    debugShowCheckedModeBanner: false,
  );
}

/// app entry point with ProviderScope  
void runMain() => runApp(
    ProviderScope(
      overrides: [
        riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new),
      ],
      child: const BooksExampleApp(),
    ),
  );

