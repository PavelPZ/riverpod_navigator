import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'examples.dart' show BooksExampleApp;

void main() {
  runApp(ProviderScope(child: const BooksExampleApp()));
}
