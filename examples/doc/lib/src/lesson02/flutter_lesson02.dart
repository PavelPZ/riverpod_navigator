import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'dart_lesson02.dart';
import 'screens.dart';

part 'flutter_lesson02.g.dart';

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

