import 'package:doc/simple.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

void main() {
  test('navigation test', () async {
    final container = ProviderContainer(overrides: riverpodNavigatorOverrides([HomeSegment()], AppNavigator.new));
    final navigator = container.read(navigatorProvider) as AppNavigator;

    Future navigTest(Future action(), String expected) async {
      await action();
      await container.pump();
      expect(navigator.navigationStack2Url, expected);
    }

    await navigTest(navigator.toHome, 'home');

    await navigTest(
      () => navigator.navigate([HomeSegment(), BookSegment(id: 1)]),
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
      navigator.toNextBook,
      'home/book;id=3',
    );

    return;
  });
}
