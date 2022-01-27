import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screens.dart';

part 'lesson01.freezed.dart';
part 'lesson01.g.dart';

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

// *** 2. Dart-part of app configuration

final config4DartCreator = () => Config4Dart(json2Segment: (json, _) => AppSegments.fromJson(json));

// *** 3. app-specific navigator with navigation aware actions (used in screens)

const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref, Config4Dart config) : super(ref, config);

  void toHome() => navigate([HomeSegment()]);
  void toBooks() => navigate([HomeSegment(), BooksSegment()]);
  void toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  void bookNextPrevButton({bool? isPrev}) {
    assert(getActualTypedPath().last is BookSegment);
    var id = (getActualTypedPath().last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    toBook(id: id);
  }
}

// *** 4. providers

final appNavigatorProvider = Provider<AppNavigator>((ref) => AppNavigator(ref, ref.watch(config4DartProvider)));

/// Provider with Flutter 2.0 RouterDelegate
final appRouterDelegateProvider =
    Provider<RiverpodRouterDelegate>((ref) => RiverpodRouterDelegate(ref, ref.watch(configProvider), ref.watch(appNavigatorProvider)));

// *** 5. Flutter-part of app configuration

final configCreator = () => Config(
      /// Which widget will be builded for which [TypedSegment].
      /// Used in [RiverpodRouterDelegate] to build pages from [TypedSegment]'s
      screenBuilder: (segment) => (segment as AppSegments).map(
        home: (home) => HomeScreen(home),
        books: (books) => BooksScreen(books),
        book: (book) => BookScreen(book),
      ),

      /// specify home path of app
      initPath: [HomeSegment()],
    );

// *** 6. root widget for app

/// Using functional_widget package to be less verbose. Package generates "class BooksExampleApp extends ConsumerWidget...", see *.g.dart
@cwidget
Widget booksExampleApp(WidgetRef ref) => MaterialApp.router(
      title: 'Books App',
      routerDelegate: ref.watch(appRouterDelegateProvider),
      routeInformationParser: RouteInformationParserImpl(ref.watch(config4DartProvider)),
    );

// *** 7. app entry point with ProviderScope

void main() {
  runApp(ProviderScope(
    // initialize configs providers
    overrides: [
      config4DartProvider.overrideWithValue(config4DartCreator()),
      configProvider.overrideWithValue(configCreator()),
    ],
    child: const BooksExampleApp(),
  ));
}
