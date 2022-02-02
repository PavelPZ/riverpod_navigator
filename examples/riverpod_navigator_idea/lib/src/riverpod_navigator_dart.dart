import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

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
    //required this.routerDelegateCreator,
    required this.riverpodNavigatorCreator,
    required this.json2Segment,
    required this.initPath,
    PathParser? pathParser,
  }) : pathParser = pathParser ?? PathParser() {
    this.pathParser.init(this);
  }

  /// String <=> TypedPath parser
  final PathParser pathParser;

  /// How to convert json string to [TypedSegment]
  final Json2Segment json2Segment;

  /// initial screen
  final TypedPath initPath;

  /// app specific RiverpodNavigator.
  /// "create" proc for riverpodNavigatorProvider.
  final RiverpodNavigator Function(Ref ref) riverpodNavigatorCreator;

  /// RouterDelegate4Dart for Dart project, RiverpodRouterDelegate for Flutter project.
  /// "create" proc for routerDelegateProvider.
  IRouterDelegate Function(Ref ref) routerDelegateCreator = (_) => RouterDelegate4Dart();
}

// ********************************************
// TypedPath changing
// ********************************************

/// Riverpod provider which provides actual [TypedPath] to whole app
///
/// Do not watch for it, it sometimes changes two times during single navig calculation
/// (e.g. when [RiverpodNavigator.appNavigationLogic] performs redirect).
final actualTypedPathProvider = StateProvider<TypedPath>((_) => []);

/// Helper provider. When its value changed, navigation calculation starts.
///
/// Basically, for actualTypedPathProvider we need possibility to changing state WITHOUT calling its listeners
/// (e.g. when [RiverpodNavigator.appNavigationLogic] performs redirect).
/// It is no possible so we hack it by means of navigationConditionsChangedProvider.
final flag4actualTypedPathChangeProvider = StateProvider<int>((_) => 0);

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

final appNavigationLogicProvider = FutureProvider<void>((ref) => ref.read(riverpodNavigatorProvider).appNavigationLogicCreator(ref));

// ********************************************
//   RiverpodNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RiverpodNavigator {
  RiverpodNavigator(this.ref) : config = ref.read(config4DartProvider);

  @protected
  Ref ref;
  @protected
  final Config4Dart config;

  /// put all change-route application logic here (redirects, needs login etc.)
  ///
  /// Can be async, see [AsyncRiverpodNavigator]
  FutureOr<TypedPath> appNavigationLogic(TypedPath oldPath, TypedPath newPath) => newPath;

  // "create" proc for appNavigationLogicProvider
  @nonVirtual
  Future<void> appNavigationLogicCreator(Ref ref) async {
    ref.watch(flag4actualTypedPathChangeProvider);
    final routerDelegate = ref.read(routerDelegateProvider);
    final actualTypedPath = ref.read(actualTypedPathProvider.notifier);
    final oldPath = routerDelegate.currentConfiguration;
    var newPath = actualTypedPath.state;
    final newPathFutureOr = appNavigationLogic(oldPath, newPath);
    newPath = newPathFutureOr is Future ? await newPathFutureOr : newPathFutureOr;
    routerDelegate.currentConfiguration = actualTypedPath.state = newPath;
    routerDelegate.notifyListeners();
  }

  /// Main [RiverpodNavigator] method. Provides navigation to the new [TypedPath].
  ///
  /// If the navigation logic depends on another state (e.g. whether the user is logged in or not),
  /// use watch for this state in overrided [RiverpodNavigator.appNavigationLogic]
  @nonVirtual
  Future<void> navigate(TypedPath newTypedPath) async {
    // navigation to the same path?
    final oldPath = getActualTypedPath();
    final newPath = eq2Identical(getActualTypedPath(), newTypedPath);
    if (oldPath == newPath) return;
    // future path
    ref.read(actualTypedPathProvider.notifier).state = newPath;
    // flag to start the calculation
    ref.read(flag4actualTypedPathChangeProvider.notifier).state++;
    // wait for the navigation to complete
    await ref.read(appNavigationLogicProvider.future);
  }

  @nonVirtual
  TypedPath getActualTypedPath() => ref.read(routerDelegateProvider).currentConfiguration;

  @nonVirtual
  String debugTypedPath2String() => config.pathParser.debugTypedPath2String(getActualTypedPath());

  /// for [Navigator.onPopPage] in [RiverpodRouterDelegate.build]
  @nonVirtual
  bool onPopRoute() {
    final actPath = getActualTypedPath();
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
    final actPath = getActualTypedPath();
    if (actPath.length <= 1) return false;
    await navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
    return true;
  }

  @nonVirtual
  Future<void> push(TypedSegment segment) => navigate([...getActualTypedPath(), segment]);

  @nonVirtual
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
