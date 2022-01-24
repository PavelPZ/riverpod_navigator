import '../model.dart';

typedef Json2Segment = TypedSegment Function(JsonMap jsonMap, String unionKey);

class Extensions4Dart {
  Extensions4Dart({
    required this.json2Segment,
    PathParser? pathParser,
  })  : assert(_value == null, 'Extension.init called multipple times'),
        pathParser = pathParser ?? PathParser();

  static Extensions4Dart get value {
    assert(_value != null, 'Call Extension.init first!');
    return _value as Extensions4Dart;
  }

  final PathParser pathParser;
  final Json2Segment json2Segment;

  static Extensions4Dart? _value;
}
