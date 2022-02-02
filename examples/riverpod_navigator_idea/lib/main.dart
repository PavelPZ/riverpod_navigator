import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator_idea/src/riverpod_navigator.dart';

import 'src/appDart/appDart.dart' show config4DartCreator;
import 'src/appFlutter/appFlutter.dart' show ExampleApp, configCreator;
import 'src/riverpod_navigator_dart.dart';

void main() {
  runApp(ProviderScope(
      // initialize configs providers
      overrides: [
        config4DartProvider.overrideWithValue(config4DartCreator()),
        configProvider.overrideWithValue(configCreator(config4DartCreator())),
      ], child: const ExampleApp()));
}
