part of 'index.dart';

class TypedRoute<T extends TypedSegment> {
  TypedRoute({
    required this.builder,
    this.screen2Page,
    this.onCreate,
    this.onMerge,
    this.onDeactivate,
  });
  TypedRoute.empty();
  Widget Function(T segment)? builder;
  Screen2Page? screen2Page;
  Future<void> Function(T newPath)? onCreate;
  Future<void> Function(T oldPath, T newPath)? onMerge;
  Future<void> Function(T oldPath)? onDeactivate;
  bool isRoute(TypedSegment segment) => segment is T;

  Widget screenBuilder(T segment) => builder!(segment);
  Future<void>? creating(T newPath) => onCreate?.call(newPath);
  Future<void>? merging(T oldPath, T newPath) => onMerge?.call(oldPath, newPath);
  Future<void>? deactivating(T oldPath) => onDeactivate?.call(oldPath);

  AsyncScreenActions toAsyncScreenActions() => AsyncScreenActions(
        creating: (n) => creating(n as T),
        merging: (o, n) => merging(o as T, n as T),
        deactivating: (o) => deactivating(o as T),
      );
}

class TypedRouteGroup<T extends TypedSegment> {
  TypedRouteGroup(
    this.fromJson, {
    required this.routes,
    this.unionKey = 'runtimeType',
  });
  TypedRouteGroup.empty({this.unionKey = 'runtimeType'});
  List<TypedRoute<T>>? routes;
  final String unionKey;
  T Function(JsonMap jsonMap)? fromJson;

  bool isGroup(TypedSegment segment) => segment is T;
  // *** to override
  T json2Segment(JsonMap jsonMap) => fromJson!(jsonMap);
  TypedRoute<T> segment2Route(T segment) => routes!.firstWhere((s) => s.isRoute(segment));
}

class TypedRouter {
  TypedRouter(this.groups) {
    final unionKeys = groups.map((e) => e.unionKey).toSet();
    if (unionKeys.length != groups.length) throw 'Missing RouteGroup(unionKey: \'XXX\')';
  }
  final List<TypedRouteGroup> groups;

  TypedRouteGroup segment2Group(TypedSegment segment) => groups.singleWhere((g) => g.isGroup(segment));

  AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) => segment2Group(segment).segment2Route(segment).toAsyncScreenActions();
  TypedSegment json2Segment(JsonMap jsonMap, String unionKey) => groups.singleWhere((g) => g.unionKey == unionKey).json2Segment(jsonMap);

  // flutter part
  ScreenBuilder screenBuilder() => (segment) => segment2Group(segment).segment2Route(segment).screenBuilder(segment);
  Screen2Page screen2Page() => (segment, builder) {
        final res = segment2Group(segment).segment2Route(segment).screen2Page;
        return res == null ? screen2PageDefault(segment, builder) : res(segment, builder);
      };
}
