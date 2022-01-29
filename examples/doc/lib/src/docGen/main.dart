import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class LessonInfo {
  LessonInfo(this.id, String lessonParts, String screensParts) : parts = [lessonParts.split(','), screensParts.split(',')]; // e.g. 0,1,2,3,4,5,6,7

  final String id; // '01', '031', etc.
  final List<List<String>> parts;
}

final lessonInfos = <LessonInfo>[
  LessonInfo('01', '0,1,2,3,4,5,6,7', '0,1,2'),
  LessonInfo('03', '0,1,1-3,2-3,3,4,5,6,7', '0,1,2'),
  LessonInfo('031', '0,1-31,1-3,2-31,3,4,5-3,6,7', '0,1,1-3,2'),
];

const genPath = r'D:\riverpod_navigator\examples\doc\lib\src\docGen\';
const filePath = r'D:\riverpod_navigator\examples\doc\lib\src\temp\';
const del = '一';

List<Map<String, String>> getFilesPart(List<String> fileNames) {
  final res = <Map<String, String>>[];
  for (var i = 0; i < fileNames.length; i++) {
    final str = File('$genPath${fileNames[i]}').readAsStringSync().replaceAll('\n', del);
    final parts = str.split('###part ');
    final map = <String, String>{};
    res.add(map);
    for (var part in parts) {
      final idx = part.indexOf(del);
      if (idx < 0) continue;
      map[part.substring(0, idx - 1)] = part.substring(idx + 1);
    }
  }
  return res;
}

String fileName(String lessonId, int idx) => '${filePath}lesson$lessonId\\${idx == 0 ? 'lesson$lessonId' : 'screens'}.dart';

void main() {
  final parsed = getFilesPart(['lesson.gen', 'screens.gen']);
  for (final info in lessonInfos) {
    for (var idx = 0; idx < 2; idx++) {
      final sourcePart = parsed[idx];
      final resParts = <String>[];
      for (var partId in info.parts[idx]) {
        resParts.add((sourcePart[partId] ?? '').replaceAll(del, '\n'));
      }
      final fn = fileName(info.id, idx);
      Directory(p.dirname(fn)).createSync(recursive: true);
      File(fn).writeAsStringSync(resParts.join('\n').replaceAll('{01}', info.id), encoding: utf8);
    }
  }
  return;
}
