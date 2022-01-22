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
final typedPathNotifierProvider = StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier());

/// Helper singleton
class RiverpodNavigator {
  RiverpodNavigator(this._ref);

  final Ref _ref;

  void navigate(TypedPath newTypedPath) => _ref.read(typedPathNotifierProvider.notifier).setNewTypedPath(newTypedPath);

  TypedPath get actualTypedPath => _ref.read(typedPathNotifierProvider);
  String get actualTypedPathAsString => actualTypedPath.map((s) => s.key).join(' / ');

  /* --- common navigation agnostic actions --- */
  bool pop() {
    if (actualTypedPath.length <= 1) return false;
    navigate([for (var i = 0; i < actualTypedPath.length - 1; i++) actualTypedPath[i]]);
    return true;
  }

  void push(TypedSegment segment) => navigate([...actualTypedPath, segment]);
}

typedef Json2Segment = TypedSegment Function(JsonMap jsonMap);

/// Simple Uri parser, just for demonstration or for non Flutter web apps.
class PathParser {
  PathParser(this.json2Segment);

  final Json2Segment json2Segment;

  String typedPath2Path(TypedPath typedPath) => typedPath.map((s) => Uri.encodeComponent(jsonEncode(s.toJson()))).join('/');

  TypedPath path2TypedPath(String? path) {
    if (path == null || path.isEmpty) return [];
    return [
      for (final s in path.split('/'))
        if (s.isNotEmpty) json2Segment(jsonDecode(Uri.decodeFull(s)))
    ];
  }
}
