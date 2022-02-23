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
typedef SegmentMap = Map<String, dynamic>;
typedef Json2Segment = TypedSegment Function(SegmentMap, String unionKey);
typedef FromSegmentMap<T extends TypedSegment> = T Function(SegmentMap map);

extension SegmentMapEx on SegmentMap {
  SegmentMap setInt(String name, int value, {int defaultValue = 0}) {
    if (value != defaultValue) this[name] = value.toString();
    return this;
  }

  int getInt(String name, {int defaultValue = 0}) {
    final value = this[name];
    return value == null ? defaultValue : int.parse(value);
  }

  SegmentMap setString(String name, String? value, {String? defaultValue}) {
    if (value != defaultValue) this[name] = value;
    return this;
  }

  String? getString(String name, {String? defaultValue}) {
    final value = this[name];
    return value ?? defaultValue;
  }
}

/// Abstract interface for typed variant of path's segment.
///
/// Instead of three-segment url path 'home/books/$bookId' we can use
/// e.g. navigate([Home(), Books(), Book(id: bookId)]);
@immutable
class TypedSegment {
  //TypedSegment();

  /// temporary field. Transmits result of async action to screen
  // @JsonKey(ignore: true)
  // AsyncActionResult asyncActionResult;
  @deprecated
  SegmentMap toJson() => <String, dynamic>{'runtimeType': runtimeType.toString()};

  void toSegmentMap(SegmentMap map) {}

  String toType() => runtimeType.toString();

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

extension TypedPathEx on TypedPath {
  String toPath() => map((s) => s.toString()).join('/');
}
