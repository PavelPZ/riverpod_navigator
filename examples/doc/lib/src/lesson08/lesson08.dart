// ignore: unused_import
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screens.dart';

part 'lesson08.freezed.dart';
part 'lesson08.g.dart';

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

/// create segment from JSON map
TypedSegment json2Segment(JsonMap jsonMap, String unionKey) => AppSegments.fromJson(jsonMap);

// *** 2. App-specific navigator with navigation aware actions (used in screens)

const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref, {Object? flutterConfig, IRouterDelegate? routerDelegate})
      : super(ref, initPath: [HomeSegment()], json2Segment: json2Segment, flutterConfig: flutterConfig, routerDelegate: routerDelegate);

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

// *** 3. Navigator configuration for flutter

AppNavigator appNavigatorCreator(Ref ref) =>
    AppNavigator(ref, routerDelegate: RiverpodRouterDelegate(), flutterConfig: FlutterConfig(screenBuilder: appSegmentsScreenBuilder));

// *** 4. Root app widget and entry point with ProviderScope

/// Root app widget
/// Using functional_widget package to be less verbose. Package generates "class BooksExampleApp extends ConsumerWidget...", see *.g.dart
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
        riverpodNavigatorCreatorProvider.overrideWithValue(appNavigatorCreator),
      ],
      child: const BooksExampleApp(),
    ),
  );

