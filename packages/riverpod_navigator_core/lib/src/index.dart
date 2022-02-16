import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

part 'defer2NextTick.dart';
part 'defer2NextTickNew.dart';
part 'navigator.dart';
part 'providers.dart';

// ********************************************
// Basic types
// ********************************************

typedef AsyncActionResult = dynamic;
typedef JsonMap = Map<String, dynamic>;

/// Abstract interface for typed variant of path's segment.
///
/// Instead of three-segment url path 'home/books/$bookId' we can use
/// e.g. navigate([Home(), Books(), Book(id: bookId)]);
abstract class TypedSegment {
  /// temporary field. Transmits result of async action to screen
  @JsonKey(ignore: true)
  AsyncActionResult asyncActionResult;
  JsonMap toJson() => <String, dynamic>{'runtimeType': runtimeType.toString()};

  @override
  String toString() => _toString ?? (_toString = jsonEncode(toJson()));
  String? _toString;
}

/// Typed variant of whole url path (which consists of [TypedSegment]s)
typedef TypedPath = List<TypedSegment>;

// ********************************************
// RestorePath
// ********************************************

class RestorePath {
  RestorePath();
  TypedPath? path;
  void saveLastKnownStack(TypedPath lastStack) => path = lastStack;
  TypedPath getInitialPath(TypedPath initPath) => path ?? initPath;
}

// ********************************************
// Cancellation Token
// ********************************************

//
class CToken {
  bool isCancelling = false;
}
