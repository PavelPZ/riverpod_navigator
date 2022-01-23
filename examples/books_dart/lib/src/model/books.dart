import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

part 'books.freezed.dart';
part 'books.g.dart';

@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
  @override
  AppSegments copy() => map(
        home: (_) => HomeSegment(),
        books: (_) => BooksSegment(),
        book: (route) => route.copyWith(),
      );
}
