@Timeout(Duration(minutes: 30))

import 'dart:convert';

import 'package:books_dart/books_dart.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';
import 'package:test/test.dart';

import 'testLib.dart';

void main() {
  Extensions4Dart(json2Segment: json2Segment);
  test('timer', () async {
    await Future.delayed(Duration(seconds: 2));
    return;
  });
  test('navig to login page', () async {
    final container = createContainer();
    final navigator = container.read(appNavigatorProvider4Model);

    await navigator.toBook(id: 2);
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.toBook(id: 1); // needs login => goto login page
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.loginPageCancel(); // cancel in login page => not logged, goto last page before login needed: toBook(id: 2)
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.toBook(id: 1); // needs login => goto login page
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.loginPageOK(); // ok in login page => logged, goto page which needs login: toBook(id: 1)
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    return;
  });
  test('navigate to login page when logged', () async {
    final container = createContainer();
    final navigator = container.read(appNavigatorProvider4Model);

    await navigator.globalLoginButton();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.loginPageOK();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.navigate([LoginHomeSegment()]); // redircet to home
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    return;
  });
  test('logout when on page which needs login', () async {
    final container = createContainer();
    final navigator = container.read(appNavigatorProvider4Model);

    await navigator.toBook(id: 1);
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.loginPageOK(); // logged, in Book(id: 1)
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.globalLogoutButton(); // refresh => needs login => goto login page
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.loginPageCancel(); // cancel when canceledUrl:null => Home
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    return;
  });
  test('login', () async {
    final container = createContainer();
    final navigator = container.read(appNavigatorProvider4Model);

    await navigator.toBooks();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.globalLoginButton();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.loginPageOK();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.toBook(id: 1);
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    return;
  });
  test('next x prev button in book page', () async {
    final container = createContainer();
    final navigator = container.read(appNavigatorProvider4Model);

    await navigator.globalLoginButton();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.loginPageOK();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.toBook(id: 1);
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.bookNextPrevButton();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.bookNextPrevButton();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.bookNextPrevButton();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.bookNextPrevButton();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.bookNextPrevButton();
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.bookNextPrevButton(isPrev: true);
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    await navigator.bookNextPrevButton(isPrev: true);
    await container.pump();
    print(navigator.getActualTypedPathAsString());

    return;
  });
  test('key', () {
    final key = BookSegment(id: 123).key;
    // ignore: unused_local_variable
    final key2 = json.encode(BookSegment(id: 123));
    expect(key, '{"id":123,"runtimeType":"book"}');
    return;
  });
}
