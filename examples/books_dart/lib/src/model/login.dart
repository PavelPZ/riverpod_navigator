import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

part 'login.freezed.dart';
part 'login.g.dart';

@Freezed(unionKey: LoginSegments.jsonNameSpace)
class LoginSegments with _$LoginSegments, TypedSegment {
  factory LoginSegments() = _LoginSegments;
  LoginSegments._();
  factory LoginSegments.home({String? loggedUrl, String? canceledUrl}) = LoginHomeSegment;

  factory LoginSegments.fromJson(Map<String, dynamic> json) => _$LoginSegmentsFromJson(json);

  static const String jsonNameSpace = '_login';
}
