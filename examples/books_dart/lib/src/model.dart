import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

part 'model.freezed.dart';
part 'model.g.dart';

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

@Freezed(unionKey: LoginSegments.jsonNameSpace)
class LoginSegments with _$LoginSegments, TypedSegment {
  factory LoginSegments() = _LoginSegments;
  LoginSegments._();
  factory LoginSegments.home({String? loggedUrl, String? canceledUrl}) = LoginHomeSegment;

  factory LoginSegments.fromJson(Map<String, dynamic> json) => _$LoginSegmentsFromJson(json);
  @override
  LoginSegments copy() => map(
        (_) => throw UnimplementedError(),
        home: (_) => LoginHomeSegment(),
      );
  static const String jsonNameSpace = '_login';
}
