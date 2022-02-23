part of 'riverpod_navigator_core.dart';

typedef Opening<T extends TypedSegment> = Future<AsyncActionResult> Function(T newPath);
typedef Replacing<T extends TypedSegment> = Future<AsyncActionResult> Function(T oldPath, T newPath);
typedef Closing<T extends TypedSegment> = Future<AsyncActionResult> Function(T oldPath);

class RRouter {
  // RRouter(this.groups) {
  //   final unionKeys = groups.map((e) => e.unionKey).toSet();
  //   if (unionKeys.length != groups.length) throw 'Missing RRouter\'s "@Freezed(unionKey: xxx.jsonNameSpace)" dekorator';
  // }
  RRouter(List<RRoute4Dart> routes) {
    for (final r in routes) {
      if (string2Route.containsKey(r.type)) throw Exception('');
      string2Route[r.type] = r;
      if (type2Route.containsKey(r.runtimeType)) throw Exception('');
      type2Route[r.runtimeType] = r;
    }
  }
  //final List<RRoutes> groups;

  final string2Route = <String, RRoute4Dart>{};
  final type2Route = <Type, RRoute4Dart>{};

  //RRoutes segment2Routes(TypedSegment segment) => groups.singleWhere((g) => g.isRoutes(segment));
  R segment2Route<R extends RRoute4Dart>(TypedSegment segment) =>
      type2Route[segment.runtimeType] as R; //" segment2Routes(segment).segment2Route(segment) as R;

  TypedSegment json2Segment(SegmentMap jsonMap, String unionKey) => string2Route[unionKey]!.fromSegmentMap!(jsonMap);
}

// class RRoutes<T extends TypedSegment> {
//   RRoutes(
//     this.fromJson,
//     this.routes, {
//     this.unionKey = 'runtimeType',
//   });
//   List<RRoute4Dart<T>> routes;
//   T Function(SegmentMap jsonMap) fromJson;
//   final String unionKey;

//   bool isRoutes(TypedSegment segment) => segment is T;
//   RRoute4Dart<T> segment2Route(T segment) => routes.firstWhere((s) => s.isRoute(segment));
// }

class RRoute4Dart<T extends TypedSegment> {
  RRoute4Dart(
    this.fromSegmentMap, {
    this.opening,
    this.replacing,
    this.closing,
    String? type,
  }) : type = type ?? T.toString();
  RRoute4Dart.noWeb({
    this.opening,
    this.replacing,
    this.closing,
  })  : fromSegmentMap = null,
        type = T.toString();
  Opening<T>? opening;
  Replacing<T>? replacing;
  Closing<T>? closing;

  final FromSegmentMap<T>? fromSegmentMap;
  final String type;

  @nonVirtual
  Future<AsyncActionResult>? callOpening(TypedSegment newPath) => opening?.call(newPath as T);
  @nonVirtual
  Future<AsyncActionResult>? callReplacing(TypedSegment oldPath, TypedSegment newPath) => replacing?.call(oldPath as T, newPath as T);
  @nonVirtual
  Future<AsyncActionResult>? callClosing(TypedSegment oldPath) => closing?.call(oldPath as T);

  bool isRoute(TypedSegment segment) => segment is T;
}
