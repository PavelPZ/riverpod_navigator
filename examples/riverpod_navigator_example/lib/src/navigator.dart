import 'dart:convert';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import 'providers.dart';

// ********************************************
//  basic classes:  TypedSegment and TypedPath
// ********************************************

/// Abstract interface for typed variant of path's segment.
///
/// Instead of url path 'home/books/$bookId' we can use navigate([Home(), Books(), Book(id: bookId)]);
abstract class TypedSegment {
  Map<String, dynamic> toJson();

  String get asJson => _asJson ?? (_asJson = jsonEncode(toJson()));
  String? _asJson;
}

/// Typed variant of whole url path (which consists of [TypedSegment]s)
typedef TypedPath = List<TypedSegment>;

// ********************************************
//   RiverpodNavigator
// ********************************************

/// Helper singleton class for navigating to [TypedPath]
class RiverpodNavigator {
  RiverpodNavigator(this.ref);

  @protected
  Ref ref;

  /// app navigation logic here, e.g. redirect, guards, ...
  TypedPath appLogic(TypedPath oldPath, TypedPath newPath) => newPath;

  /// Main [RiverpodNavigator] method. Provides navigation to the new [TypedPath] by changing change [workingTypedPathProvider] state.
  @nonVirtual
  void navigate(TypedPath newPath) {
    // navigation to the same path?
    final oldPath = getActualTypedPath();
    newPath = eq2Identical(getActualTypedPath(), newPath);
    if (oldPath == newPath) return;
    // future path
    ref.read(workingTypedPathProvider.notifier).state = newPath;
    // flag to start the calculation
    ref.read(flag4actualTypedPathChangeProvider.notifier).state++;
    ref.read(appNavigationLogicProvider);
  }

  @nonVirtual
  TypedPath getActualTypedPath() => ref.read(riverpodRouterDelegateProvider).currentConfiguration;

  /// for [Navigator.onPopPage] in [RiverpodRouterDelegate.build]
  @nonVirtual
  bool onPopRoute() {
    final actPath = getActualTypedPath();
    if (actPath.length <= 1) return false;
    navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
    return false;
  }

  /// replaces "eq" typed paths with "identical" ones
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
  void pop() {
    final actPath = getActualTypedPath();
    if (actPath.length <= 1) return;
    navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
  }

  @nonVirtual
  void push(TypedSegment segment) => navigate([...getActualTypedPath(), segment]);

  @nonVirtual
  void replaceLast(TypedSegment segment) {
    final actPath = getActualTypedPath();
    navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i], segment]);
  }
}
