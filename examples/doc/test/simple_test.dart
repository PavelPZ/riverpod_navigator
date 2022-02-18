import 'package:doc/simple.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

ProviderContainer createContainer() {
  final res = ProviderContainer(overrides: RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new));
  addTearDown(res.dispose);
  return res;
}

void main() {
  test('navigation test', () async {
    final container = createContainer();
    final start = DateTime.now();

    Future navigTest(Future action(), String expected) async {
      await action();
      print('${DateTime.now().difference(start).inMilliseconds} msec ($expected)');
      await container.pump();
      expect(container.navigator.navigationStack2Url, expected);
    }

    await navigTest(() => container.navigator.toHome(), 'home');

    await navigTest(() => container.navigator.toPage('Page'), 'home/page;title=Page');

    await navigTest(() => container.navigator.pop(), 'home');

    await navigTest(() => container.navigator.push(PageSegment(title: 'Page2')), 'home/page;title=Page2');

    await navigTest(() => container.navigator.replaceLast((_) => PageSegment(title: 'Page3')), 'home/page;title=Page3');

    return;
  });
}
