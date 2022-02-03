import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import 'extensions/simpleUrlParser.dart';

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

  @override
  String toString() => _toString ?? (_toString = jsonEncode(toJson()));
  String? _toString;
}

typedef AsyncActionResult = dynamic;

/// Typed variant of whole url path (which consists of [TypedSegment]s)
typedef TypedPath = List<TypedSegment>;
typedef Json2Segment = TypedSegment Function(JsonMap jsonMap, String unionKey);

// ********************************************
// Providers
// ********************************************

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

/// Provides actual [TypedPath] state
final typedPathProvider = StateProvider<TypedPath>((_) => []);

/// monitoring of all states that affect navigation
//final navigationStateProvider = Provider<Tuple2<TypedPath, bool>>((ref) => Tuple2(ref.watch(typedPathProvider), ref.watch(isLoggedProvider)));

/// monitoring of all states that affect navigation
final navigationStateProvider = Provider<List<Object>>((ref) => ref.read(config4DartProvider).getAllDependedStates(ref));

List<Object> defaultGetAllDependedStates(Ref ref) => [ref.watch(typedPathProvider)];

typedef GetAllDependedStates = List<Object> Function(Ref ref);

// ********************************************
// Dart config and providers (with creators from config)
// ********************************************

class Config4Dart {
  Config4Dart({
    //required this.routerDelegateCreator,
    required this.riverpodNavigatorCreator,
    required this.json2Segment,
    required this.initPath,
    GetAllDependedStates? getAllDependedStates,
    PathParser? pathParser,
    this.segment2AsyncScreenActions,
  })  : pathParser = pathParser ?? SimplePathParser(),
        getAllDependedStates = getAllDependedStates ?? defaultGetAllDependedStates {
    this.pathParser.init(this);
  }

  /// String <=> TypedPath parser
  final PathParser pathParser;

  /// How to convert json string to [TypedSegment]
  final Json2Segment json2Segment;

  /// screen async-navigation actions
  final Segment2AsyncScreenActions? segment2AsyncScreenActions;

  /// initial screen
  final TypedPath initPath;

  /// app specific RiverpodNavigator.
  /// "create" proc for riverpodNavigatorProvider.
  final RiverpodNavigator Function(Ref ref) riverpodNavigatorCreator;

  /// RouterDelegate4Dart for Dart project, RiverpodRouterDelegate for Flutter project.
  /// "create" proc for routerDelegateProvider.
  IRouterDelegate Function(Ref ref) routerDelegateCreator = (_) => RouterDelegate4Dart();

  final GetAllDependedStates getAllDependedStates;
}

// ********************************************
// TypedPath changing
// ********************************************

// RouterDelegate interface for dart and flutter
abstract class IRouterDelegate {
  TypedPath currentConfiguration = [];
  void notifyListeners();
  set navigator(RiverpodNavigator value) => _navigator = value;
  RiverpodNavigator get navigator => _navigator as RiverpodNavigator;
  RiverpodNavigator? _navigator;
}

// RouterDelegate for dart
class RouterDelegate4Dart extends IRouterDelegate {
  @override
  void notifyListeners() {}
}

