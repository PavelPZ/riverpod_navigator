import 'package:books_dart/books_dart.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

export 'books.dart';
export 'login.dart';

const booksLen = 5;

TypedSegment json2Segment(JsonMap jsonMap, String unionKey) {
  switch (unionKey) {
    case PathParser.defaultJsonUnionKey:
      return AppSegments.fromJson(jsonMap);
    case LoginSegments.jsonNameSpace:
      return LoginSegments.fromJson(jsonMap);
    default:
      throw UnimplementedError();
  }
}
