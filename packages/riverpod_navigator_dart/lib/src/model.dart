import 'dart:convert';

import 'package:riverpod/riverpod.dart';

typedef JsonMap = Map<String, dynamic>;

/// Typed variant of Uri path segment
abstract class TypedSegment {
  TypedSegment copy();
  JsonMap toJson();

  /// key for MaterialApp(key: ValueKey([TypedSegment.key]))
  String get key => _key ?? (_key = jsonEncode(this));
  String? _key;
}

/// Typed variant of Uri path
typedef TypedPath = List<TypedSegment>;

/// Notifies Navigator 2.0 [RiverpodRouterDelegate] when to change navigation stack
class TypedPathNotifier extends StateNotifier<TypedPath> {
  TypedPathNotifier() : super([]);

  /// change state
  void setNewTypedPath(TypedPath newTypedPath) => state = newTypedPath;
}

/// Will provided [TypedPathNotifier] to whole app
//final typedPathNotifierProvider = StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier());
