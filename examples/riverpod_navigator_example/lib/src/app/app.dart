import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

import '../navigator.dart';

part 'app.freezed.dart';
part 'app.g.dart';

/// [TypedSegment]'s for this example
@freezed
class ExampleSegments with _$ExampleSegments, TypedSegment {
  ExampleSegments._();
  factory ExampleSegments.home() = HomeSegment;
  factory ExampleSegments.books() = BooksSegment;
  factory ExampleSegments.book({required int id}) = BookSegment;

  factory ExampleSegments.fromJson(Map<String, dynamic> json) => _$ExampleSegmentsFromJson(json);

  static ExampleSegments json2Segment(Map<String, dynamic> json) => ExampleSegments.fromJson(json);
}

// ********************************************
//  ExampleRiverpodNavigator
// ********************************************

/// Number of virtual books in example. There are not any Book data.
const booksLen = 5;

/// Singleton class with app navigation agnostic actions
class ExampleRiverpodNavigator extends RiverpodNavigator {
  ExampleRiverpodNavigator(Ref ref) : super(ref);

  void toHome() => navigate([HomeSegment()]);
  void toBooks() => navigate([HomeSegment(), BooksSegment()]);
  void toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  void bookNextPrevButton({bool? isPrev}) {
    assert(getActualTypedPath().last is BookSegment);
    var id = (getActualTypedPath().last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    toBook(id: id);
  }

  void login() => navigate([HomeSegment()]);
}
