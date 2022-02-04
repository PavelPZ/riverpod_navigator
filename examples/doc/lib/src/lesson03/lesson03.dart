// ignore: unused_import
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screens.dart';

part 'lesson03.freezed.dart';
part 'lesson03.g.dart';

// *** 1. classes for typed path segments (TypedSegment)

/// The Freezed package generates three immutable classes used for writing typed navigation path,
/// e.g TypedPath path = [HomeSegment (), BooksSegment () and BookSegment (id: 3)]
@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
}

final Json2Segment json2AppSegments = (json, _) => AppSegments.fromJson(json);

// *** 1.1. async screen actions

AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
  // simulate helper
  Future<String> simulateAsyncResult(String title, int msec) async {
    await Future.delayed(Duration(milliseconds: msec));
    return title;
  }

  return (segment as AppSegments).maybeMap(
    book: (_) => AsyncScreenActions<BookSegment>(
      // for every Book screen: creating takes some time
      creating: (newSegment) async => simulateAsyncResult('Book creating async result after 1 sec', 1000),
      // for every Book screen with odd id: changing to another Book screen takes some time
      merging: (_, newSegment) async => newSegment.id.isOdd ? simulateAsyncResult('Book merging async result after 500 msec', 500) : null,
      // for every Book screen with even id: creating takes some time
      deactivating: (oldSegment) => oldSegment.id.isEven ? Future.delayed(Duration(milliseconds: 500)) : null,
    ),
    home: (_) => AsyncScreenActions<HomeSegment>(
        // Home screen takes some timefor creating
        creating: (_) async => simulateAsyncResult('Home creating async result after 1 sec', 1000)),
    orElse: () => null,
  );
}

// *** 2. App-specific navigator with navigation aware actions (used in screens)

const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref) : super(ref);

  void toHome() => navigate([HomeSegment()]);
  void toBooks() => navigate([HomeSegment(), BooksSegment()]);
  void toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  void bookNextPrevButton({bool? isPrev}) {
    assert(currentTypedPath.last is BookSegment);
    var id = (currentTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    toBook(id: id);
  }
}

/// provide a correctly typed navigator for tests
extension ReadNavigator on ProviderContainer {
  AppNavigator readNavigator() => read(riverpodNavigatorProvider) as AppNavigator;
}

// *** 3. Dart-part of app configuration

final config4DartCreator = () => Config4Dart(
      initPath: [HomeSegment()],
      json2Segment: json2AppSegments,
      riverpodNavigatorCreator: (ref) => AppNavigator(ref),
    );

// *** 4. Flutter-part of app configuration

final configCreator = (Config4Dart config4Dart) => Config(
      /// Which widget will be builded for which [TypedSegment].
      /// Used in [RiverpodRouterDelegate] to build pages from [TypedSegment]'s
      screenBuilder: screenBuilderAppSegments,
      config4Dart: config4Dart,
    );

// *** 5. root widget for app

/// Using functional_widget package to be less verbose. Package generates "class BooksExampleApp extends ConsumerWidget...", see *.g.dart
@cwidget
Widget booksExampleApp(WidgetRef ref) => MaterialApp.router(
      title: 'Books App',
      routerDelegate: ref.read(riverpodNavigatorProvider).routerDelegate as RiverpodRouterDelegate,
      routeInformationParser: RouteInformationParserImpl(ref),
    );

// *** 6. app entry point with ProviderScope

void runMain() {
  final config = configCreator(config4DartCreator());
  runApp(ProviderScope(
    // initialize configs providers
    overrides: [
      config4DartProvider.overrideWithValue(config.config4Dart),
      configProvider.overrideWithValue(config),
    ],
    child: const BooksExampleApp(),
  ));
}
