import 'package:doc/login_flow.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

ProviderContainer createContainer() {
  final res = ProviderContainer(overrides: providerOverrides([HomeSegment()], AppNavigator.new, dependsOn: [isLoggedProvider]));
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
      // print(navigator.debugTypedPath2String());
    }

    await navigTest(() => container.navigator.navigate([HomeSegment()]), 'home');

    // navigate to book 3, book 3 needs login => redirected to login page
    await navigTest(
        () => container.navigator.navigate([HomeSegment(), BookSegment(id: 3)]), 'login;loggedUrl=home%2Fbook%3Bid%3D3;canceledUrl=home');

    // confirm login => redirect to book 3
    await navigTest(() => container.navigator.loginScreenOK(), 'home/book;id=3');

    // to next book 4
    await navigTest(() => container.navigator.gotoNextBook(), 'home/book;id=4');

    // to next book 5
    await navigTest(() => container.navigator.gotoNextBook(), 'home/book;id=5');

    // logout, but book needs login => redirected to login page
    await navigTest(() => container.navigator.onLogout(), 'login;loggedUrl=home%2Fbook%3Bid%3D5;canceledUrl=');

    // cancel login => redirect to home
    await navigTest(() => container.navigator.loginScreenCancel(), 'home');

    return;
  });
}
