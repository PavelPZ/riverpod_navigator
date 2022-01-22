import 'dart:convert';

import 'package:riverpod/riverpod.dart';

typedef JsonMap = Map<String, dynamic>;

abstract class TypedSegment {
  TypedSegment copy();
  JsonMap toJson();

  /// key for MaterialApp(key: ValueKey([TypedSegment.key]))
  String get key => _key ?? (_key = jsonEncode(this));
  String? _key;
}

typedef TypedPath = List<TypedSegment>;

class TypedPathNotifier extends StateController<TypedPath> {
  TypedPathNotifier({TypedPath? initPath}) : super(initPath ?? []);
}

final typedPathNotifierProvider = StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier());

class RiverpodNavigator {
  RiverpodNavigator(this.ref, {this.initPath});
  final Ref ref;
  final TypedPath? initPath;

  void navigate(TypedPath newTypedPath) => setNewTypedPath(newTypedPath);

  void setNewTypedPath(TypedPath newTypedPath) => ref.read(typedPathNotifierProvider.notifier).state = newTypedPath;

  TypedPath get actualTypedPath => ref.read(typedPathNotifierProvider);

  /*   common navigation agnostic actions     */
  bool pop() {
    if (actualTypedPath.length <= 1) return false;
    navigate([for (var i = 0; i < actualTypedPath.length - 1; i++) actualTypedPath[i]]);
    return true;
  }

  void push(TypedSegment segment) => navigate([...actualTypedPath, segment]);
}

typedef Json2Segment = TypedSegment Function(JsonMap jsonMap);

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
