import 'package:doc/login_flow.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

ProviderContainer createContainer() {
  final res = ProviderContainer(
      overrides: providerOverrides([HomeSegment()], AppNavigator.new,
          dependsOn: [isLoggedProvider]));
  addTearDown(res.dispose);
  return res;
}

void main() {
  test('navigation test', () async {
    final container = createContainer();
    final navigator = container.read(navigatorProvider) as AppNavigator;
    final start = DateTime.now();

    Future navigTest(Future action(), String expected) async {
      await action();
      print(
          '${DateTime.now().difference(start).inMilliseconds} msec ($expected)');
      await container.pump();
      expect(navigator.navigationStack2Url, expected);
      // print(navigator.debugTypedPath2String());
    }

    await navigTest(navigator.toHome, 'home');

    // navigate to book 3, book 3 needs login => redirected to login page
    await navigTest(() => navigator.toBook(id: 3),
        'login;loggedUrl=home%2Fbook%3Bid%3D3;canceledUrl=home');

    // confirm login => redirect to book 3
    await navigTest(() => navigator.loginScreenOK(), 'home/book;id=3');

    // to next book 4
    await navigTest(navigator.toNextBook, 'home/book;id=4');

    // to next book 5
    await navigTest(navigator.toNextBook, 'home/book;id=5');

    // logout, but book needs login => redirected to login page
    await navigTest(() => navigator.onLogout(),
        'login;loggedUrl=home%2Fbook%3Bid%3D5;canceledUrl=');

    // cancel login => redirect to home
    await navigTest(() => navigator.loginScreenCancel(), 'home');

    return;
  });
}
