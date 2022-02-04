// ignore: unused_import
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

part 'dart_lesson03.freezed.dart';
part 'dart_lesson03.g.dart';

// *** 1. classes for typed path segments (TypedSegment)

/// Terminology:
/// - string path:
/// ```
/// final stringPath = 'home/books/book;id=2';
/// ```
/// - the string path consists of three string segments: 'home', 'books', 'book;id=2'
/// - typed path:
/// ```
/// final typedPath = <ExampleSegments>[HomeSegment(), BooksSegment(), BookSegment(id:2)];
/// ```
/// - the typed path consists of three typed segments: HomeSegment(), BooksSegment(), BookSegment(id:2)
/// ---------------------
/// From the following definition, [Freezed](https://github.com/rrousselGit/freezed) generates three typed segment classes,
/// HomeSegment, BooksSegment and BookSegment.
/// 
/// See [Freezed](https://github.com/rrousselGit/freezed) for details.
@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
}

/// create segment from JSON map
TypedSegment json2Segment(JsonMap jsonMap, String unionKey) => AppSegments.fromJson(jsonMap);

// *** 1.1. async screen actions

/// Each screen may require an asynchronous action during its creation, merging, or deactivating.
AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
  /// helper for simulating asynchronous action
  Future<String> simulateAsyncResult(String title, int msec) async {
    await Future.delayed(Duration(milliseconds: msec));
    return title;
  }

  return (segment as AppSegments).maybeMap(
    book: (_) => AsyncScreenActions<BookSegment>(
      // for every Book screen: creating takes some time
      creating: (newSegment) async => simulateAsyncResult('Book creating async result after 1 sec', 1000),
      // for every Book screen with odd id: changing to another Book screen takes some time
      merging: (_, newSegment) async => newSegment.id.isOdd ? simulateAsyncResult('Book merging async result after 500 msec', 500) : null,
      // for every Book screen with even id: deactivating takes some time
      deactivating: (oldSegment) => oldSegment.id.isEven ? Future.delayed(Duration(milliseconds: 500)) : null,
    ),
    home: (_) => AsyncScreenActions<HomeSegment>(
      creating: (_) async => simulateAsyncResult('Home creating async result after 1 sec', 1000),
    ),
    orElse: () => null,
  );
}

// *** 2. Specify navigation-aware actions in the navigator. The actions are then used in the screen widgets.

const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          json2Segment: json2Segment,
          segment2AsyncScreenActions: segment2AsyncScreenActions,
        );

  Future<void> toHome() => navigate([HomeSegment()]);
  Future<void> toBooks() => navigate([HomeSegment(), BooksSegment()]);
  Future<void> toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  Future<void> bookNextPrevButton({bool? isPrev}) {
    assert(currentTypedPath.last is BookSegment);
    var id = (currentTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    return toBook(id: id);
  }
}

