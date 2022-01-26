import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'configAndProviders.dart';

// flutter pub run build_runner watch
part 'app.g.dart';

@hcwidget
Widget booksExampleApp(WidgetRef ref) => MaterialApp.router(
      title: 'Books App',
      routerDelegate: ref.watch(appRouterDelegateProvider),
      routeInformationParser: RouteInformationParserImpl(ref.watch(config4DartProvider)),
    );
