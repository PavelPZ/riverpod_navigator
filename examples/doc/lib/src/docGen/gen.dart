import 'dart:io';

import 'package:path/path.dart' as p;

import 'fileGen.dart';

const lessonsPath = r'D:\riverpod_navigator\examples\doc\lib\src\temp\';

String lessonFn(String lessonId, bool? dartOnly) =>
    '${lessonsPath}lesson$lessonId\\${dartOnly == null ? 'lesson$lessonId' : dartOnly == true ? 'dart_lesson$lessonId' : 'flutter_lesson$lessonId'}.dart';

String screenFn(String lessonId) => '${lessonsPath}lesson$lessonId\\screens.dart';

void gen() {
  final dir = Directory(lessonsPath);
  if (dir.existsSync()) Directory(lessonsPath).deleteSync(recursive: true);
  void writeFile(String fn, String content) {
    Directory(p.dirname(fn)).createSync(recursive: true);
    File(fn).writeAsStringSync(content);
  }

  for (var i = 1; i < 9; i++) {
    // if (i != 1 && i != 2) continue;
    final lessonId = int2LessonId(i);
    final sfn = screenFn(lessonId);
    String sfile;
    if (i == 2) {
      final fd = lessonFn(lessonId, true);
      final filed = fileGen(true, i, true, false);
      writeFile(fd, filed);
      final ff = lessonFn(lessonId, false);
      final filef = fileGen(true, i, false, false);
      writeFile(ff, filef);
      sfile = fileGen(false, i, null, false, screenSplitDartFlutterOnly: true);
    } else {
      final fn = lessonFn(lessonId, null);
      final file = fileGen(true, i, null, false);
      writeFile(fn, file);
      sfile = fileGen(false, i, null, false);
    }
    writeFile(sfn, sfile);
  }
}
