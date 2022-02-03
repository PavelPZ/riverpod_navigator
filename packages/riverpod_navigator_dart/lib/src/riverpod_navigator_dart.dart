import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

import 'extensions/simpleUrlParser.dart';

part 'riverpod_navigator_dart.freezed.dart';

typedef JsonMap = Map<String, dynamic>;
typedef Json2Segment = TypedSegment Function(JsonMap jsonMap, String unionKey);
typedef AsyncActionResult = dynamic;

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

/// Typed variant of whole url path (which consists of [TypedSegment]s)
typedef TypedPath = List<TypedSegment>;

// ********************************************
//  NavigationState
// ********************************************

@freezed
class NavigationState with _$NavigationState, INavigationState {
  factory NavigationState({required TypedPath path}) = _NavigationState;
  NavigationState._();

  @override
  INavigationState copyWithPath(TypedPath path) => copyWith(path: path);
}

abstract class INavigationState {
  TypedPath get path;
  INavigationState copyWithPath(TypedPath path);
}

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

/// monitoring of all states that affect navigation
final navigationStateNotifierProvider = StateProvider<INavigationState>((ref) => ref.read(config4DartProvider).getAllDependedStates(ref));

NavigationState defaultGetAllDependedStates(Ref ref) => NavigationState(path: []);

typedef GetAllDependedStates = INavigationState Function(Ref ref);

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

  /// "creator" proc for routerDelegate.
  /// depends on the use of the flutter x dart platform
  IRouterDelegate Function(Ref ref) routerDelegateCreator = (_) => RouterDelegate4Dart();

  /// e.g (ref) => [ref.watch(typedPathProvider), ref.watch(userIsLoggedProvider)]
  ///
  /// default value is (ref) => [ref.watch(typedPathProvider)]
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
class RiverpodNavigator<T extends INavigationState> {
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

  T readNavigationState() => ref.read(navigationStateNotifierProvider) as T;
  void updateNavigationState(T update(T state)) {
    ref.read(navigationStateNotifierProvider.notifier).update((s) => update(s as T));
  }

  /// put all change-route application logic here (redirects, needs login etc.)
  ///
  /// Returns redirect path or null (if newPath is already processed)
  FutureOr<TypedPath?> appNavigationLogic(Ref ref, TypedPath oldPath, INavigationState newState) => null;

  /// Main [RiverpodNavigator] method. Provides navigation to the new [TypedPath].
  ///
  /// If the navigation logic depends on another state (e.g. whether the user is logged in or not),
  /// use watch for this state in overrided [RiverpodNavigator.appNavigationLogic]
  @nonVirtual
  Future<void> navigate(TypedPath newPath) async {
    // listen for redirects (appNavigationLogicProvider returns or null or redirect path)
    _unlistenRedirects ??= ref.listen<INavigationState>(navigationStateNotifierProvider, (_, __) async {
      final oldPath = actualTypedPath;
      final newState = ref.read(navigationStateNotifierProvider);

      final redirectPathFuture = appNavigationLogic(ref, oldPath, newState);
      final redirectPath = redirectPathFuture is Future<TypedPath?> ? await redirectPathFuture : redirectPathFuture;

      // redirect
      if (redirectPath != null) {
        scheduleMicrotask(() => navigate(redirectPath));
        return;
      }

      // no redirect => actualize navigation stack
      routerDelegate.currentConfiguration = newState.path;
      routerDelegate.notifyListeners();
    });
    // refresh navigation state
    updateNavigationState((state) => state.copyWithPath(newPath) as T);

    // This line is necessary to activate the [navigationStateProvider].
    // Without this line [navigationStateProvider] is not listened.
    // ignore: unused_local_variable
    final res = ref.read(navigationStateNotifierProvider);
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
