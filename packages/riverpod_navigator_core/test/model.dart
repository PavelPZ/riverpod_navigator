import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';

class HomeSegment extends TypedSegment {
  static HomeSegment fromSegmentMap(SegmentMap map) => HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  final int id;

  @override
  void toSegmentMap(SegmentMap map) => map.setInt('id', id);
  static BookSegment fromSegmentMap(SegmentMap map) => BookSegment(id: map.getInt('id'));
}

class LoginSegment extends TypedSegment {
  static LoginSegment fromSegmentMap(SegmentMap map) => LoginSegment();
}

final routes = <RRoute4Dart>[
  RRoute4Dart<HomeSegment>(HomeSegment.fromSegmentMap),
  RRoute4Dart<BookSegment>(BookSegment.fromSegmentMap),
  RRoute4Dart<LoginSegment>(LoginSegment.fromSegmentMap),
];
