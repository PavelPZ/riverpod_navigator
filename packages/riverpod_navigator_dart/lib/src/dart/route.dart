part of 'index.dart';

class TypedRoute<T extends TypedSegment> {
  Future<void>? creating(T newPath) => null;
  Future<void>? merging(T oldPath, T newPath) => null;
  Future<void>? deactivating(T oldPath) => null;

  /// properties which needs Flutter library
  Object? flutterConfig;

  AsyncScreenActions toAsyncScreenActions() => AsyncScreenActions(
        creating: (n) => creating(n as T),
        merging: (o, n) => merging(o as T, n as T),
        deactivating: (o) => deactivating(o as T),
      );
}

abstract class RouteGroup<T extends TypedSegment> {
  RouteGroup({this.unionKey = 'runtimeType'});
  final String unionKey;
  bool isGroup(TypedSegment segment) => segment is T;
  // *** to override
  T json2Segment(JsonMap jsonMap);
  TypedRoute segment2Route(T segment);
}

class TypedRouter {
  TypedRouter(this.groups);
  final List<RouteGroup> groups;

  AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) => segment2Group(segment).segment2Route(segment).toAsyncScreenActions();
  TypedSegment json2Segment(JsonMap jsonMap, String unionKey) => groups.singleWhere((g) => g.unionKey == unionKey).json2Segment(jsonMap);

  RouteGroup segment2Group(TypedSegment segment) => groups.singleWhere((g) => g.isGroup(segment));
}
