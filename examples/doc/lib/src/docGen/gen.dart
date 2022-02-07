import 'dart:io';

import 'package:path/path.dart' as p;

import 'fileGen.dart';

// !!! const lessonsPath = r'D:\riverpod_navigator\examples\doc\lib\src\temp\';
const lessonsPath = r'D:\riverpod_navigator\examples\doc\lib\src\';
const docLessonPath = r'D:\riverpod_navigator\doc\';

String lessonFn(String lessonId) => '${lessonsPath}lesson$lessonId\\lesson$lessonId.dart';

String screenFn(String lessonId) => '${lessonsPath}lesson$lessonId\\screens.dart';

String docFn(String lessonId) => '${docLessonPath}lesson$lessonId.md';

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

    writeFile(lessonFn(lessonId), fileGen(true, i, false));
    writeFile(screenFn(lessonId), fileGen(false, i, false));
    writeFile(docFn(lessonId), fileGen(true, i, true) + fileGen(false, i, true));
  }
}
