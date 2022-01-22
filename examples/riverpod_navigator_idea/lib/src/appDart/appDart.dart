import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

import '../packageDart.dart';

part 'appDart.freezed.dart';
part 'appDart.g.dart';

/// TypedSegment's for example
@freezed
class ExampleSegments with _$ExampleSegments, TypedSegment {
  ExampleSegments._();
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

/// number of books in example
const booksLen = 5;

/// app navigation agnostic actions
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

final exampleRiverpodNavigatorProvider = Provider<ExampleRiverpodNavigator>((ref) => ExampleRiverpodNavigator(ref, initPath: [HomeSegment()]));
