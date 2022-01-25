import 'dart:async';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

import '../riverpod_navigator_dart.dart';

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

/// Typed variant of whole url path (which consists of [TypedSegment]s)
typedef TypedPath = List<TypedSegment>;

/// Riverpod StateNotifier. Notifying that actual typed path has changed
/// (and the Navigator 2.0 navigation stack needs to be changed too).
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

/// String path <==> TypedPath
class PathParser {
  static const String defaultJsonUnionKey = 'runtimeType';

  /// String path => TypedPath
  String typedPath2Path(TypedPath typedPath) => typedPath.map((s) => Uri.encodeComponent(s.asJson)).join('/');

  /// TypedPath => String path, suitable for browser
  TypedPath path2TypedPath(String? path) {
    if (path == null || path.isEmpty) return [];
    return [
      for (final s in path.split('/'))
        if (s.isNotEmpty) config4Dart.json2Segment(jsonDecode(Uri.decodeFull(s)), defaultJsonUnionKey)
    ];
  }

  /// Friendly display of TypedPath
  String debugTypedPath2String(TypedPath typedPath) => typedPath.map((s) => s.asJson).join(' / ');
}

// ********************************************
//   configuration
// ********************************************

typedef Json2Segment = TypedSegment Function(JsonMap jsonMap, String unionKey);

// @IFNDEF riverpod_navigator_idea

//********** types for asynchronous navigation */

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

/// navigation config (for dart-only part of code)
class Config4Dart {
  Config4Dart({
    required this.json2Segment,
    PathParser? pathParser,
    this.segment2AsyncScreenActions,
  })  : assert(_value == null, 'Extension.init called multipple times'),
        pathParser = pathParser ?? SimplePathParser() /* PathParser */ {
    _value = this;
  }

  /// String url path <==> [TypedPath] parser
  final PathParser pathParser;

  /// How to convert [TypedSegment] to json
  final Json2Segment json2Segment;

  /// screen async-navigation action
  final Segment2AsyncScreenActions? segment2AsyncScreenActions;
}

Config4Dart get config4Dart {
  assert(_value != null, 'Call Extension.init first!');
  return _value as Config4Dart;
}

/// config is static singleton
Config4Dart? _value;
