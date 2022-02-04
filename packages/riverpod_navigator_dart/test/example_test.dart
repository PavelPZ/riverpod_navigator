// ignore_for_file: unused_local_variable

@Timeout(Duration(minutes: 30))

import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

import 'testLib.dart';

final intProvider = Provider<int>((_) => throw UnimplementedError());

void main() {
  test('foreach', () async {
    final fncs = <Function>[() => print(1), () => print(2)];
    // ignore: avoid_function_literals_in_foreach_calls
    final all = () => fncs.forEach((f) => f());
    all();
    return;
  });
  test('overrides', () async {
    final container = createContainer(overrides: [
      intProvider.overrideWithValue(1),
    ]);
    final v1 = container.read(intProvider);

    return;
  });
}
