// ignore_for_file: unused_local_variable

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

final providerA = StateProvider<int>((_) => 1);
final providerB = StateProvider<int>((_) => 2);

final providerAB = FutureProvider<Tuple2<int, int>>((ref) async {
  final a = ref.watch(providerA);
  final b = ref.watch(providerB);
  if (a > 2) throw Exception('a > 2');
  return Tuple2(a, b);
});

void main() {
  test('test', () async {
    final container = ProviderContainer();
    final t1 = await container.read(providerAB.future);
    container.read(providerA.notifier).state++;
    await container.pump();
    final t2 = await container.read(providerAB.future);
    container.read(providerA.notifier).state++;
    await container.pump();
    try {
      final t3 = await container.read(providerAB.future);
    } catch (e) {
      container.read(providerA.notifier).state--;
      await container.pump();
      final t4 = await container.read(providerAB.future);
      return;
    }
    return;
  });
}
