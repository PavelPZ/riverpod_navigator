import 'package:books_dart/books_dart.dart';
import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'pages.dart';
import 'provider.dart';

// flutter pub run build_runner watch
part 'app.g.dart';

void configureEngineAndApp() {
  // configure engine
  Config(
    screenBuilder: screenBuilder,
    navigatorWidgetBuilder: null,
    screen2Page: null,
    initPath: [HomeSegment()],
    // 4Dart:
    pathParser: SimplePathParser(),
    json2Segment: json2Segment,
    segment2AsyncScreenActions: segment2AsyncScreenActions,
    // when using route
    // segment2AsyncScreenActions: segment2AsyncScreenActions4Routes,
  );
  // configure app
  // when using route
  // needsLoginProc4Dart = getNeedsLogin4Routes4Dart;
}

@hcwidget
Widget booksExampleApp(WidgetRef ref) {
  final navigator = ref.read(appNavigatorProvider);
  final delegate = RiverpodRouterDelegate(navigator);
  ref.listen(typedPathNotifierProvider, (_, __) => delegate.notifyListeners());

  return MaterialApp.router(
    title: 'Books App',
    routerDelegate: delegate,
    routeInformationParser: RouteInformationParserImpl(),
  );
}
