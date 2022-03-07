part of 'riverpod_navigator_core.dart';

// ********************************************
//   UrlPars extension
// ********************************************

/// helper for typed-segment <=> string-segment conversion
extension UrlParsEx on UrlPars {
  UrlPars setInt(String name, int? value) => _set<int>(name, value);
  UrlPars setString(String name, String? value) => _set<String>(name, value);
  UrlPars setBool(String name, bool? value) => _set<bool>(name, value);
  UrlPars setDouble(String name, double? value) => _set<double>(name, value);

  String getString(String name) => _get<String>(name, (v) => v);
  int getInt(String name) => _get<int>(name, (v) => int.parse(v));
  bool getBool(String name) => _get<bool>(name, (v) => v == 'true');
  double getDouble(String name) => _get<double>(name, (v) => double.parse(v));

  String? getStringNull(String name) => _getNull<String>(name, (v) => v);
  int? getIntNull(String name) => _getNull<int>(name, (v) => int.parse(v));
  bool? getBoolNull(String name) => _getNull<bool>(name, (v) => v == 'true');
  double? getDoubleNull(String name) => _getNull<double>(name, (v) => double.parse(v));

  UrlPars _set<T>(String name, T? value) {
    if (value != null) this[name] = value.toString();
    return this;
  }

  T _get<T>(String name, T parse(String value)) {
    final value = this[name];
    if (value == null) throw Exception('value != null expected');
    return parse(value);
  }

  T? _getNull<T>(String name, T parse(String value)) {
    final value = this[name];
    return value == null ? null : parse(value);
  }
}

// ********************************************
//   PathParser
// ********************************************

abstract class IPathParser {
  IPathParser(this.router);

  final RRouter router;

  /// String path => TypedPath
  String toUrl(TypedPath typedPath);

  /// TypedPath => String path
  TypedPath fromUrl(String? path);
}

/// Path parser
class PathParser extends IPathParser {
  PathParser(RRouter router) : super(router);

  /// String path => TypedPath
  @override
  String toUrl(TypedPath typedPath) => typedPath.map((s) => router.toUrl(s)).join('/');

  /// TypedPath => String path
  @override
  TypedPath fromUrl(String? path) {
    final res = <TypedSegment>[];
    if (path == null || path.isEmpty) return res;
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
      res.add(router.fromUrlPars(map, properties[0]));
    }
    return res;
  }
}
