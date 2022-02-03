import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/widgets.dart';

void main() {
  runApp(ProviderScope(child: const AppRoot()));
}
