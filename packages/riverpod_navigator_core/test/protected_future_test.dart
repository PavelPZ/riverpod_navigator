@Timeout(Duration(minutes: 30))
import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

DateTime start = DateTime.now();

void doPrint(String m) => print('${DateTime.now().difference(start).inMilliseconds}: $m');

class TestNavigator extends RNavigatorCore {
  TestNavigator(Ref ref) : super(ref, []);

  @override
  FutureOr<TypedPath> appNavigationLogicCore(TypedPath oldNavigationStack, TypedPath ongoingPath) async {
    await Future.delayed(Duration(milliseconds: 1000));
    doPrint('after appNavigationLogicCore');
    return [];
  }
}

class Segment extends TypedSegment {}

void main() {
  test('test login flow', () async {
    start = DateTime.now();
    final container = ProviderContainer(
      overrides: RNavigatorCore.providerOverrides([], TestNavigator.new),
    );
    final navigator = container.read(riverpodNavigatorProvider);
    await container.pump();
    doPrint('start');

    navigator.registerProtectedFuture(Future.delayed(Duration(milliseconds: 2000)).then((value) => doPrint('protectedFuture 2000')));
    navigator.registerProtectedFuture(Future.delayed(Duration(milliseconds: 1500)).then((value) => doPrint('protectedFuture 1500')));
    navigator.registerProtectedFuture(Future.delayed(Duration(milliseconds: 2500)).then((value) => doPrint('protectedFuture 2500')));
    navigator.registerProtectedFuture(Future.value().then((value) => doPrint('protectedFuture none')));
    container.read(ongoingPathProvider.notifier).state = [Segment()];
    await container.pump();
    doPrint('before navigationCompleted');
    await navigator.navigationCompleted;
    doPrint('after navigationCompleted');

    return;
  });
}
