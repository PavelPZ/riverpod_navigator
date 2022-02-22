import 'package:doc/async.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

ProviderContainer createContainer() {
  final res = ProviderContainer(
      overrides:
          RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new));
  addTearDown(res.dispose);
  return res;
}

void main() {
  test('navigation test', () async {
    final container = createContainer();
    final start = DateTime.now();

    Future navigTest(Future action(), String expected) async {
      await action();
      print(
          '${DateTime.now().difference(start).inMilliseconds} msec ($expected)');
      await container.pump();
      expect(container.navigator.navigationStack2Url, expected);
    }

    await navigTest(() => container.navigator.toHome(), 'home');

    await navigTest(() => container.navigator.toPage(id: 1), 'home/page;id=1');

    await navigTest(() => container.navigator.pop(), 'home');

    await navigTest(
        () => container.navigator.push(PageSegment(id: 2)), 'home/page;id=2');

    await navigTest(
        () => container.navigator.replaceLast((_) => PageSegment(id: 3)),
        'home/page;id=3');

    await navigTest(() => container.navigator.toNextPage(), 'home/page;id=4');

    return;
  });
}
