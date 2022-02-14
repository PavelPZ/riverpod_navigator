@Timeout(Duration(minutes: 30))
import 'dart:async';

import 'package:r_navigator_core/r_navigator_core.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

final loginProvider = StateProvider<bool>((_) => throw UnimplementedError());

class TestNavigator extends RNavigatorCore {
  TestNavigator(Ref ref, {this.delayMsec, this.isError = false}) : super(ref, dependsOn: [loginProvider]);

  static List<Override> initProviders(TestNavigator navigator(Ref ref)) => [
        loginProvider.overrideWithValue(StateController<bool>(false)),
        ...RNavigatorCore.initProviders([Home()], navigator),
      ];

  final int? delayMsec;
  final bool isError;

  @override
  FutureOr<TypedPath> appNavigationLogicCore(TypedPath ongoingPath) {
    if (delayMsec == null) {
      if (isError) throw 'SYNC ERROR';
      return ongoingPath;
    } else {
      return Future.delayed(Duration(milliseconds: delayMsec!)).then<TypedPath>((value) => isError ? throw 'ASYNC ERROR' : ongoingPath);
    }
  }

  // @override
  // FutureOr<TypedPath> appNavigationLogicCore(TypedPath ongoingPath) async {
  //   throw 'ASYNC ERROR';
  // }
}

class Home extends TypedSegment {
  @override
  String toString() => 'home';
}

class Books extends TypedSegment {
  @override
  String toString() => 'books';
}

class Book extends TypedSegment {
  Book({required this.id});
  final int id;
  @override
  String toString() => 'book;id=$id';
}

extension TypedPathEx on TypedPath {
  String toPath() => map((s) => s.toString()).join('/');
}

void main() {
  test('sync', () async {
    final container = ProviderContainer(overrides: TestNavigator.initProviders((ref) => TestNavigator(ref)));
    final navigator = container.read(riverpodNavigatorProvider);

    await container.pump();
    await navigator.navigationCompleted;
    final p1 = container.read(navigationStackProvider).toPath();
    expect(p1, 'home');

    container.read(ongoingPathProvider.notifier).state = [Home(), Books(), Book(id: 1)];
    await container.pump();
    await navigator.navigationCompleted;
    final p2 = container.read(navigationStackProvider).toPath();
    expect(p2, 'home/books/book;id=1');
    return;
  });

  test('sync error', () async {
    final container = ProviderContainer(overrides: TestNavigator.initProviders((ref) => TestNavigator(ref, isError: true)));
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
    final container = ProviderContainer(overrides: TestNavigator.initProviders((ref) => TestNavigator(ref, delayMsec: 1000)));
    final navigator = container.read(riverpodNavigatorProvider);

    await container.pump();
    await navigator.navigationCompleted;
    final p1 = container.read(navigationStackProvider).toPath();
    expect(p1, 'home');

    container.read(ongoingPathProvider.notifier).state = [Home(), Books(), Book(id: 1)];
    await container.pump();
    await navigator.navigationCompleted;
    final p2 = container.read(navigationStackProvider).toPath();
    expect(p2, 'home/books/book;id=1');
    return;
  });

  test('async, enother event', () async {
    final container = ProviderContainer(overrides: TestNavigator.initProviders((ref) => TestNavigator(ref, delayMsec: 1000)));
    final navigator = container.read(riverpodNavigatorProvider);

    await container.pump();
    await navigator.navigationCompleted;
    final p1 = container.read(navigationStackProvider).toPath();
    expect(p1, 'home');

    for (var i = 0; i < 3; i++) {
      container.read(ongoingPathProvider.notifier).state = [Home(), Books(), Book(id: 1)];
      await container.pump();

      await Future.delayed(Duration(milliseconds: 300));
      container.read(ongoingPathProvider.notifier).state = [Home()];
      await Future.delayed(Duration(milliseconds: 300));
      container.read(ongoingPathProvider.notifier).state = [Home(), Books(), Book(id: 1)];
      container.read(loginProvider.notifier).update((s) => !s);
      container.read(ongoingPathProvider.notifier).state = [Home(), Books()];

      await navigator.navigationCompleted;
      final p3 = container.read(navigationStackProvider).toPath();
      expect(p3, 'home/books');
    }
    return;
  });

  test('async error', () async {
    final container = ProviderContainer(overrides: TestNavigator.initProviders((ref) => TestNavigator(ref, delayMsec: 1000, isError: true)));
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

  test('CancelableOperation', () async {
    // FutureOr<String> async1(String value) async {
    //   await Future.delayed(Duration(milliseconds: 1000));
    //   return 'value';
    // }

    // FutureOr<String> async2(String value) => Future.delayed(Duration(milliseconds: 900)).then((value) => throw 'ERROR: async 2');

    // FutureOr<String> async3(String value) async {
    //   await Future.delayed(Duration(milliseconds: 900));
    //   throw 'ERROR: async 3';
    // }

    // FutureOr<String> async4(String value) => Future.delayed(Duration(milliseconds: 900)).then((value) => Future.error('ERROR: async 4'));

    // FutureOr<String> sync1(String value) => value;

    // FutureOr<String> sync2(String value) => throw 'ERROR: sync 2';

    // final appLogics = [async1, async2, async3, async4, sync1, sync2];

    // for (final appLogic in appLogics) {
    //   final completer = Completer<String>();
    //   var runnerActive = false;
    //   appLogic('STEP 1');
    //   await Future.delayed(Duration(milliseconds: 500));
    //   appLogic('STEP 2');
    // }

    // var isCompleted = false;

    // while (!isCompleted) {
    //   final res = appLogic();
    //   if (res is Future) await res;
    // }

    // final future = Completer();
    // final result = 'xxx';
    // final FutureOr futureOr = result;
    // //final FutureOr futureOr = future.future;

    // if (futureOr is Future) {
    //   final op = CancelableOperation.fromFuture(futureOr);
    //   final vo = op.valueOrCancellation('wwwww');
    // }
  });
}
