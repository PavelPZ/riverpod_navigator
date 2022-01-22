import 'package:riverpod/riverpod.dart';
import 'model.dart';

final typedPathNotifierProvider = StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier());
