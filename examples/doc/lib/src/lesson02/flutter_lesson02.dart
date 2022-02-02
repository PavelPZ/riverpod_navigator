import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'dart_lesson02.dart';
import 'screens.dart';

part 'flutter_lesson02.g.dart';

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

