// ignore: unused_import
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screens.dart';

part 'lesson01.freezed.dart';
part 'lesson01.g.dart';



// *************************************
// Lesson01
// *************************************

// *** 1. define classes for typed-segments (aka TypedSegment)

/// From the following AppSegments class declaration, the [freezed package](https://github.com/rrousselGit/freezed) 
/// generates three typed-segment classes: *HomeSegment, BooksSegment and BookSegment*.
@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
}

// *** 2. Type App-specific navigator (aka AppNavigator)

/// AppNavigator is a singleton class that does the following:
/// - configures various navigation parameters 
/// - contains actions related to navigation. The actions are then used in the screen widgets.


// *** 2.1. Navigation parameters

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          // home (initial) navigation path
          initPath: [HomeSegment()],
          // how to decode JSON to TypedSegment
          json2Segment: (jsonMap, _) => AppSegments.fromJson(jsonMap),
          // map TypedSegment's to navigation-stack Screens
          screenBuilder: appSegmentsScreenBuilder,
        );

// *** 2.2. Common navigation actions

//
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

const booksLen = 5;
// *** 3. Root widget

/// Note: *To make it less verbose, we use the functional_widget package to generate widgets.
/// See generated "lesson0?.g.dart"" file for details.*
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

// *** 4. App entry point

/// app entry point with ProviderScope.overrides
void runMain() => runApp(
    ProviderScope(
      overrides: [
        riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new /*See Constructor tear-offs in Dart ^2.15*/),
      ],
      child: const BooksExampleApp(),
    ),
  );

