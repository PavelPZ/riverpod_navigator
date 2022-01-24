import 'dart:async';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

import 'extensions/extensions.dart';
import 'route.dart';

typedef JsonMap = Map<String, dynamic>;

/// Typed variant of Uri path segment
abstract class TypedSegment {
  TypedSegment copy();
  JsonMap toJson();

  /// key for MaterialApp(key: ValueKey([TypedSegment.key]))
  String get key => _key ?? (_key = jsonEncode(toJson()));
  String? _key;
}

/// Typed variant of Uri path
typedef TypedPath = List<TypedSegment>;

/// Notifies Navigator 2.0 [RiverpodRouterDelegate] when to change navigation stack
class TypedPathNotifier extends StateNotifier<TypedPath> {
  TypedPathNotifier() : super([]);

  /// change state, which is called typedPath
  set typedPath(TypedPath newTypedPath) => state = newTypedPath;
  TypedPath get typedPath => state;
}

/// Will provided [TypedPathNotifier] to whole app
final typedPathNotifierProvider = StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier());

abstract class RiverpodNavigator {
  RiverpodNavigator(this.ref, this.getRouteWithSegment);
  final GetRoute4Segment getRouteWithSegment;
  Ref ref;

  Future<void> navigate(TypedPath newTypedPath) async => setActualTypedPath(newTypedPath);

  TypedPathNotifier getPathNotifier() => ref.read(typedPathNotifierProvider.notifier);
  TypedPath getActualTypedPath() => getPathNotifier().typedPath;
  String getActualTypedPathAsString() => getActualTypedPath().map((s) => s.key).join(' / ');
  void setActualTypedPath(TypedPath value) => getPathNotifier().typedPath = value;

  /// for [Navigator.onPopPage] in [RiverpodRouterDelegate.build]
  bool onPopRoute() {
    final actPath = getActualTypedPath();
    if (actPath.length <= 1) return false;
    unawaited(navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]));
    return true;
  }

  /* ******************************************** */
  /*   common navigation-agnostic app actions     */
  /* ******************************************** */

  Future<bool> pop() async {
    final actPath = getActualTypedPath();
    if (actPath.length <= 1) return false;
    await navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
    return true;
  }

  Future<void> push(TypedSegment segment) => navigate([...getActualTypedPath(), segment]);

  Future<void> replaceLast(TypedSegment segment) {
    final actPath = getActualTypedPath();
    return navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i], segment]);
  }
}

mixin PathParserExtension {
  PathParser pathParser = PathParser();
}

class PathParser {
  static const String defaultJsonUnionKey = 'runtimeType';

  String typedPath2Path(TypedPath typedPath) => typedPath.map((s) => Uri.encodeComponent(s.key/*=jsonEncode(s.toJson())*/)).join('/');

  TypedPath path2TypedPath(String? path) {
    if (path == null || path.isEmpty) return [];
    return [
      for (final s in path.split('/'))
        if (s.isNotEmpty) config4Dart.json2Segment(jsonDecode(Uri.decodeFull(s)), defaultJsonUnionKey)
    ];
  }
}
