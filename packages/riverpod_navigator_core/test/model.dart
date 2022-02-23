import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';

class HomeSegment extends TypedSegment {
  static HomeSegment fromSegmentMap(SegmentMap map) => HomeSegment();
}

class BookSegment extends TypedSegment {
  BookSegment({required this.id});
  final int id;

  @override
  void toSegmentMap(SegmentMap map) => map.setInt('id', id);
  static BookSegment fromSegmentMap(SegmentMap map) => BookSegment(id: map.getInt('id'));
}

class LoginSegment extends TypedSegment {}
