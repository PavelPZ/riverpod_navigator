import 'dart:async';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

typedef JsonMap = Map<String, dynamic>;

/// Typed variant of Uri path segment
abstract class TypedSegment {
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
  RiverpodNavigator(this.ref);

  Ref ref;

  Future<void> navigate(TypedPath newTypedPath) async => setActualTypedPath(newTypedPath);

  TypedPathNotifier getPathNotifier() => ref.read(typedPathNotifierProvider.notifier);

  TypedPath getActualTypedPath() => getPathNotifier().typedPath;
  void setActualTypedPath(TypedPath value) => getPathNotifier().typedPath = value;

  String debugTypedPath2String() => config4Dart.pathParser.debugTypedPath2String(getActualTypedPath());

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

/* ******************************************** */
/*   parser                              */
/* ******************************************** */

class PathParser {
  static const String defaultJsonUnionKey = 'runtimeType';

  String typedPath2Path(TypedPath typedPath) => typedPath.map((s) => Uri.encodeComponent(s.key/*=jsonEncode(s.toJson())*/)).join('/');

  String debugTypedPath2String(TypedPath typedPath) => typedPath.map((s) => s.key/*=jsonEncode(s.toJson())*/).join(' / ');

  TypedPath path2TypedPath(String? path) {
    if (path == null || path.isEmpty) return [];
    return [
      for (final s in path.split('/'))
        if (s.isNotEmpty) config4Dart.json2Segment(jsonDecode(Uri.decodeFull(s)), defaultJsonUnionKey)
    ];
  }
}

/* ******************************************** */
/*   configuration                              */
/* ******************************************** */

typedef Json2Segment = TypedSegment Function(JsonMap jsonMap, String unionKey);

// @IFNDEF riverpod_navigator_idea
typedef Creating<T extends TypedSegment> = Future? Function(T newPath);
typedef Merging<T extends TypedSegment> = Future? Function(T oldPath, T newPath);
typedef Deactivating<T extends TypedSegment> = Future? Function(T oldPath);

class AsyncScreenActions<T extends TypedSegment> {
  AsyncScreenActions({this.creating, this.merging, this.deactivating});
  final Creating<T>? creating;
  final Merging<T>? merging;
  final Deactivating<T>? deactivating;

  Future? callCreating(TypedSegment newPath) => creating != null ? creating?.call(newPath as T) : null;
  Future? callMerging(TypedSegment oldPath, TypedSegment newPath) => merging != null ? merging?.call(oldPath as T, newPath as T) : null;
  Future? callDeactivating(TypedSegment oldPath) => creating != null ? deactivating?.call(oldPath as T) : null;
}

typedef Segment2AsyncScreenActions = AsyncScreenActions? Function(TypedSegment segment);
// @ENDIF riverpod_navigator_idea

class Config4Dart {
  Config4Dart({
    required this.json2Segment,
    PathParser? pathParser,
    this.segment2AsyncScreenActions,
  })  : assert(_value == null, 'Extension.init called multipple times'),
        pathParser = pathParser ?? PathParser() {
    _value = this;
  }

  final PathParser pathParser;
  final Json2Segment json2Segment;
  final Segment2AsyncScreenActions? segment2AsyncScreenActions;
}

Config4Dart get config4Dart {
  assert(_value != null, 'Call Extension.init first!');
  return _value as Config4Dart;
}

Config4Dart? _value;
