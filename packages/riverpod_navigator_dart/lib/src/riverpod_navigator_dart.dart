import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod/riverpod.dart';

import '../riverpod_navigator_dart.dart';

typedef JsonMap = Map<String, dynamic>;

// ********************************************
//  basic classes:  TypedSegment and TypedPath
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

// ********************************************
// Dart config and providers (with creators from config)
// ********************************************
typedef Json2Segment = TypedSegment Function(JsonMap jsonMap, String unionKey);

/// config4DartProvider value is initialized by:
///
/// ```
/// ProviderScope(
///   overrides: [
///     config4DartProvider.overrideWithValue(Config4Dart(...))),
///   ],...
/// ```
final config4DartProvider = Provider<Config4Dart>((_) => throw UnimplementedError());

/// provider for app specific RiverpodNavigator
final riverpodNavigatorProvider = Provider<RiverpodNavigator>((ref) => ref.read(config4DartProvider).riverpodNavigatorCreator(ref));

/// provider for: 1. RouterDelegate4Dart for Dart project, 2. RiverpodRouterDelegate for Flutter project
final routerDelegateProvider = Provider<IRouterDelegate>((ref) => ref.read(config4DartProvider).routerDelegateCreator(ref));

class Config4Dart {
  Config4Dart({
    required this.routerDelegateCreator,
    required this.riverpodNavigatorCreator,
    required this.json2Segment,
    required this.initPath,
    PathParser? pathParser,
    this.segment2AsyncScreenActions,
    this.splashPath,
  }) : pathParser = pathParser ?? SimplePathParser();
  // String <=> TypedPath parser
  final PathParser pathParser;

  /// How to convert [TypedSegment] to json
  final Json2Segment json2Segment;

  /// screen async-navigation action
  final Segment2AsyncScreenActions? segment2AsyncScreenActions;

  /// initial screen
  final TypedPath initPath;

  /// splash screen
  final TypedPath? splashPath;

  /// app specific RiverpodNavigator
  final RiverpodNavigator Function(Ref ref) riverpodNavigatorCreator;

  /// RouterDelegate4Dart for Dart project, RiverpodRouterDelegate for Flutter project
  final IRouterDelegate Function(Ref ref) routerDelegateCreator;
}

// ********************************************
// FutureTypedPath => async actual TypedPath
// ********************************************

/// "updateShouldNotify => true" forces update of RouterDelegateProvider
/// (and the Navigator 2.0 navigation stack needs to be changed too).
class FutureTypedPath extends StateController<TypedPath> {
  FutureTypedPath() : super([]);

  /// change state, which is called typedPath
  set typedPath(TypedPath newTypedPath) => state = newTypedPath;
  TypedPath get typedPath => state;

  @override
  bool updateShouldNotify(TypedPath old, TypedPath current) => true;
}

/// Riverpod provider which provides [FutureTypedPath] to whole app
final futureTypedPathProvider = StateNotifierProvider<FutureTypedPath, TypedPath>((_) => FutureTypedPath());

// RouterDelegate interface for dart and flutter
abstract class IRouterDelegate {
  TypedPath currentConfiguration = [];
  void notifyListeners();
}

// RouterDelegate for dart
class RouterDelegate4Dart extends IRouterDelegate {
  @override
  void notifyListeners() {}
}

final asyncTypedPathProvider = FutureProvider<TypedPath>((ref) => ref.watch(riverpodNavigatorProvider).appNavigationLogic(ref));

// ********************************************
//   RiverpodNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RiverpodNavigator {
  RiverpodNavigator(this.ref) : config = ref.read(config4DartProvider);

  Ref ref;
  final Config4Dart config;

  /// put all change-route application logic here
  Future<TypedPath> appNavigationLogic(Ref ref) async {
    final routerDelegate = ref.read(routerDelegateProvider);
    final newPath = ref.watch(futureTypedPathProvider);
    final oldPath = routerDelegate.currentConfiguration;
    routerDelegate.currentConfiguration = newPath;
    routerDelegate.notifyListeners();
    return newPath;
  }

  /// Main [RiverpodNavigator] method. Provides navigation to the new [TypedPath].
  ///
  /// 1 line: change [futureTypedPathProvider]'s state => [asyncTypedPathProvider] starts its work
  /// 2 line: waiting for [asyncTypedPathProvider] completition
  Future<TypedPath> navigate(TypedPath newTypedPath) {
    ref.read(futureTypedPathProvider.notifier).state = newTypedPath;
    return ref.read(asyncTypedPathProvider.future);
  }

  FutureTypedPath getPathNotifier() => ref.read(futureTypedPathProvider.notifier);

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
//   PathParser
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
//   AsyncScreenActions
// ********************************************

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
