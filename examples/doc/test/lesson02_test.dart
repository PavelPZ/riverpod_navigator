import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';
import 'package:test/test.dart';

// ignore: avoid_relative_lib_imports
import '../lib/src/lesson02/dart_lesson02.dart';

ProviderContainer createContainer() {
  final res = ProviderContainer(overrides: [
    config4DartProvider.overrideWithValue(config4DartCreator()),
  ]);
  addTearDown(res.dispose);
  return res;
}

void main() {
  test('no flutter dependency', () async {
    final start = DateTime.now();
    await Future.delayed(Duration(seconds: 1));
    final end = DateTime.now();
    expect(end.difference(start).inMilliseconds >= 1000, true);
  });

  test('navigation test', () async {
    final container = createContainer();
    final navigator = container.readNavigator();

    navigator.toBook(id: 3);
    await container.pump();
    expect(navigator.debugTypedPath2String(), 'home/books/book;id=3');

    navigator.toBooks();
    await container.pump();
    expect(navigator.debugTypedPath2String(), 'home/books');

    navigator.toHome();
    await container.pump();
    expect(navigator.debugTypedPath2String(), 'home');

    await navigator.pop();
    await container.pump();
    expect(navigator.debugTypedPath2String(), 'home');

    navigator.toBook(id: 2);
    await container.pump();
    expect(navigator.debugTypedPath2String(), 'home/books/book;id=2');

    await navigator.pop();
    await container.pump();
    expect(navigator.debugTypedPath2String(), 'home/books');

    await navigator.push(BookSegment(id: 1));
    await container.pump();
    expect(navigator.debugTypedPath2String(), 'home/books/book;id=1');
    return;
  });
}
