import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

import 'extensions/simpleUrlParser.dart';

typedef JsonMap = Map<String, dynamic>;
typedef Json2Segment = TypedSegment Function(JsonMap jsonMap, String unionKey);
typedef AsyncActionResult = dynamic;
typedef RiverpodNavigatorCreator = RiverpodNavigator Function(Ref ref);

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
// Providers
// ********************************************

/// config4DartProvider value is initialized by:
///
/// ```
/// ProviderScope(
///   overrides: [
///     riverpodNavigatorCreatorProvider.overrideWithValue(...),
///   ],...
/// ```
final riverpodNavigatorCreatorProvider = Provider<RiverpodNavigatorCreator>((_) => throw UnimplementedError());

/// provider for app specific RiverpodNavigator
final riverpodNavigatorProvider = Provider<RiverpodNavigator>((ref) => ref.read(riverpodNavigatorCreatorProvider)(ref));

final ongoingTypedPath = StateProvider<TypedPath>((_) => []);

// ********************************************
// Dart config and providers (with creators from config)
// ********************************************

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
class RouterDelegate4Dart with IRouterDelegate {
  @override
  void notifyListeners() {}
}

// ********************************************
//   RiverpodNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
abstract class RiverpodNavigator {
  RiverpodNavigator(
    this.ref, {
    List<AlwaysAliveProviderListenable>? dependsOn,
    required this.json2Segment,
    IRouterDelegate? routerDelegate,
    required this.initPath,
    this.segment2AsyncScreenActions,
    Object? flutterConfig,
  })  : flutterConfig = flutterConfig ?? Object(),
        routerDelegate = routerDelegate ?? RouterDelegate4Dart() {
    this.routerDelegate.navigator = this;

    _defer2NextTick = Defer2NextTick(runNextTick: _runNavigation);
    final allDepends = <AlwaysAliveProviderListenable>[ongoingTypedPath, if (dependsOn != null) ...dependsOn];
    for (final depend in allDepends) _unlistens.add(ref.listen<dynamic>(depend, (previous, next) => defer2NextTick.start()));
    // ignore: avoid_function_literals_in_foreach_calls
    ref.onDispose(() => _unlistens.forEach((f) => f()));
  }

  @protected
  Ref ref;
  final List<Function> _unlistens = [];

  /// depends on the use of the flutter x dart platform
  IRouterDelegate routerDelegate;

  /// screen async-navigation actions
  final Segment2AsyncScreenActions? segment2AsyncScreenActions;

  /// initial screen
  final TypedPath initPath;

  /// properties which needs Flutter library
  Object flutterConfig;

  Defer2NextTick get defer2NextTick => _defer2NextTick as Defer2NextTick;
  Defer2NextTick? _defer2NextTick;
  Future<void> get navigationCompleted => defer2NextTick.future;

  Json2Segment json2Segment;
  PathParser pathParserCreator() => SimplePathParser(json2Segment);

  PathParser get pathParser => _pathParser ?? (_pathParser = pathParserCreator());
  PathParser? _pathParser;

  /// put all change-route application logic here (redirects, needs login etc.)
  ///
  /// Returns redirect path or null (if newPath is already processed)
  FutureOr<void> appNavigationLogic(Ref ref, TypedPath currentPath) => null;

  /// synchronize [ongoingTypedPath] with [RiverpodRouterDelegate.currentConfiguration]
  Future<void> _runNavigation() async {
    final appLogic = appNavigationLogic(ref, currentTypedPath);
    if (appLogic is Future) await appLogic;
    routerDelegate.currentConfiguration = ref.read(ongoingTypedPath);
    routerDelegate.notifyListeners();
  }

  /// Main [RiverpodNavigator] method. Provides navigation to the new [TypedPath].
  @nonVirtual
  Future<void> navigate(TypedPath newPath) async {
    ref.read(ongoingTypedPath.notifier).state = newPath;
    return navigationCompleted;
  }

  @nonVirtual
  TypedPath get currentTypedPath => routerDelegate.currentConfiguration;

  @nonVirtual
  String debugTypedPath2String() => pathParser.debugTypedPath2String(currentTypedPath);

  /// for [Navigator.onPopPage] in [RiverpodRouterDelegate.build]
  @nonVirtual
  bool onPopRoute() {
    final actPath = currentTypedPath;
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
  Future<void> pop() =>
      currentTypedPath.length <= 1 ? Future.value() : navigate([for (var i = 0; i < currentTypedPath.length - 1; i++) currentTypedPath[i]]);

  @nonVirtual
  Future<void> push(TypedSegment segment) => navigate([...currentTypedPath, segment]);

  @nonVirtual
  Future<void> replaceLast(TypedSegment segment) => navigate([for (var i = 0; i < currentTypedPath.length - 1; i++) currentTypedPath[i], segment]);
}

// ********************************************
//   PathParser
// ********************************************

/// String path <==> TypedPath
class PathParser {
  PathParser(this.json2Segment);

  @protected
  final Json2Segment json2Segment;

  static const String defaultJsonUnionKey = 'runtimeType';

  /// String path => TypedPath
  String typedPath2Path(TypedPath typedPath) => typedPath.map((s) => Uri.encodeComponent(s.toString())).join('/');

  /// TypedPath => String path, suitable for browser
  TypedPath path2TypedPath(String? path) {
    if (path == null || path.isEmpty) return [];
    return [
      for (final s in path.split('/'))
        if (s.isNotEmpty) json2Segment(jsonDecode(Uri.decodeFull(s)), defaultJsonUnionKey)
    ];
  }

  /// Friendly display of TypedPath
  String debugTypedPath2String(TypedPath typedPath) => typedPath.map((s) => s.toString()).join(' / ');
}

// ********************************************
//   Defer2NextTick
// ********************************************

class Defer2NextTick {
  Defer2NextTick({required this.runNextTick});
  Completer? _completer;
  FutureOr<void> Function() runNextTick;

  void start() {
    if (_completer != null) return;
    _completer = Completer();
    scheduleMicrotask(() async {
      try {
        final value = runNextTick();
        if (value is Future) await value;
        _completer?.complete();
      } catch (e, s) {
        _completer?.completeError(e, s);
      }
      _completer = null;
    });
  }

  Future<void> get future => _completer != null ? (_completer as Completer).future : Future.value();
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
