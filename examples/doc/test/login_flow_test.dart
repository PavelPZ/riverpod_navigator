import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

// ignore: avoid_relative_lib_imports
import '../lib/src/login_flow.dart';

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
      // print(navigator.debugTypedPath2String());
    }

    await navigTest(() => navigator.navigate([HomeSegment()]), 'home');

    // navigate to book 3, book 3 needs login => redirected to login page
    await navigTest(() => navigator.navigate([HomeSegment(), BookSegment(id: 3)]), 'login;loggedUrl=home%2Fbook%3Bid%3D3;canceledUrl=home');

    // confirm login => redirect to book 3
    await navigTest(() => navigator.okOnloginPage(), 'home/book;id=3');

    // to next book 4
    await navigTest(() => navigator.gotoNextBook(), 'home/book;id=4');

    // to next book 5
    await navigTest(() => navigator.gotoNextBook(), 'home/book;id=5');

    // logout, but book needs login => redirected to login page
    await navigTest(() => navigator.globalLogoutButton(), 'login;loggedUrl=home%2Fbook%3Bid%3D5;canceledUrl=');

    // cancel login => redirect to home
    await navigTest(() => navigator.cancelOnloginPage(), 'home');

    return;
  });
}
