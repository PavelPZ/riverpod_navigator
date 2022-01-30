import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'dart-lesson02.dart';
import 'screens.dart';

part 'flutter-lesson02.g.dart';

// *** 5. Flutter-part of app configuration

final configCreator = (Config4Dart config4Dart) => Config(
      /// Which widget will be builded for which [TypedSegment].
      /// Used in [RiverpodRouterDelegate] to build pages from [TypedSegment]'s
      screenBuilder: (segment) => (segment as AppSegments).map(
        home: (home) => HomeScreen(home),
        books: (books) => BooksScreen(books),
        book: (book) => BookScreen(book),
      ),
      config4Dart: config4Dart,
    );

// *** 6. root widget for app

/// Using functional_widget package to be less verbose. Package generates "class BooksExampleApp extends ConsumerWidget...", see *.g.dart
@cwidget
Widget booksExampleApp(WidgetRef ref) => MaterialApp.router(
      title: 'Books App',
      routerDelegate: ref.read(routerDelegateProvider) as RiverpodRouterDelegate,
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
