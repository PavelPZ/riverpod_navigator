import 'dart:async';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

typedef JsonMap = Map<String, dynamic>;

// ********************************************
//   riverpod StateNotifier and StateNotifierProvider
// ********************************************

/// Abstract interface for typed variant of path's segment.
///
/// Instead of three-segment url path 'home/books/$bookId' we can use
/// e.g. navigate([Home(), Books(), Book(id: bookId)]);
abstract class TypedSegment {
  JsonMap toJson();

  String get asJson => _asJson ?? (_asJson = jsonEncode(toJson()));
  String? _asJson;
}

/// Typed variant of whole url path (which could consists of three typed segments)
typedef TypedPath = List<TypedSegment>;

/// Riverpod StateNotifier notifying that actual typed path has changed
class TypedPathNotifier extends StateNotifier<TypedPath> {
  TypedPathNotifier() : super([]);

  /// change state, which is called typedPath
  set typedPath(TypedPath newTypedPath) => state = newTypedPath;
  TypedPath get typedPath => state;
}

/// Riverpod provider which provides [TypedPathNotifier] to whole app
final typedPathNotifierProvider = StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier());

// ********************************************
//   RiverpodNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
abstract class RiverpodNavigator {
  RiverpodNavigator(this.ref);

  Ref ref;

  /// Main navigator method provided navigating to new [TypedPath]
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

  // *** common navigation-agnostic app actions ***

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

// ********************************************
//   parser
// ********************************************

class PathParser {
  static const String defaultJsonUnionKey = 'runtimeType';

  String typedPath2Path(TypedPath typedPath) => typedPath.map((s) => Uri.encodeComponent(s.asJson/*=jsonEncode(s.toJson())*/)).join('/');

  String debugTypedPath2String(TypedPath typedPath) => typedPath.map((s) => s.asJson/*=jsonEncode(s.toJson())*/).join(' / ');

  TypedPath path2TypedPath(String? path) {
    if (path == null || path.isEmpty) return [];
    return [
      for (final s in path.split('/'))
        if (s.isNotEmpty) config4Dart.json2Segment(jsonDecode(Uri.decodeFull(s)), defaultJsonUnionKey)
    ];
  }
}

// ********************************************
//   configuration
// ********************************************

typedef Json2Segment = TypedSegment Function(JsonMap jsonMap, String unionKey);

/// navigation config (for dart-only part of code)
class Config4Dart {
  Config4Dart({
    required this.json2Segment,
    PathParser? pathParser,
  })  : assert(_value == null, 'Extension.init called multipple times'),
        pathParser = pathParser ?? PathParser() {
    _value = this;
  }

  /// String url path <==> [TypedPath] parser
  final PathParser pathParser;

  /// How to convert [TypedSegment] to json
  final Json2Segment json2Segment;
}

Config4Dart get config4Dart {
  assert(_value != null, 'Call Extension.init first!');
  return _value as Config4Dart;
}

/// config is static singleton
Config4Dart? _value;
