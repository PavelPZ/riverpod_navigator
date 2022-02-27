part of 'riverpod_navigator_core.dart';

typedef Opening<T extends TypedSegment> = Future<AsyncActionResult> Function(
    T newPath);
typedef Replacing<T extends TypedSegment> = Future<AsyncActionResult> Function(
    T oldPath, T newPath);
typedef Closing<T extends TypedSegment> = Future<AsyncActionResult> Function(
    T oldPath);
typedef AsyncOper = Future<AsyncActionResult> Function();

class RRouter {
  RRouter(List<RRoute4Dart> routes) {
    for (final r in routes) {
      if (string2Route.containsKey(r.urlName)) {
        throw Exception('"${r.urlName}" segmentTypeName already registered.');
      }
      string2Route[r.urlName] = r;
      if (type2Route.containsKey(r.runtimeType)) {
        throw Exception(
            '"${r.runtimeType.toString()}" segment.runtimeType already registered.');
      }
      type2Route[r.segmentType] = r;
    }
  }

  final string2Route = <String, RRoute4Dart>{};
  final type2Route = <Type, RRoute4Dart>{};

  R segment2Route<R extends RRoute4Dart>(TypedSegment segment) =>
      type2Route[segment.runtimeType] as R;

  bool segmentEq(TypedSegment s1, TypedSegment s2) =>
      segment2Route(s1).toUrl(s1) == segment2Route(s2).toUrl(s2);

  String? toUrl(TypedSegment s) => type2Route[s.runtimeType]!.toUrl(s);

  TypedSegment fromUrlPars(UrlPars pars, String typeName) =>
      string2Route[typeName]!.fromUrlPars(pars);
}

class RRoute4Dart<T extends TypedSegment> {
  RRoute4Dart(
    this.urlName,
    this.fromUrlPars, {
    this.opening,
    this.replacing,
    this.closing,
  }) : segmentType = T;
  Opening<T>? opening;
  Replacing<T>? replacing;
  Closing<T>? closing;

  final FromUrlPars<T> fromUrlPars;
  final String urlName;
  final Type segmentType;

  AsyncOper? callOpening(TypedSegment newPath) =>
      opening == null ? null : () => opening!(newPath as T);
  AsyncOper? callReplacing(TypedSegment oldPath, TypedSegment newPath) =>
      replacing == null ? null : () => replacing!(oldPath as T, newPath as T);
  AsyncOper? callClosing(TypedSegment oldPath) =>
      closing == null ? null : () => closing!(oldPath as T);

  String toUrl(T segment) {
    final map = <String, String>{};
    segment.toUrlPars(map);
    final props = [urlName] +
        map.entries
            .map((kv) => '${kv.key}=${Uri.encodeComponent(kv.value)}')
            .toList();
    return props.join(';');
  }
}
