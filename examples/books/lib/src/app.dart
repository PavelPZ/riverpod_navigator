import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'provider.dart';

// flutter pub run build_runner watch
part 'app.g.dart';

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
