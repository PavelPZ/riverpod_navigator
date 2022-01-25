import '../model.dart';

export 'asyncNavigator.dart';
export 'simpleUrlParser.dart';

typedef Json2Segment = TypedSegment Function(JsonMap jsonMap, String unionKey);

class AsyncScreenActions<T extends TypedSegment> {
  Future<void>? creating(T newPath) => null;
  Future<void>? merging(T oldPath, T newPath) => null;
  Future<void>? deactivating(T oldPath) => null;
}

typedef Segment2AsyncScreenActions = AsyncScreenActions Function(TypedSegment segment);

class Extensions4Dart {
  Extensions4Dart({
    required this.json2Segment,
    PathParser? pathParser,
    this.segment2AsyncScreenActions,
  })  : assert(_value == null, 'Extension.init called multipple times'),
        pathParser = pathParser ?? PathParser() {
    _value = this;
  }

  final PathParser pathParser;
  final Json2Segment json2Segment;
  final Segment2AsyncScreenActions? segment2AsyncScreenActions;
}

Extensions4Dart get config4Dart {
  assert(_value != null, 'Call Extension.init first!');
  return _value as Extensions4Dart;
}

Extensions4Dart? _value;
