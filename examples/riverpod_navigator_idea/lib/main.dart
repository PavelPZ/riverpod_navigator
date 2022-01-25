import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/appFlutter/appFlutter.dart' show ExampleApp, configure;

void main() {
  configure();
  runApp(ProviderScope(child: const ExampleApp()));
}
