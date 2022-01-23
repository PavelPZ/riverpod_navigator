import 'dart:convert';

import 'model.dart';

typedef Json2Segment = TypedSegment Function(JsonMap jsonMap, String unionKey);

class PathParser {
  PathParser(this.json2Segment);

  static const String defaultJsonUnionKey = 'runtimeType';

  final Json2Segment json2Segment;

  String typedPath2Path(TypedPath typedPath) => typedPath.map((s) => Uri.encodeComponent(jsonEncode(s.toJson()))).join('/');

  TypedPath path2TypedPath(String? path) {
    if (path == null || path.isEmpty) return [];
    return [
      for (final s in path.split('/'))
        if (s.isNotEmpty) json2Segment(jsonDecode(Uri.decodeFull(s)), defaultJsonUnionKey)
    ];
  }
}
