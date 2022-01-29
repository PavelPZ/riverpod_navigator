// *** 0. imports a part's

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screens.dart';

part 'lesson031.freezed.dart';
part 'lesson031.g.dart';

// *** 1. define typed segments

@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;
  factory AppSegments.splash() = SplashSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
}

// *** NEW 1.1 app-specific navigator with navigation aware actions.
// actions are then used in app widgets.

AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
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
        creating: (_) async => simulateAsyncResult('Home creating async result after 1 sec', 2000)),
    orElse: () => null,
  );
}

// *** MODIFIED 2. Configure dart-part of app

final config4DartCreator = () => Config4Dart(
      json2Segment: (json, _) => AppSegments.fromJson(json),
      segment2AsyncScreenActions: segment2AsyncScreenActions,
      initPath: [HomeSegment()],
      splashPath: [SplashSegment()],
      riverpodNavigatorCreator: (ref) => AppNavigator(ref),
      routerDelegateCreator: (ref) => RiverpodRouterDelegate(ref),
    );

// *** 3. app specific navigator with navigation aware actions for app screens

const booksLen = 5;

class AppNavigator extends AsyncRiverpodNavigator {
  AppNavigator(Ref ref) : super(ref);

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

// *** 4. WidgetRef extension

extension ReadNavigator on WidgetRef {
  AppNavigator readNavigator() => read(riverpodNavigatorProvider) as AppNavigator;
}

// *** 5. Configure flutter-part of app

final configCreator = (Config4Dart config4Dart) => Config(
      /// Which widget will be builded for which [TypedSegment].
      /// Used in [RiverpodRouterDelegate] to build pages from [TypedSegment]'s
      screenBuilder: (segment) => (segment as AppSegments).map(
        home: (s) => HomeScreen(s),
        books: (s) => BooksScreen(s),
        book: (s) => BookScreen(s),
        splash: (s) => SplashScreen(s),
      ),
      config4Dart: config4Dart,
    );

// *** 6. root widget for app
// Using functional_widget package to be less verbose. Package generates ConsumerWidget's code, see *.g.dart

@cwidget
Widget booksExampleApp(WidgetRef ref) => MaterialApp.router(
      title: 'Books App',
      routerDelegate: ref.watch(routerDelegateProvider) as RiverpodRouterDelegate,
      routeInformationParser: RouteInformationParserImpl(ref),
    );

// *** 7. app entry point with ProviderScope

void main() {
  runApp(ProviderScope(
    // initialize configs providers
    overrides: [
      config4DartProvider.overrideWithValue(config4DartCreator()),
      configProvider.overrideWithValue(configCreator(config4DartCreator())),
    ],
    child: const BooksExampleApp(),
  ));
}
