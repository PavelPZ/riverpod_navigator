@Timeout(Duration(minutes: 30))
import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

import 'model.dart';

final loginProvider = StateProvider<bool>((_) => false);

class TestNavigator extends RNavigatorCore {
  TestNavigator(Ref ref, {this.delayMsec, this.isError = false})
      : super(ref, routes);

  final int? delayMsec;
  final bool isError;

  @override
  FutureOr<TypedPath> appNavigationLogicCore(
      TypedPath oldNavigationStack, TypedPath intendedPath) {
    if (delayMsec == null) {
      if (isError) throw 'SYNC ERROR';
      return intendedPath;
    } else {
      return Future.delayed(Duration(milliseconds: delayMsec!))
          .then<TypedPath>((value) {
        if (isError) throw 'ASYNC ERROR';
        return intendedPath;
      });
    }
  }
}

void main() {
  test('sync', () async {
    final container = ProviderContainer(
        overrides: providerOverrides(
      [HomeSegment()],
      TestNavigator.new,
    ));
    final navigator = container.read(navigatorProvider);

    await container.pump();
    await navigator.navigationCompleted;
    final p1 = navigator.navigationStack2Url;
    expect(p1, 'home');

    container.read(intendedPathProvider.notifier).state = [
      HomeSegment(),
      BookSegment(id: 1)
    ];
    await container.pump();
    await navigator.navigationCompleted;
    final p2 = navigator.navigationStack2Url;
    expect(p2, 'home/book;id=1');
    return;
  });

  test('sync error', () async {
    final container = ProviderContainer(
        overrides: providerOverrides(
      [HomeSegment()],
      (ref) => TestNavigator(ref, isError: true),
    ));
    final navigator = container.read(navigatorProvider);

    await container.pump();

    try {
      await navigator.navigationCompleted;
      fail('exception not thrown');
    } on String catch (e) {
      expect(e, 'SYNC ERROR');
    } catch (e) {
      fail('expect String');
    }
    return;
  });

  test('async', () async {
    final container = ProviderContainer(
        overrides: providerOverrides(
      [HomeSegment()],
      (ref) => TestNavigator(ref, delayMsec: 1000),
    ));
    final navigator = container.read(navigatorProvider);

    await container.pump();
    await navigator.navigationCompleted;
    final p1 = navigator.navigationStack2Url;
    expect(p1, 'home');

    container.read(intendedPathProvider.notifier).state = [
      HomeSegment(),
      BookSegment(id: 1)
    ];
    await container.pump();
    await navigator.navigationCompleted;
    final p2 = navigator.navigationStack2Url;
    expect(p2, 'home/book;id=1');
    return;
  });

  test('async, enother event', () async {
    final container = ProviderContainer(
        overrides: providerOverrides(
      [HomeSegment()],
      (ref) => TestNavigator(ref, delayMsec: 1000),
      dependsOn: [loginProvider],
    ));
    final navigator = container.read(navigatorProvider);

    await container.pump();
    await navigator.navigationCompleted;
    final p1 = navigator.navigationStack2Url;
    expect(p1, 'home');

    // for (var i = 0; i < 3; i++) {
    container.read(intendedPathProvider.notifier).state = [
      HomeSegment(),
      BookSegment(id: 1)
    ];
    await container.pump();

    await Future.delayed(Duration(milliseconds: 300));
    container.read(intendedPathProvider.notifier).state = [HomeSegment()];
    await Future.delayed(Duration(milliseconds: 300));
    container.read(intendedPathProvider.notifier).state = [
      HomeSegment(),
      BookSegment(id: 2)
    ];
    container.read(loginProvider.notifier).update((s) => !s);
    container.read(intendedPathProvider.notifier).state = [
      HomeSegment(),
      BookSegment(id: 3)
    ];

    await navigator.navigationCompleted;
    final p3 = navigator.navigationStack2Url;
    expect(p3, 'home/book;id=3');
    // }
    return;
  });

  test('async error', () async {
    final container = ProviderContainer(
        overrides: providerOverrides(
      [HomeSegment()],
      (ref) => TestNavigator(ref, delayMsec: 1000, isError: true),
    ));
    final navigator = container.read(navigatorProvider);

    await container.pump();
    try {
      await navigator.navigationCompleted;
      fail('exception not thrown');
    } on String catch (e) {
      expect(e, 'ASYNC ERROR');
    } catch (e) {
      fail('expect String');
    }
    return;
  });
}
