import 'package:riverpod/riverpod.dart';
import 'model.dart';

/// Will provided [TypedPathNotifier] to whole app
final typedPathNotifierProvider = StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier());
