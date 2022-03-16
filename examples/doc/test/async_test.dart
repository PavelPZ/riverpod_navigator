import 'package:doc/async.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

ProviderContainer createContainer() {
  final res = ProviderContainer(overrides: providerOverrides([HomeSegment()], AppNavigator.new));
  addTearDown(res.dispose);
  return res;
}

void main() {
  test('navigation test', () async {
    final container = createContainer();
    final start = DateTime.now();
    final navigator = container.read(navigatorProvider) as AppNavigator;

    Future navigTest(Future action(), String expected) async {
      await action();
      print('${DateTime.now().difference(start).inMilliseconds} msec ($expected)');
      await container.pump();
      expect(navigator.navigationStack2Url, expected);
    }

    await navigTest(
      navigator.toHome,
      'home',
    );

    await navigTest(
      () => navigator.toBook(id: 1),
      'home/book;id=1',
    );

    await navigTest(
      navigator.pop,
      'home',
    );

    await navigTest(
      () => navigator.push(BookSegment(id: 2)),
      'home/book;id=2',
    );

    await navigTest(
      () => navigator.replaceLast((_) => BookSegment(id: 3)),
      'home/book;id=3',
    );

    await navigTest(
      navigator.toNextBook,
      'home/book;id=4',
    );

    return;
  });
}
