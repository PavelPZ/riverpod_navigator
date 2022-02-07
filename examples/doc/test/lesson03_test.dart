import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';
import 'package:test/test.dart';

// ignore: avoid_relative_lib_imports
import '../lib/src/lesson03/lesson03.dart';

ProviderContainer createContainer() {
  final res = ProviderContainer(overrides: [
    riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new),
  ]);
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
      expect(navigator.debugTypedPath2String(), expected);
    }

    //**********
    // test without the need to log in (book with even id only)
    //**********

    await navigTest(() => navigator.toBook(id: 0), 'home/books/book;id=0');

    await navigTest(() => navigator.toBooks(), 'home/books');

    await navigTest(() => navigator.toHome(), 'home');

    await navigTest(() => navigator.pop(), 'home');

    await navigTest(() => navigator.toBook(id: 2), 'home/books/book;id=2');

    await navigTest(() => navigator.pop(), 'home/books');

    await navigTest(() => navigator.push(BookSegment(id: 4)), 'home/books/book;id=4');

    await navigTest(() => navigator.replaceLast(BookSegment(id: 0)), 'home/books/book;id=0');

    //**********
    // log in tests
    //**********

    await navigTest(() => navigator.toHome(), 'home');

    // navigate to book 3, book 3 needs login => redirected to login page
    await navigTest(() => navigator.toBook(id: 3), 'login-home;loggedUrl=home%2Fbooks%2Fbook%3Bid%3D3;canceledUrl=home');

    // confirm login => redirect to book 3
    await navigTest(() => navigator.loginPageOK(), 'home/books/book;id=3');

    // to previous book 2
    await navigTest(() => navigator.bookNextPrevButton(isPrev: true), 'home/books/book;id=2');

    // to previous book 1
    await navigTest(() => navigator.bookNextPrevButton(isPrev: true), 'home/books/book;id=1');

    // logout, but book needs login => redirected to login page
    await navigTest(() => navigator.globalLogoutButton(), 'login-home;loggedUrl=home%2Fbooks%2Fbook%3Bid%3D1;canceledUrl=');

    // cancel login => redirect to home
    await navigTest(() => navigator.loginPageCancel(), 'home');

    return;
  });
}
