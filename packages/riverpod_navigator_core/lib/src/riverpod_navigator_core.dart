import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tuple/tuple.dart';

part 'defer2_next_tick.dart';
part 'navigator.dart';
part 'path_parser.dart';
part 'providers.dart';
part 'routes.dart';

// ********************************************
// Basic types
// ********************************************

typedef AsyncActionResult = dynamic;
typedef UrlPars = Map<String, String>;
typedef Json2Segment = TypedSegment Function(UrlPars, String unionKey);
typedef FromUrlPars<T extends TypedSegment> = T Function(UrlPars pars);

/// Ancestor for typed segmenta.
///
/// Instead of three-segment url path 'home/books/$bookId' we can use
/// e.g. navigate([HomeSegment(), BooksSegment(), BookSegment(id: bookId)]);
@immutable
class TypedSegment {
  const TypedSegment();
  void toUrlPars(UrlPars pars) {}

  /// for async navigation: holds async opening or replacing result
  AsyncHolder? get asyncHolder => null;
  void set asyncHolder(AsyncHolder? value) {}
}

/// Typed variant of whole url path (which consists of [TypedSegment]s)
typedef TypedPath = List<TypedSegment>;

/// for async navigation: holds async opening or replacing result
class AsyncHolder<T> {
  T? value;
}

// ********************************************
// RestorePath
// ********************************************

class RestorePath {
  RestorePath();
  TypedPath? path;
  void saveLastKnownStack(TypedPath lastStack) => path = lastStack;
  TypedPath getInitialPath(TypedPath initPath) => path ?? initPath;
}
