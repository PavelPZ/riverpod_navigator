import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'navigator.dart';

class RouteInformationParserImpl implements RouteInformationParser<TypedPath> {
  final parser = PathParser();

  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) => Future.value(parser.path2TypedPath(routeInformation.location));

  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) => RouteInformation(location: parser.typedPath2Path(configuration));
}

// ********************************************
//   PathParser
// ********************************************

/// String path <==> TypedPath
class PathParser {
  static const String defaultJsonUnionKey = 'runtimeType';

  /// String path => TypedPath
  String typedPath2Path(TypedPath typedPath) => typedPath.map((s) => Uri.encodeComponent(s.toString())).join('/');

  /// TypedPath => String path, suitable for browser
  TypedPath path2TypedPath(String? path) {
    if (path == null || path.isEmpty) return [];
    return [
      for (final s in path.split('/'))
        if (s.isNotEmpty) Segments.fromJson(jsonDecode(Uri.decodeFull(s)))
    ];
  }
}
