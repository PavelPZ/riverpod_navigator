import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';

class HomeSegment with TypedSegment {}

class BookSegment with TypedSegment {
  BookSegment({required this.id});
  final int id;
  @override
  JsonMap toJson() {
    final res = super.toJson();
    res['id'] = id;
    return res;
  }
}

class LoginSegment with TypedSegment {}
