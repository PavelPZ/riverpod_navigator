import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
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
  /// temporary field. Transmits result of async action to screen
  @JsonKey(ignore: true)
  AsyncActionResult asyncActionResult;
  JsonMap toJson();

  String get asJson => _asJson ?? (_asJson = jsonEncode(toJson()));
  String? _asJson;
}

typedef AsyncActionResult = dynamic;

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
class RiverpodNavigator {
  RiverpodNavigator(this.ref, this.config);

  Ref ref;

  final Config4Dart config;

  /// Main navigator method provided navigating to new [TypedPath]
  Future<void> navigate(TypedPath newTypedPath) async => setActualTypedPath(newTypedPath);

  TypedPathNotifier getPathNotifier() => ref.read(typedPathNotifierProvider.notifier);

  TypedPath getActualTypedPath() => getPathNotifier().typedPath;
  void setActualTypedPath(TypedPath value) => getPathNotifier().typedPath = value;

  String debugTypedPath2String() => config.pathParser.debugTypedPath2String(getActualTypedPath());

  /// for [Navigator.onPopPage] in [RiverpodRouterDelegate.build]
  bool onPopRoute() {
    final actPath = getActualTypedPath();
    if (actPath.length <= 1) return false;
    navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
    return false;
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

  /// every parser needs config, specified after creation (e.g. in )
  void init(Config4Dart config) => _config = config;

  Config4Dart get config => _config as Config4Dart;
  Config4Dart? _config;

  /// String path => TypedPath
  String typedPath2Path(TypedPath typedPath) => typedPath.map((s) => Uri.encodeComponent(s.asJson)).join('/');

  /// TypedPath => String path, suitable for browser
  TypedPath path2TypedPath(String? path) {
    if (path == null || path.isEmpty) return [];
    return [
      for (final s in path.split('/'))
        if (s.isNotEmpty) config.json2Segment(jsonDecode(Uri.decodeFull(s)), defaultJsonUnionKey)
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

  Future<AsyncActionResult>? callCreating(TypedSegment newPath) => creating != null ? creating?.call(newPath as T) : null;
  Future<AsyncActionResult>? callMerging(TypedSegment oldPath, TypedSegment newPath) =>
      merging != null ? merging?.call(oldPath as T, newPath as T) : null;
  Future<AsyncActionResult>? callDeactivating(TypedSegment oldPath) => creating != null ? deactivating?.call(oldPath as T) : null;
}

typedef Segment2AsyncScreenActions = AsyncScreenActions? Function(TypedSegment segment);
// @ENDIF riverpod_navigator_idea

/// navigation config (for dart-only part of code)
class Config4Dart {
  Config4Dart({
    required this.json2Segment,
    PathParser? pathParser,
    this.segment2AsyncScreenActions,
    required this.initPath,
    this.splashPath,
  }) : pathParser = pathParser ?? PathParser() {
    this.pathParser.init(this);
  }

  /// String url path <==> [TypedPath] parser
  final PathParser pathParser;

  /// How to convert [TypedSegment] to json
  final Json2Segment json2Segment;

  /// screen async-navigation action
  final Segment2AsyncScreenActions? segment2AsyncScreenActions;

  final TypedPath initPath;
  final TypedPath? splashPath;
}

final config4DartProvider = Provider<Config4Dart>((_) => throw UnimplementedError());
