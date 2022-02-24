import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tuple/tuple.dart';

part 'defer2_next_tick.dart';
part 'navigator.dart';
part 'pathParser.dart';
part 'providers.dart';
part 'routes.dart';

// ********************************************
// Basic types
// ********************************************

typedef AsyncActionResult = dynamic;
typedef SegmentMap = Map<String, String>;
typedef Json2Segment = TypedSegment Function(SegmentMap, String unionKey);
typedef FromSegmentMap<T extends TypedSegment> = T Function(SegmentMap map);

/// Abstract interface for typed variant of path's segment.
///
/// Instead of three-segment url path 'home/books/$bookId' we can use
/// e.g. navigate([Home(), Books(), Book(id: bookId)]);
@immutable
class TypedSegment {
  const TypedSegment();

  /// temporary field. Transmits result of async action to screen
  // @JsonKey(ignore: true)
  // AsyncActionResult asyncActionResult;

  void toSegmentMap(SegmentMap map) {}

  // static String toType() => runtimeType.toString().replaceFirst('Segment', '').toLowerCase();

  // @override
  // String toString() => _toString ?? (_toString = jsonEncode(toJson()));
  // String? _toString;
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
