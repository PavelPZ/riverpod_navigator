// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'async.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => app(_ref);
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      homeScreen(_ref, segment);
}

class PageScreen extends ConsumerWidget {
  const PageScreen(this.segment, {Key? key}) : super(key: key);

  final PageSegment segment;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      pageScreen(_ref, segment);
}

class PageHelper<N extends RiverpodNavigator> extends ConsumerWidget {
  const PageHelper(
      {Key? key,
      required this.segment,
      required this.title,
      required this.buildChildren})
      : super(key: key);

  final TypedSegment segment;

  final String title;

  final List<Widget> Function(N) buildChildren;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) => pageHelper<N>(_ref,
      segment: segment, title: title, buildChildren: buildChildren);
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext _context) => splashScreen();
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeSegment _$$HomeSegmentFromJson(Map<String, dynamic> json) =>
    _$HomeSegment(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$HomeSegmentToJson(_$HomeSegment instance) =>
    <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$PageSegment _$$PageSegmentFromJson(Map<String, dynamic> json) =>
    _$PageSegment(
      title: json['title'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PageSegmentToJson(_$PageSegment instance) =>
    <String, dynamic>{
      'title': instance.title,
      'runtimeType': instance.$type,
    };
