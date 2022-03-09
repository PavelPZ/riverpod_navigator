part of 'riverpod_navigator_core.dart';

/// opening
typedef Opening<T extends TypedSegment> = Future Function(T newSegment);

/// replacing
typedef Replacing<T extends TypedSegment> = Future<AsyncActionResult> Function(T oldSegment, T newSegment);

/// closing
typedef Closing<T extends TypedSegment> = Future<AsyncActionResult> Function(T oldSegment);
typedef AsyncOper = Future<AsyncActionResult> Function();

/// rroute's holder
class RRouter {
  RRouter(List<RRouteCore> routes) {
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

  final _string2Route = <String, RRouteCore>{};
  final _type2Route = <Type, RRouteCore>{};

  R segment2Route<R extends RRouteCore>(TypedSegment segment) => _type2Route[segment.runtimeType] as R;

  bool segmentEq(TypedSegment s1, TypedSegment s2) => segment2Route(s1).toUrl(s1) == segment2Route(s2).toUrl(s2);

  String? toUrl(TypedSegment s) => _type2Route[s.runtimeType]!.toUrl(s);

  TypedSegment fromUrlPars(UrlPars pars, String urlName) => _string2Route[urlName]!.fromUrlPars(pars);
}

/// meta infos for given TypedSegment
class RRouteCore<T extends TypedSegment> {
  RRouteCore(
    this.urlName,
    this.fromUrlPars, {
    this.opening,
    this.replacing,
    this.closing,
    String screenTitle(T segment)?,
  }) : screenTitle = screenTitle ?? ((_) => T.toString());
  final Opening<T>? opening;
  final Replacing<T>? replacing;
  final Closing<T>? closing;

  final FromUrlPars<T> fromUrlPars;
  final String urlName;
  final Type segmentType = T;
  String Function(T segment) screenTitle;

  String getScreenTitle(TypedSegment segment) => screenTitle(segment as T);
  AsyncOper? callOpening(TypedSegment newSegment) => opening == null
      ? null
      : () async {
          final res = await opening!(newSegment as T);
        };
  AsyncOper? callReplacing(TypedSegment oldSegment, TypedSegment newSegment) =>
      replacing == null ? null : () => replacing!(oldSegment as T, newSegment as T);
  AsyncOper? callClosing(TypedSegment oldSegment) => closing == null ? null : () => closing!(oldSegment as T);

  /// typed-segment to string-segment
  String toUrl(T segment) {
    final map = <String, String>{};
    segment.toUrlPars(map);
    final props = [urlName] + map.entries.map((kv) => '${kv.key}=${Uri.encodeComponent(kv.value)}').toList();
    return props.join(';');
  }
}
