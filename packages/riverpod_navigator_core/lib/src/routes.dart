part of 'index.dart';

typedef Opening<T extends TypedSegment> = Future<AsyncActionResult> Function(T newPath);
typedef Replacing<T extends TypedSegment> = Future<AsyncActionResult> Function(T oldPath, T newPath);
typedef Closing<T extends TypedSegment> = Future<AsyncActionResult> Function(T oldPath);

class RRouter {
  RRouter(this.groups) {
    final unionKeys = groups.map((e) => e.unionKey).toSet();
    if (unionKeys.length != groups.length) throw 'Missing RRouter\'s "@Freezed(unionKey: xxx.jsonNameSpace)" dekorator';
  }
  final List<RRoutes> groups;

  RRoutes segment2Routes(TypedSegment segment) => groups.singleWhere((g) => g.isRoutes(segment));
  R segment2Route<R extends RRoute4Dart>(TypedSegment segment) => segment2Routes(segment).segment2Route(segment) as R;

  TypedSegment json2Segment(JsonMap jsonMap, String unionKey) => groups.singleWhere((g) => g.unionKey == unionKey).fromJson(jsonMap);
}

class RRoutes<T extends TypedSegment> {
  RRoutes(
    this.fromJson,
    this.routes, {
    this.unionKey = 'runtimeType',
  });
  List<RRoute4Dart<T>> routes;
  T Function(JsonMap jsonMap) fromJson;
  final String unionKey;

  bool isRoutes(TypedSegment segment) => segment is T;
  RRoute4Dart<T> segment2Route(T segment) => routes.firstWhere((s) => s.isRoute(segment));
}

class RRoute4Dart<T extends TypedSegment> {
  RRoute4Dart({
    this.opening,
    this.replacing,
    this.closing,
  });
  Opening<T>? opening;
  Replacing<T>? replacing;
  Closing<T>? closing;

  @nonVirtual
  Future<AsyncActionResult>? callOpening(TypedSegment newPath) => opening?.call(newPath as T);
  @nonVirtual
  Future<AsyncActionResult>? callReplacing(TypedSegment oldPath, TypedSegment newPath) => replacing?.call(oldPath as T, newPath as T);
  @nonVirtual
  Future<AsyncActionResult>? callClosing(TypedSegment oldPath) => closing?.call(oldPath as T);

  bool isRoute(TypedSegment segment) => segment is T;
}
