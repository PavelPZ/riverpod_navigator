import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tuple/tuple.dart';

part 'defer2next_tick.dart';
part 'navigator.dart';
part 'path_parser.dart';
part 'providers.dart';
part 'routes.dart';

// ********************************************
// Basic types
// ********************************************

/// result for async action (opening, closing, replacing)
typedef AsyncActionResult = dynamic;

/// parsed string-segment pars, e.g. for 'book;id=3' it is {'id':'3'}
typedef UrlPars = Map<String, String>;

/// from URL TypedSegment creator
typedef FromUrlPars<T extends TypedSegment> = T Function(UrlPars pars);

/// Ancestor for typed segments.
///
/// Instead of navigate('home/books/book;id=3') we can use
/// navigate([HomeSegment(), BooksSegment(), BookSegment(id: 3)]);
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
/// for nested navigation: holds navigator initPath
class RestorePath {
  RestorePath();
  TypedPath? path;
  void saveLastKnownStack(TypedPath lastStack) => path = lastStack;
  TypedPath getInitialPath(TypedPath initPath) => path ?? initPath;
}

bool _p(String title) {
  if (!_ignorePrint) print(title);
  return true;
}

var _ignorePrint = true;