// ********************************************
//   RiverpodNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RiverpodNavigator {
  RiverpodNavigator(this.ref)
      : config = ref.read(config4DartProvider),
        routerDelegate = ref.read(config4DartProvider).routerDelegateCreator(ref) {
    routerDelegate.navigator = this;
    ref.onDispose(() => _unlistenRedirects?.call());
  }

  @protected
  Ref ref;
  @protected
  final Config4Dart config;

  Function? _unlistenRedirects;

  final IRouterDelegate routerDelegate;

  /// put all change-route application logic here (redirects, needs login etc.)
  ///
  /// Returns redirect path or null (if newPath is already processed)
  FutureOr<TypedPath?> appNavigationLogic(Ref ref, TypedPath oldPath, TypedPath newPath) => null;

  // "create" proc for appNavigationLogicProvider
  // @nonVirtual
  // Future<TypedPath?> appNavigationLogicCreator(Ref ref) async {
  //   // 'watch' as the first command
  //   final newPath = ref.watch(typedPathProvider);

  //   // first call of navigate => initialize appNavigationLogicProvider
  //   if (_unlistenRedirects == null) return [];

  //   final oldPath = actualTypedPath;
  //   final redirectPathFuture = appNavigationLogic(ref, oldPath, newPath);
  //   final redirectPath = redirectPathFuture is Future<TypedPath?> ? await redirectPathFuture : redirectPathFuture;

  //   // redirect
  //   if (redirectPath != null) return redirectPath;

  //   // no redirect => actualize navigation stack
  //   routerDelegate.currentConfiguration = newPath;
  //   routerDelegate.notifyListeners();
  //   return null;
  // }

  /// Main [RiverpodNavigator] method. Provides navigation to the new [TypedPath].
  ///
  /// If the navigation logic depends on another state (e.g. whether the user is logged in or not),
  /// use watch for this state in overrided [RiverpodNavigator.appNavigationLogic]
  @nonVirtual
  Future<void> navigate(TypedPath newPath) async {
    // listen for redirects (appNavigationLogicProvider returns or null or redirect path)
    _unlistenRedirects ??= ref.listen<List<Object>>(navigationStateProvider, (_, __) async {
      final oldPath = actualTypedPath;
      final newPath = ref.read(typedPathProvider);

      final redirectPathFuture = appNavigationLogic(ref, oldPath, newPath);
      final redirectPath = redirectPathFuture is Future<TypedPath?> ? await redirectPathFuture : redirectPathFuture;

      // redirect
      if (redirectPath != null) {
        scheduleMicrotask(() => navigate(redirectPath));
        return;
      }

      // no redirect => actualize navigation stack
      routerDelegate.currentConfiguration = newPath;
      routerDelegate.notifyListeners();
    });
    // change actualTypedPath => refresh navigation state
    ref.read(typedPathProvider.notifier).state = newPath;

    // This line is necessary to activate the [navigationStateProvider].
    // Without this line [navigationStateProvider] is not listened.
    // ignore: unused_local_variable
    final res = ref.read(navigationStateProvider);
  }

  @nonVirtual
  TypedPath get actualTypedPath => routerDelegate.currentConfiguration;

  @nonVirtual
  String debugTypedPath2String() => config.pathParser.debugTypedPath2String(actualTypedPath);

  /// for [Navigator.onPopPage] in [RiverpodRouterDelegate.build]
  @nonVirtual
  bool onPopRoute() {
    final actPath = actualTypedPath;
    if (actPath.length <= 1) return false;
    navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
    return false;
  }

  /// replaces "eq" routes with "identical" ones
  @nonVirtual
  TypedPath eq2Identical(TypedPath oldPath, TypedPath newPath) {
    final newPathCopy = [...newPath];
    var pathsEqual = oldPath.length == newPathCopy.length;
    for (var i = 0; i < min(oldPath.length, newPathCopy.length); i++) {
      if (oldPath[i] == newPathCopy[i])
        newPathCopy[i] = oldPath[i]; // "eq"  => "identical"
      else
        pathsEqual = false; // same of the state[i] is not equal
    }
    return pathsEqual ? oldPath : newPathCopy;
  }

  // *** common navigation-agnostic app actions ***

  @nonVirtual
  Future<bool> pop() async {
    final actPath = actualTypedPath;
    if (actPath.length <= 1) return false;
    await navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
    return true;
  }

  @nonVirtual
  Future<void> push(TypedSegment segment) => navigate([...actualTypedPath, segment]);

  @nonVirtual
  Future<void> replaceLast(TypedSegment segment) {
    final actPath = actualTypedPath;
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
  String typedPath2Path(TypedPath typedPath) => typedPath.map((s) => Uri.encodeComponent(s.toString())).join('/');

  /// TypedPath => String path, suitable for browser
  TypedPath path2TypedPath(String? path) {
    if (path == null || path.isEmpty) return [];
    return [
      for (final s in path.split('/'))
        if (s.isNotEmpty) config.json2Segment(jsonDecode(Uri.decodeFull(s)), defaultJsonUnionKey)
    ];
  }

  /// Friendly display of TypedPath
  String debugTypedPath2String(TypedPath typedPath) => typedPath.map((s) => s.toString()).join(' / ');
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
