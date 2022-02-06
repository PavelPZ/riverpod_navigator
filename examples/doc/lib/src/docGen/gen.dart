import 'dart:io';

import 'package:path/path.dart' as p;

import 'fileGen.dart';

// !!! const lessonsPath = r'D:\riverpod_navigator\examples\doc\lib\src\temp\';
const lessonsPath = r'D:\riverpod_navigator\examples\doc\lib\src\';
const docLessonPath = r'D:\riverpod_navigator\';

String lessonFn(String lessonId) => '${lessonsPath}lesson$lessonId\\lesson$lessonId.dart';

String screenFn(String lessonId) => '${lessonsPath}lesson$lessonId\\screens.dart';

void gen() {
  // ignore: unused_local_variable
  final dir = Directory(lessonsPath);
  // !!! if (dir.existsSync()) Directory(lessonsPath).deleteSync(recursive: true);

  void writeFile(String fn, String content) {
    Directory(p.dirname(fn)).createSync(recursive: true);
    File(fn).writeAsStringSync(content);
  }

  for (var i = 1; i < lessonMasks.length; i++) {
    // if (i != 1) continue; // !!!
    final lessonId = int2LessonId(i);
    final fn = lessonFn(lessonId);

    final file = fileGen(true, i, false);
    writeFile(fn, file);

    final sfn = screenFn(lessonId);
    final sfile = fileGen(false, i, false);
    writeFile(sfn, sfile);
  }
}
