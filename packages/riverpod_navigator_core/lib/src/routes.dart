part of 'riverpod_navigator_core.dart';

/// opening
typedef Opening<T extends TypedSegment> = Future<AsyncActionResult> Function(T newPath);

/// replacing
typedef Replacing<T extends TypedSegment> = Future<AsyncActionResult> Function(T oldPath, T newPath);

/// closing
typedef Closing<T extends TypedSegment> = Future<AsyncActionResult> Function(T oldPath);
typedef AsyncOper = Future<AsyncActionResult> Function();

/// rroute's holder
class RRouter {
  RRouter(List<RRoute4Dart> routes) {
    for (final r in routes) {
      if (_string2Route.containsKey(r.urlName)) {
        throw Exception('"${r.urlName}" segment.TypeName already registered.');
      }
      _string2Route[r.urlName] = r;
      if (_type2Route.containsKey(r.segmentType)) {
        throw Exception('"${r.segmentType.toString()}" segment.segmentType already registered.');
      }
      _type2Route[r.segmentType] = r;
    }
  }

  final _string2Route = <String, RRoute4Dart>{};
  final _type2Route = <Type, RRoute4Dart>{};

  R segment2Route<R extends RRoute4Dart>(TypedSegment segment) => _type2Route[segment.runtimeType] as R;

  bool segmentEq(TypedSegment s1, TypedSegment s2) => segment2Route(s1).toUrl(s1) == segment2Route(s2).toUrl(s2);

  String? toUrl(TypedSegment s) => _type2Route[s.runtimeType]!.toUrl(s);

  TypedSegment fromUrlPars(UrlPars pars, String urlName) => _string2Route[urlName]!.fromUrlPars(pars);
}

/// meta infos for given TypedSegment
class RRoute4Dart<T extends TypedSegment> {
  RRoute4Dart(
    this.urlName,
    this.fromUrlPars, {
    this.opening,
    this.replacing,
    this.closing,
  });
  final Opening<T>? opening;
  final Replacing<T>? replacing;
  final Closing<T>? closing;

  final FromUrlPars<T> fromUrlPars;
  final String urlName;
  final Type segmentType = T;

  AsyncOper? callOpening(TypedSegment newPath) => opening == null ? null : () => opening!(newPath as T);
  AsyncOper? callReplacing(TypedSegment oldPath, TypedSegment newPath) =>
      replacing == null ? null : () => replacing!(oldPath as T, newPath as T);
  AsyncOper? callClosing(TypedSegment oldPath) => closing == null ? null : () => closing!(oldPath as T);

  /// typed-segment to string-segment
  String toUrl(T segment) {
    final map = <String, String>{};
    segment.toUrlPars(map);
    final props = [urlName] + map.entries.map((kv) => '${kv.key}=${Uri.encodeComponent(kv.value)}').toList();
    return props.join(';');
  }
}
