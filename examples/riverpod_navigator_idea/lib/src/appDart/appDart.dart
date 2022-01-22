import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

import '../packageDart.dart';

part 'appDart.freezed.dart';
part 'appDart.g.dart';

@freezed
class ExampleSegments with _$ExampleSegments, TypedSegment {
  factory ExampleSegments.home() = HomeSegment;
  factory ExampleSegments.books() = BooksSegment;
  factory ExampleSegments.book({required int id}) = BookSegment;

  factory ExampleSegments.fromJson(Map<String, dynamic> json) => _$ExampleSegmentsFromJson(json);
  @override
  ExampleSegments copy() => map(
        home: (_) => HomeSegment(),
        books: (_) => BooksSegment(),
        book: (route) => route.copyWith(),
      );
}

class ExampleRiverpodNavigator extends RiverpodNavigator {
  ExampleRiverpodNavigator(Ref ref, {TypedPath? initPath}) : super(ref, initPath: initPath);
  void toHome() => navigate([HomeSegment()]);
  void toBooks() => navigate([HomeSegment(), BooksSegment()]);
  void toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  void bookNextPrevButton({bool? isPrev}) {
    assert(actualTypedPath.last is BookSegment);
    var id = (actualTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    toBook(id: id);
  }
}

const booksLen = 5;

final exampleRiverpodNavigatorProvider = Provider<ExampleRiverpodNavigator>((ref) => ExampleRiverpodNavigator(ref, initPath: [HomeSegment()]));

final json2Segment = (jsonMap) => ExampleSegments.fromJson(jsonMap);
