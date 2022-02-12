// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => app(_ref);
}

class Page1Screen extends ConsumerWidget {
  const Page1Screen(this.segment, {Key? key}) : super(key: key);

  final Page1Segment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      page1Screen(_ref, segment);
}

class Page2Screen extends ConsumerWidget {
  const Page2Screen(this.segment, {Key? key}) : super(key: key);

  final Page2Segment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      page2Screen(_ref, segment);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$Page1Segment _$$Page1SegmentFromJson(Map<String, dynamic> json) =>
    _$Page1Segment(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$Page1SegmentToJson(_$Page1Segment instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$Page2Segment _$$Page2SegmentFromJson(Map<String, dynamic> json) =>
    _$Page2Segment(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$Page2SegmentToJson(_$Page2Segment instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };
