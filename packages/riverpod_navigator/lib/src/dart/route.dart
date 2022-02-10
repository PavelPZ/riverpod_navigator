part of 'index.dart';

class RRoute<T extends TypedSegment> {
  RRoute(
    this.builder, {
    this.screen2Page,
    this.creating,
    this.merging,
    this.deactivating,
  });
  RRoute.empty();
  Widget Function(T segment)? builder;
  Screen2Page? screen2Page;
  Future<AsyncActionResult> Function(T newPath)? creating;
  Future<AsyncActionResult> Function(T oldPath, T newPath)? merging;
  Future<AsyncActionResult> Function(T oldPath)? deactivating;
  bool isRoute(TypedSegment segment) => segment is T;

  Widget screenBuilder(T segment) => builder!(segment);
  Future<AsyncActionResult>? xcreating(T newPath) => creating?.call(newPath);
  Future<AsyncActionResult>? xmerging(T oldPath, T newPath) => merging?.call(oldPath, newPath);
  Future<AsyncActionResult>? xdeactivating(T oldPath) => deactivating?.call(oldPath);

  AsyncScreenActions toAsyncScreenActions() => AsyncScreenActions(
        creating: (n) => xcreating(n as T),
        merging: (o, n) => xmerging(o as T, n as T),
        deactivating: (o) => xdeactivating(o as T),
      );
}

class RRoutes<T extends TypedSegment> {
  RRoutes(
    this.fromJson,
    this.routes, {
    this.unionKey = 'runtimeType',
  });
  RRoutes.empty({this.unionKey = 'runtimeType'});
  List<RRoute<T>>? routes;
  final String unionKey;
  T Function(JsonMap jsonMap)? fromJson;

  bool isGroup(TypedSegment segment) => segment is T;
  // *** to override
  T json2Segment(JsonMap jsonMap) => fromJson!(jsonMap);
  RRoute<T> segment2Route(T segment) => routes!.firstWhere((s) => s.isRoute(segment));
}

class RRouter {
  RRouter(this.groups) {
    final unionKeys = groups.map((e) => e.unionKey).toSet();
    if (unionKeys.length != groups.length) throw 'Missing RouteGroup(unionKey: \'XXX\')';
  }
  final List<RRoutes> groups;

  RRoutes segment2Group(TypedSegment segment) => groups.singleWhere((g) => g.isGroup(segment));

  AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) => segment2Group(segment).segment2Route(segment).toAsyncScreenActions();
  TypedSegment json2Segment(JsonMap jsonMap, String unionKey) => groups.singleWhere((g) => g.unionKey == unionKey).json2Segment(jsonMap);

  // flutter part
  ScreenBuilder screenBuilder() => (segment) => segment2Group(segment).segment2Route(segment).screenBuilder(segment);
  Screen2Page screen2Page() => (segment, builder) {
        final res = segment2Group(segment).segment2Route(segment).screen2Page;
        return res == null ? screen2PageDefault(segment, builder) : res(segment, builder);
      };
}
