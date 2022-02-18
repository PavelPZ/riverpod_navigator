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
    final navigator = container.read(riverpodNavigatorProvider);
    final start = DateTime.now();

    Future navigTest(Future action(), String expected) async {
      await action();
      print('${DateTime.now().difference(start).inMilliseconds} msec ($expected)');
      await container.pump();
      expect(navigator.navigationStack2Url, expected);
    }

    await navigTest(() => navigator.navigate([HomeSegment()]), 'home');

    await navigTest(() => navigator.navigate([HomeSegment(), PageSegment(title: 'Page')]), 'home/page;title=Page');

    await navigTest(() => navigator.pop(), 'home');

    await navigTest(() => navigator.push(PageSegment(title: 'Page2')), 'home/page;title=Page2');

    await navigTest(() => navigator.replaceLast((_) => PageSegment(title: 'Page3')), 'home/page;title=Page3');

    return;
  });
}
