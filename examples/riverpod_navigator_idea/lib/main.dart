import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/appFlutter/appFlutter.dart';

void main() {
  runApp(ProviderScope(child: const ExampleApp()));
}
