part of 'riverpod_navigator_core.dart';

/// opening
typedef Opening<T extends TypedSegment> = Future? Function(T sNew);

/// replacing
typedef Replacing<T extends TypedSegment> = Future? Function(T sOld, T sNew);

/// closing
typedef Closing<T extends TypedSegment> = Future? Function(T sOld);

typedef GetFuture = Future? Function();

/// rroute's holder
class RRouter {
  RRouter(List<RRouteCore> routes) {
    for (final r in routes) {
      final rrr = _string2Route[r.urlName];
      if (rrr != null) {
        if (rrr.segmentType != r.segmentType) {
          throw Exception('"${r.urlName}" segment.urlName already registered.');
        }
      } else {
        _string2Route[r.urlName] = r;
      }

      final rr = _type2Route[r.segmentType];
      if (rr != null) {
        if (rr.segmentType != r.segmentType) {
          throw Exception('"${r.segmentType.toString()}" segment.segmentType already registered.');
        }
      } else {
        _type2Route[r.segmentType] = r;
      }
    }
  }

  // final _type2Route = <Type, RRouteCore>{};

  R segment2Route<R extends RRouteCore>(TypedSegment segment) => _type2Route[segment.runtimeType] as R;

  bool segmentEq(TypedSegment s1, TypedSegment s2) => segment2Route(s1).segment2String(s1) == segment2Route(s2).segment2String(s2);

  // String? toUrl(TypedSegment s) => _type2Route[s.runtimeType]!.toUrl(s);

  // TypedSegment decode(UrlPars pars, String urlName) => _string2Route[urlName]!.decode(pars);
}

final _type2Route = <Type, RRouteCore>{};
final _string2Route = <String, RRouteCore>{};

/// meta infos for given TypedSegment
class RRouteCore<T extends TypedSegment> {
  RRouteCore(
    this.urlName,
    this.decode, {
    this.opening,
    this.replacing,
    this.closing,
    String screenTitle(T segment)?,
  }) : screenTitle = screenTitle ?? ((_) => T.toString());
  final Opening<T>? opening;
  final Replacing<T>? replacing;
  final Closing<T>? closing;

  final FromUrlPars<T> decode;
  final String urlName;
  final Type segmentType = T;
  String Function(T segment) screenTitle;

  String getScreenTitle(TypedSegment segment) => screenTitle(segment as T);
  GetFuture? callOpening(TypedSegment sNew) => opening == null ? null : () => opening!(sNew as T);
  GetFuture? callReplacing(TypedSegment sOld, TypedSegment sNew) => replacing == null ? null : () => replacing!(sOld as T, sNew as T);
  GetFuture? callClosing(TypedSegment sOld) => closing == null ? null : () => closing!(sOld as T);

  /// typed-segment to string-segment
  String segment2String(T segment) {
    final map = <String, String>{};
    segment.encode(map);
    final props = [urlName] + map.entries.map((kv) => '${kv.key}=${Uri.encodeComponent(kv.value)}').toList();
    return props.join(';');
  }
}

String? segment2String(TypedSegment s) => _type2Route[s.runtimeType]!.segment2String(s);
TypedSegment map2Segment(UrlPars pars, String urlName) => _string2Route[urlName]!.decode(pars);
String path2String(TypedPath typedPath) => typedPath.map((s) => segment2String(s)).join('/');
TypedPath? string2Path(String? path) {
  if (path == null || path.isEmpty) return null;
  final res = <TypedSegment>[];
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  if (segments.isEmpty) return res;
  for (final segment in segments) {
    final map = <String, String>{};
    final properties = segment.split(';');
    assert(properties[0].isNotEmpty);
    for (final par in properties.skip(1)) {
      assert(par.isNotEmpty);
      final nameValue = par.split('=');
      assert(nameValue.length == 2);
      map[nameValue[0]] = Uri.decodeComponent(nameValue[1]);
    }
    // res.add(_router.decode(map, properties[0]));
    res.add(map2Segment(map, properties[0]));
  }
  return res.isEmpty ? null : res;
}
