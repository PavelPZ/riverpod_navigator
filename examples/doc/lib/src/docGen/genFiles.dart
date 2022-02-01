import 'parts.dart';

class GenFile {
  GenFile(
    this.id,
    this.name,
    //this.path,
    this.ids, {
    this.descendants,
    this.descDiff,
  });
  String id;
  String name;
  //String Function() path;
  List<List<String>> ids;
  Map<int, String>? descDiff;
  List<GenFile>? descendants;

  void run() {
    genFiles['$name$id'] = this;
    if (descendants == null) return;
    for (var d in descendants as List<GenFile>) {
      assert(d.descDiff != null && (d.descDiff as Map<int, String>).isNotEmpty);
      for (var i = d.ids.length; i < 8; i++) d.ids.add([...ids[i]]);
      for (final nv in (d.descDiff as Map<int, String>).entries) d.ids[nv.key] = nv.value.split('~');
      d.run();
    }
  }
}

List<Part> fromGetFile(GenFile file) {
  final res = <Part>[];
  return res;
}

const tempDir = r'd:\riverpod_navigator\examples\doc\lib\src\temp\';

final genFiles = <String, GenFile>{};

void initGenFiles() {
  GenFile(
    '01',
    'lesson',
    [
      [lessonHeader('01')],
      ['@l1'],
      ['@l2'],
      ['@l3'],
      ['@l4'],
      ['@l5'],
      ['@l6'],
    ],
    descendants: [
      GenFile(
        '03',
        'lesson',
        [
          [lessonHeader('03')]
        ],
        descDiff: {1: '@l1~l1-3', 2: '@l2-3'},
        descendants: [
          GenFile(
            '031',
            'lesson',
            [
              [lessonHeader('031')]
            ],
            descDiff: {5: '@l4-31'},
          ),
        ],
      ),
    ],
  ).run();
  GenFile(
    '02',
    'dart-lesson',
    [
      [dartLessonHeader('01')],
      ['@l1'],
      ['@l2'],
      ['@l3'],
    ],
  );
  GenFile(
    '02',
    'flutter-lesson',
    [
      [flutterLessonHeader('01')],
      ['@l4'],
      ['@l5'],
      ['@l6']
    ],
  );
  GenFile(
    '01',
    'screen',
    [
      [screensHeader('01')],
      ['@s1'],
      ['@s2'],
    ],
    descendants: [
      GenFile(
        '03',
        'screen',
        [
          [lessonHeader('03')]
        ],
        descDiff: {},
      ),
      GenFile(
        '031',
        'screen',
        [
          [lessonHeader('031')]
        ],
        descDiff: {
          1: '@s1~s1-31',
        },
      ),
    ],
  );
  return;
}
