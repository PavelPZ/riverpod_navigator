import 'dart:async';

import 'package:async/async.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

part 'defer2NextClick.dart';
part 'navigator.dart';
part 'providers.dart';

// ********************************************
// Basic types
// ********************************************

abstract class TypedSegment {}

/// Typed variant of whole url path (which consists of [TypedSegment]s)
typedef TypedPath = List<TypedSegment>;

// ********************************************
// RestorePath
// ********************************************

class RestorePath {
  RestorePath();
  TypedPath? path;
  void onPathChanged(TypedPath navigationStack) => path = navigationStack;
  TypedPath getInitialPath(TypedPath initPath) => path ?? initPath;
}
