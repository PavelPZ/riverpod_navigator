import 'dart:async';
import 'dart:convert';

import 'package:riverpod/riverpod.dart';

import 'pathParser.dart';
import 'route.dart';

typedef JsonMap = Map<String, dynamic>;

/// Typed variant of Uri path segment
abstract class TypedSegment {
  TypedSegment copy();
  JsonMap toJson();

  /// key for MaterialApp(key: ValueKey([TypedSegment.key]))
  String get key => _key ?? (_key = jsonEncode(this));
  String? _key;
}

/// Typed variant of Uri path
typedef TypedPath = List<TypedSegment>;

/// Notifies Navigator 2.0 [RiverpodRouterDelegate] when to change navigation stack
class TypedPathNotifier extends StateNotifier<TypedPath> {
  TypedPathNotifier() : super([]);

  /// change state
  void setNewTypedPath(TypedPath newTypedPath) => state = newTypedPath;
}

/// Will provided [TypedPathNotifier] to whole app
final typedPathNotifierProvider = StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier());

abstract class RiverpodNavigator {
  RiverpodNavigator(this.ref, this.getRouteWithSegment, this.pathParser, {this.initPath});
  final Ref ref;
  final TypedPath? initPath;
  final GetRoute4Segment getRouteWithSegment;
  final PathParser pathParser;

  Future<void> navigate(TypedPath newTypedPath) async => actualTypedPath = newTypedPath;

  TypedPath get actualTypedPath => ref.read(typedPathNotifierProvider);
  set actualTypedPath(TypedPath value) => ref.read(typedPathNotifierProvider.notifier).setNewTypedPath(value);
  String get actualTypedPathAsString => actualTypedPath.map((s) => s.key).join(' / ');

  /// for RouterDelegate
  bool onPopRoute() {
    if (actualTypedPath.length <= 1) return false;
    unawaited(navigate([for (var i = 0; i < actualTypedPath.length - 1; i++) actualTypedPath[i]]));
    return true;
  }

  /* ******************************************** */
  /*   common navigation agnostic app actions     */
  /* ******************************************** */

  Future<bool> pop() async {
    if (actualTypedPath.length <= 1) return false;
    await navigate([for (var i = 0; i < actualTypedPath.length - 1; i++) actualTypedPath[i]]);
    return true;
  }

  Future<void> push(TypedSegment segment) => navigate([...actualTypedPath, segment]);

  Future<void> replaceLast(TypedSegment segment) => navigate([for (var i = 0; i < actualTypedPath.length - 1; i++) actualTypedPath[i], segment]);
}
