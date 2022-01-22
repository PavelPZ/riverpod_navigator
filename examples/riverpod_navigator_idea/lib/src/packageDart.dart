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

/// App navigation is driven by this StateNavigator
///
///
class TypedPathNotifier extends StateNotifier<TypedPath> {
  TypedPathNotifier() : super([]);
  void setNewTypedPath(TypedPath newTypedPath) => state = newTypedPath;
}

/// Will provided TypedPathNotifier to whole app
final typedPathNotifierProvider = StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier());

typedef ListenByChangeNotifier = void Function(Function notifyListener);

///
class RiverpodNavigator {
  RiverpodNavigator(this._ref, {this.initPath});

  final Ref _ref;
  final TypedPath? initPath;

  void navigate(TypedPath newTypedPath) => _ref.read(typedPathNotifierProvider.notifier).setNewTypedPath(newTypedPath);

  TypedPath get actualTypedPath => _ref.read(typedPathNotifierProvider);
  String get actualTypedPathAsString => actualTypedPath.map((s) => s.key).join(' / ');

  /// for connectiong to RouterDelegate
  void listenByChangeNotifier(Function notifyListeners) => _ref.listen(typedPathNotifierProvider, (_, __) => notifyListeners());

  /* --- common navigation agnostic actions --- */
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
