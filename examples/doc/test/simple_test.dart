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
    final navigator = container.read(riverpodNavigatorProvider) as AppNavigator;

    Future navigTest(Future action(), String expected) async {
      final start = DateTime.now();
      await action();
      print('${DateTime.now().difference(start).inMilliseconds} msec ($expected)');
      await container.pump();
      expect(navigator.debugNavigationStack2String, expected);
    }

    await navigTest(() => navigator.toHome(), 'home');

    await navigTest(() => navigator.toPage('Page'), 'home/page;title=Page');

    await navigTest(() => navigator.pop(), 'home');

    await navigTest(() => navigator.push(PageSegment(title: 'Page2')), 'home/page;title=Page2');

    await navigTest(() => navigator.replaceLast(PageSegment(title: 'Page3')), 'home/page;title=Page3');

    return;
  });
}
