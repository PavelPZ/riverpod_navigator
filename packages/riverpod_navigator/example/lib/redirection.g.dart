// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redirection.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => app(_ref);
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen(this.segment, {Key? key}) : super(key: key);

  final LoginSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      loginScreen(_ref, segment);
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      homeScreen(_ref, segment);
}

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen(this.segment, {Key? key}) : super(key: key);

  final FamilySegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      familyScreen(_ref, segment);
}

class PersonScreen extends ConsumerWidget {
  const PersonScreen(this.segment, {Key? key}) : super(key: key);

  final PersonSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      personScreen(_ref, segment);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginSegment _$$LoginSegmentFromJson(Map<String, dynamic> json) =>
    _$LoginSegment(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$LoginSegmentToJson(_$LoginSegment instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$HomeSegment _$$HomeSegmentFromJson(Map<String, dynamic> json) =>
    _$HomeSegment(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$HomeSegmentToJson(_$HomeSegment instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$FamilySegment _$$FamilySegmentFromJson(Map<String, dynamic> json) =>
    _$FamilySegment(
      fid: json['fid'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$FamilySegmentToJson(_$FamilySegment instance) =>
    <String, dynamic>{
      'fid': instance.fid,
      'runtimeType': instance.$type,
    };

_$PersonSegment _$$PersonSegmentFromJson(Map<String, dynamic> json) =>
    _$PersonSegment(
      fid: json['fid'] as String,
      pid: json['pid'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PersonSegmentToJson(_$PersonSegment instance) =>
    <String, dynamic>{
      'fid': instance.fid,
      'pid': instance.pid,
      'runtimeType': instance.$type,
    };
