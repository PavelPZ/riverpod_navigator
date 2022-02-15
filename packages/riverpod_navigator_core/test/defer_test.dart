@Timeout(Duration(minutes: 30))
import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

import 'model.dart';

final loginProvider = StateProvider<bool>((_) => false);

class TestNavigator extends RNavigatorCore {
  TestNavigator(Ref ref, {this.delayMsec, this.isError = false}) : super(ref);

  final int? delayMsec;
  final bool isError;

  @override
  FutureOr<TypedPath> appNavigationLogicCore(TypedPath ongoingPath, {CToken? cToken}) {
    if (delayMsec == null) {
      if (isError) throw 'SYNC ERROR';
      return ongoingPath;
    } else {
      return Future.delayed(Duration(milliseconds: delayMsec!)).then<TypedPath>((value) {
        if (cToken?.isCanceled == true) return [];
        if (isError) throw 'ASYNC ERROR';
        return ongoingPath;
      });
    }
  }

  // @override
  // FutureOr<TypedPath> appNavigationLogicCore(TypedPath ongoingPath) async {
  //   throw 'ASYNC ERROR';
  // }
}

void main() {
  test('sync', () async {
    final container = ProviderContainer(
        overrides: RNavigatorCore.providerOverrides(
      [HomeSegment()],
      TestNavigator.new,
    ));
    final navigator = container.read(riverpodNavigatorProvider);

    await container.pump();
    await navigator.navigationCompleted;
    final p1 = container.read(navigationStackProvider).toPath();
    expect(p1, '{"runtimeType":"HomeSegment"}');

    container.read(ongoingPathProvider.notifier).state = [HomeSegment(), BookSegment(id: 1)];
    await container.pump();
    await navigator.navigationCompleted;
    final p2 = container.read(navigationStackProvider).toPath();
    expect(p2, '{"runtimeType":"HomeSegment"}/{"runtimeType":"BookSegment","id":1}');
    return;
  });

  test('sync error', () async {
    final container = ProviderContainer(
        overrides: RNavigatorCore.providerOverrides(
      [HomeSegment()],
      (ref) => TestNavigator(ref, isError: true),
    ));
    final navigator = container.read(riverpodNavigatorProvider);

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
        overrides: RNavigatorCore.providerOverrides(
      [HomeSegment()],
      (ref) => TestNavigator(ref, delayMsec: 1000),
    ));
    final navigator = container.read(riverpodNavigatorProvider);

    await container.pump();
    await navigator.navigationCompleted;
    final p1 = container.read(navigationStackProvider).toPath();
    expect(p1, '{"runtimeType":"HomeSegment"}');

    container.read(ongoingPathProvider.notifier).state = [HomeSegment(), BookSegment(id: 1)];
    await container.pump();
    await navigator.navigationCompleted;
    final p2 = container.read(navigationStackProvider).toPath();
    expect(p2, '{"runtimeType":"HomeSegment"}/{"runtimeType":"BookSegment","id":1}');
    return;
  });

  test('async, enother event', () async {
    final container = ProviderContainer(
        overrides: RNavigatorCore.providerOverrides(
      [HomeSegment()],
      (ref) => TestNavigator(ref, delayMsec: 1000),
      dependsOn: [loginProvider],
    ));
    final navigator = container.read(riverpodNavigatorProvider);

    await container.pump();
    await navigator.navigationCompleted;
    final p1 = container.read(navigationStackProvider).toPath();
    expect(p1, '{"runtimeType":"HomeSegment"}');

    for (var i = 0; i < 3; i++) {
      container.read(ongoingPathProvider.notifier).state = [HomeSegment(), BookSegment(id: 1)];
      await container.pump();

      await Future.delayed(Duration(milliseconds: 300));
      container.read(ongoingPathProvider.notifier).state = [HomeSegment()];
      await Future.delayed(Duration(milliseconds: 300));
      container.read(ongoingPathProvider.notifier).state = [HomeSegment(), BookSegment(id: 2)];
      container.read(loginProvider.notifier).update((s) => !s);
      container.read(ongoingPathProvider.notifier).state = [HomeSegment(), BookSegment(id: 3)];

      await navigator.navigationCompleted;
      final p3 = container.read(navigationStackProvider).toPath();
      expect(p3, '{"runtimeType":"HomeSegment"}/{"runtimeType":"BookSegment","id":3}');
    }
    return;
  });

  test('async error', () async {
    final container = ProviderContainer(
        overrides: RNavigatorCore.providerOverrides(
      [HomeSegment()],
      (ref) => TestNavigator(ref, delayMsec: 1000, isError: true),
    ));
    final navigator = container.read(riverpodNavigatorProvider);

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
