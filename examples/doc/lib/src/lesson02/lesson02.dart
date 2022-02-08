// ignore: unused_import
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screens.dart';

part 'lesson02.freezed.dart';
part 'lesson02.g.dart';



// *************************************
// Lesson02
// Lesson02 is [lesson01](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson01.md) enhanced with:
// 
// - asynchronous navigation when screens require some asynchronous actions (when creating, deactivating, or merging)
// - the splash screen appears before the HomeScreen is displayed
// 
// 
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

// *** 1.1. async screen actions

/// Each screen may require an asynchronous action during its creating, merging, or deactivating.
/// The asynchronous result is then provided to the screen widget.
AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
  // 
  /// helper for simulating asynchronous action. Its result is then provided to the screen widget.
  Future<String> simulateAsyncResult(String asyncResult, int msec) async {
    await Future.delayed(Duration(milliseconds: msec));
    return asyncResult;
  }

  if (segment is! AppSegments) return null;

  return segment.maybeMap(
    book: (_) => AsyncScreenActions<BookSegment>(
      // for every Book screen: creating takes some time
      creating: (newSegment) => simulateAsyncResult('Book.creating: async result after 700 msec', 700),
      // for every Book screen with odd id: changing to another Book screen takes some time
      merging: (oldSegment, newSegment) => newSegment.id.isOdd ? simulateAsyncResult('Book.merging: async result after 500 msec', 500) : null,
      // for every Book screen with even id: deactivating takes some time
      deactivating: (oldSegment) => oldSegment.id.isEven ? Future.delayed(Duration(milliseconds: 500)) : null,
    ),
    home: (_) => AsyncScreenActions<HomeSegment>(
      creating: (_) async => simulateAsyncResult('Home.creating: async result after 1000 msec', 1000),
    ),
    orElse: () => null,
  );
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
          initPath: [HomeSegment()],
          json2Segment: (jsonMap, _) => AppSegments.fromJson(jsonMap),
          screenBuilder: appSegmentsScreenBuilder,
          // new for this example: asynchronous screen actions
          segment2AsyncScreenActions: segment2AsyncScreenActions,
          // new for this example: splash screen that appears before the home page is created
          splashBuilder: SplashScreen.new,
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
/// See generated "lesson??.g.dart"" file for details.*
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

/// app entry point with ProviderScope's override
void runMain() => runApp(
    ProviderScope(
      overrides: [
        riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new /*See Constructor tear-offs in Dart ^2.15*/),
      ],
      child: const BooksExampleApp(),
    ),
  );

