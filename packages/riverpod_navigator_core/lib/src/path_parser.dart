part of 'riverpod_navigator_core.dart';

// ********************************************
//   SegmentMap extension
// ********************************************

extension SegmentMapEx on UrlPars {
  UrlPars setInt(String name, int value, {int defaultValue = 0}) {
    if (value != defaultValue) this[name] = value.toString();
    return this;
  }

  int getInt(String name, {int defaultValue = 0}) {
    final value = this[name];
    return value == null ? defaultValue : int.parse(value);
  }

  UrlPars setString(String name, String? value, {String? defaultValue}) {
    if (value == defaultValue || value == null) return this;
    this[name] = value;
    return this;
  }

  String? getStringNull(String name, {String? defaultValue}) {
    final value = this[name];
    return value ?? defaultValue;
  }

  String getString(String name, {String? defaultValue}) {
    final value = this[name];
    assert(value != null || defaultValue != null,
        'Must be value != null || defaultValue != null');
    return value ?? defaultValue!;
  }
}

// ********************************************
//   PathParser
// ********************************************

/// Path parser interface
class PathParser {
  PathParser(this.router);

  final RRouter router;

  static const String defaultJsonUnionKey = 'runtimeType';

  /// String path => TypedPath
  String toUrl(TypedPath typedPath) =>
      typedPath.map((s) => router.toUrl(s)).join('/');

  /// TypedPath => String path
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
      res.add(router.fromUrl(map, properties[0]));
    }
    return res;
  }
}

/// Simple url path parser
///
/// provides a general method for coding or decoding [TypedSegment]'s with limited capabilities:
/// - attribute values [bool], [String], [int] or [double] only (no [List] or inner classes)
/// = produces one url path segment for one TypedSegment format eg 'home/books/book;id=3'
// class SimplePathParser extends PathParser {
//   SimplePathParser(Json2Segment json2Segment) : super(json2Segment);

//   @override
//   TypedPath path2TypedPath(String? path) {
//     final res = <TypedSegment>[];
//     if (path == null || path.isEmpty) return res;
//     final segments = path.split('/').where((s) => s.isNotEmpty).toList();
//     if (segments.isEmpty) return res;
//     for (final segment in segments) {
//       final segmentMap = <String, dynamic>{};
//       final properties = segment.split(';');
//       assert(properties[0].isNotEmpty);
//       final runtimeType = properties[0].split('-');
//       assert(runtimeType.length <= 2);
//       String unionKey = PathParser.defaultJsonUnionKey;
//       if (runtimeType.length == 1) {
//         // 'book;id=1'
//         segmentMap[PathParser.defaultJsonUnionKey] = runtimeType[0];
//       } else {
//         // 'login-login'
//         unionKey = '_${runtimeType[0]}';
//         segmentMap[unionKey] = runtimeType[1];
//       }
//       for (final par in properties.skip(1)) {
//         assert(par.isNotEmpty);
//         final nameValue = par.split('=');
//         assert(nameValue.length == 2);
//         _addNameValue(segmentMap, nameValue);
//       }
//       final typedSegment = json2Segment(segmentMap, unionKey);
//       res.add(typedSegment);
//     }
//     return res;
//   }

//   @override
//   String typedPath2Path(TypedPath typedPath) {
//     final segmentUrls = <String>[];
//     for (final segment in typedPath) {
//       final jsonMap = segment.toJson();
//       final unionKey = jsonMap.keys.singleWhere((k) => k == PathParser.defaultJsonUnionKey || k.startsWith('_'));
//       final name = unionKey.startsWith('_') ? '${unionKey.substring(1)}-${jsonMap[unionKey]}' : jsonMap[unionKey];
//       String? temp;
//       final segmentUrl = <String>[
//         name,
//         for (final nv in jsonMap.entries.where((en) => en.key != unionKey))
//           if ((temp = _nameValue2Url(nv)) != null) temp ?? ''
//       ].join(';');
//       segmentUrls.add(segmentUrl);
//     }
//     return segmentUrls.join('/');
//   }

//   // a=1;b=0.;c=.0;d=1.5;e=true;f=false;aa:=1;bb:=0.;cc:=.0;dd:=1.5;ee:=true;ff:=false;g=others;h=.;i=12345678901234567890
//   static void _addNameValue(Map<String, dynamic> res, List<String> nameValue /*name=nameValue[0], value=nameValue[1]*/) {
//     var n = nameValue[0];
//     final v = nameValue[1];
//     dynamic nv;
//     if (n.endsWith(':')) {
//       n = n.substring(0, n.length - 1);
//       nv = Uri.decodeFull(v);
//     } else {
//       if (v == 'true') {
//         nv = true;
//       } else if (v == 'false') {
//         nv = false;
//       } else if ((nv = int.tryParse(v)) != null) {
//       } else if ((nv = double.tryParse(v)) != null) {
//       } else {
//         nv = Uri.decodeComponent(v);
//       }
//     }
//     res[n] = nv;
//   }

//   static String? _nameValue2Url(MapEntry<String, dynamic> nv) {
//     if (nv.value == null) return null;
//     String value;
//     String name = nv.key;
//     if (nv.value is int || nv.value is double) {
//       value = nv.value.toString();
//     } else if (nv.value is bool) {
//       value = nv.value ? 'true' : 'false';
//     } else {
//       assert(nv.value is String);
//       if (_stringNeedsType(nv.value)) name += ':';
//       value = Uri.encodeComponent(nv.value);
//     }
//     return '$name=$value';
//   }

//   static bool _stringNeedsType(String s) => int.tryParse(s) != null || s == 'true' || s == 'false' || double.tryParse(s) != null;
// }
