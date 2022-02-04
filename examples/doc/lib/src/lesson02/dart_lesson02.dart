// ignore: unused_import
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

part 'dart_lesson02.freezed.dart';
part 'dart_lesson02.g.dart';

// *** 1. classes for typed path segments (TypedSegment)

/// The Freezed package generates three immutable classes used for writing typed navigation path,
/// e.g TypedPath path = [HomeSegment (), BooksSegment () and BookSegment (id: 3)]
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

// *** 2. App-specific navigator with navigation aware actions (used in screens)

const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref, {Object? flutterConfig, IRouterDelegate? routerDelegate})
      : super(ref, initPath: [HomeSegment()], json2Segment: json2Segment, flutterConfig: flutterConfig, routerDelegate: routerDelegate);

  void toHome() => navigate([HomeSegment()]);
  void toBooks() => navigate([HomeSegment(), BooksSegment()]);
  void toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  void bookNextPrevButton({bool? isPrev}) {
    assert(currentTypedPath.last is BookSegment);
    var id = (currentTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    toBook(id: id);
  }
}

