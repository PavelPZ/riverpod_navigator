part of 'index.dart';

typedef Creating<T extends TypedSegment> = Future<AsyncActionResult> Function(T newPath);
typedef Merging<T extends TypedSegment> = Future<AsyncActionResult> Function(T oldPath, T newPath);
typedef Deactivating<T extends TypedSegment> = Future<AsyncActionResult> Function(T oldPath);

class RRouter {
  RRouter(this.groups) {
    final unionKeys = groups.map((e) => e.unionKey).toSet();
    if (unionKeys.length != groups.length) throw 'Missing RouteGroup(unionKey: \'...\')';
  }
  final List<RRoutes> groups;

  RRoutes segment2Routes(TypedSegment segment) => groups.singleWhere((g) => g.isRoutes(segment));
  RRoute segment2Route(TypedSegment segment) => segment2Routes(segment).segment2Route(segment);

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

  bool isRoutes(TypedSegment segment) => segment is T;
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
  ScreenBuilder<T> screenBuilder;
  Screen2Page? screen2Page;
  Creating<T>? creating;
  Merging<T>? merging;
  Deactivating<T>? deactivating;

  Future<AsyncActionResult>? callCreating(TypedSegment newPath) => creating?.call(newPath as T);
  Future<AsyncActionResult>? callMerging(TypedSegment oldPath, TypedSegment newPath) => merging?.call(oldPath as T, newPath as T);
  Future<AsyncActionResult>? callDeactivating(TypedSegment oldPath) => deactivating?.call(oldPath as T);

  bool isRoute(TypedSegment segment) => segment is T;
  Widget buildScreen(TypedSegment segment) => screenBuilder(segment as T);
}
