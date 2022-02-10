part of 'index.dart';

class RRouter {
  RRouter(this.groups) {
    final unionKeys = groups.map((e) => e.unionKey).toSet();
    if (unionKeys.length != groups.length) throw 'Missing RouteGroup(unionKey: \'XXX\')';
  }
  final List<RRoutes> groups;

  RRoutes segment2Group(TypedSegment segment) => groups.singleWhere((g) => g.isGroup(segment));
  RRoute segment2Route(TypedSegment segment) => segment2Group(segment).segment2Route(segment);

  TypedSegment json2Segment(JsonMap jsonMap, String unionKey) => groups.singleWhere((g) => g.unionKey == unionKey).fromJson(jsonMap);
}

class RRoutes<T extends TypedSegment> {
  RRoutes(
    this.fromJson,
    this.routes, {
    this.unionKey = 'runtimeType',
  });
  List<RRoute<T>> routes;
  T Function(JsonMap jsonMap) fromJson;
  final String unionKey;

  bool isGroup(TypedSegment segment) => segment is T;
  RRoute<T> segment2Route(T segment) => routes.firstWhere((s) => s.isRoute(segment));
}

class RRoute<T extends TypedSegment> {
  RRoute(
    this.screenBuilder, {
    this.screen2Page,
    this.creating,
    this.merging,
    this.deactivating,
  });
  Widget Function(T segment) screenBuilder;
  Widget buildScreen(TypedSegment segment) => screenBuilder(segment as T);
  Screen2Page? screen2Page;
  Future<AsyncActionResult> Function(T newPath)? creating;
  Future<AsyncActionResult> Function(T oldPath, T newPath)? merging;
  Future<AsyncActionResult> Function(T oldPath)? deactivating;
  bool isRoute(TypedSegment segment) => segment is T;
}
