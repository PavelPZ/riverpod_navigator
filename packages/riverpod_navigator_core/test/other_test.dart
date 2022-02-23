@Timeout(Duration(minutes: 30))
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:riverpod_navigator_core/src/riverpod_navigator_core.dart';
import 'package:test/test.dart';

void main() {
  test('other', () async {
    const a1 = A(1, '2');
    const a2 = A(1, '2');
    const a3 = A(3, '2');
    expect(identical(a1, a2), true);
    expect(identical(a1, a3), false);

    const as1 = [A(1, '2'), A(3, '2')];
    const as2 = [A(1, '2'), A(3, '2')];
    expect(identical(as1, as2), true);

    const map = <Object, String>{a1: 'a1 or a2', a3: 'a3'};
    final list = as1.map((a) => map[a]);

    print(list);

    switch (as1[0]) {
      case a1:
        print('a1');
        break;
      case a3:
        print('a3');
        break;
    }
    return;
  });
}

@immutable
class A {
  const A(this.id, this.title);
  final int id;
  final String title;
}

@immutable
class TypedSegment2 {
  const TypedSegment2();

  JsonMap toJson() => <String, dynamic>{'runtimeType': runtimeType.toString()};

  @override
  String toString() => jsonEncode(toJson());
}
