import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

import 'navigator.dart';

final userIsLoggedProvider = StateProvider<bool>((_) => false);

final appNavigatorProvider4Dart = Provider<AppNavigator>((ref) {
  final cfg = ref.read(config4DartProvider);
  return AppNavigator(ref, cfg);
});
