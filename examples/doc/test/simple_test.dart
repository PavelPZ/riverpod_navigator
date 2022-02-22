import 'package:doc/simple.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

void main() {
  test('navigation test', () async {
    final container = ProviderContainer(overrides: RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new));
    final navigator = container.read(navigatorProvider);

    Future navigTest(Future action(), String expected) async {
      await action();
      await container.pump();
      expect(navigator.navigationStack2Url, expected);
    }

    await navigTest(() => navigator.navigate([HomeSegment()]), 'home');

    await navigTest(() => navigator.navigate([HomeSegment(), PageSegment(title: 'Page')]), 'home/page;title=Page');

    await navigTest(() => navigator.pop(), 'home');

    await navigTest(() => navigator.push(PageSegment(title: 'Page2')), 'home/page;title=Page2');

    await navigTest(() => navigator.replaceLast<PageSegment>((old) => PageSegment(title: 'X${old.title}')), 'home/page;title=XPage2');

    return;
  });
}
