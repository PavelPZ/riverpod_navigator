import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'dart_lesson03.dart';
import 'screens.dart';

part 'flutter_lesson03.g.dart';

// *** 3. Navigator creator for flutter

AppNavigator appNavigatorCreator(Ref ref) => AppNavigator(ref)
  ..flutterInit(
    screenBuilder: appSegmentsScreenBuilder,
  );

// *** 4. Root app widget and entry point

/// Root app widget
/// 
/// To make it less verbose, we use the functional_widget package to generate widgets.
/// See .g.dart file for details.
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

