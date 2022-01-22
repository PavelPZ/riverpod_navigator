import 'package:flutter/widgets.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

class RouteInformationParserImpl implements RouteInformationParser<TypedPath> {
  RouteInformationParserImpl(this._pathParser);
  final PathParser _pathParser;
  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) => Future.value(_pathParser.path2TypedPath(routeInformation.location));

  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) => RouteInformation(location: _pathParser.typedPath2Path(configuration));
}
