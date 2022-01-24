import '../model.dart';

export 'simpleNavigator.dart';
export 'simpleUrlParser.dart';

typedef Json2Segment = TypedSegment Function(JsonMap jsonMap, String unionKey);

class Extensions4Dart {
  Extensions4Dart({
    required this.json2Segment,
    PathParser? pathParser,
  })  : assert(_value == null, 'Extension.init called multipple times'),
        pathParser = pathParser ?? PathParser() {
    _value = this;
  }

  final PathParser pathParser;
  final Json2Segment json2Segment;
}

Extensions4Dart get config4Dart {
  assert(_value != null, 'Call Extension.init first!');
  return _value as Extensions4Dart;
}

Extensions4Dart? _value;
