@Timeout(Duration(minutes: 30))
import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';
import 'package:test/test.dart';

import 'model.dart';

final isLoggedProvider = StateProvider<bool>((_) => false);

class TestNavigator extends RNavigatorCore {
  TestNavigator(Ref ref) : super(ref, routes);

  @override
  FutureOr<TypedPath> appNavigationLogicCore(
      TypedPath oldNavigationStack, TypedPath ongoingPath) {
    final userIsLogged = ref.read(isLoggedProvider);

    // if user is not logged-in and some of the ongoing screen needs login => redirect to LoginScreen
    if (!userIsLogged && ongoingPath.any((segment) => needsLogin(segment))) {
      return [LoginSegment()];
    }

    // user is logged and LogginScreen is going to display => redirect to HomeScreen
    if (userIsLogged && ongoingPath.any((segment) => segment is LoginSegment)) {
      return [HomeSegment()];
    }

    // no redirection is needed
    return ongoingPath;
  }

  bool needsLogin(TypedSegment segment) =>
      segment is BookSegment && segment.id.isOdd;
}

void main() {
  test('test login flow', () async {
    final container = ProviderContainer(
      overrides: providerOverrides(
        [HomeSegment()],
        TestNavigator.new,
        dependsOn: [isLoggedProvider],
      ),
    );
    final navigator = container.read(navigatorProvider);

    //*****************************
    // Helpers
    //*****************************
    Future changeState(void action(), String expected) async {
      action();
      await navigator.navigationCompleted;
      await container.pump();
      final stringPath = navigator.navigationStack2Url;
      expect(stringPath, expected);
    }

    Future changeOngoing(TypedPath path, String expected) => changeState(
          () => container.read(ongoingPathProvider.notifier).state = path,
          expected,
        );

    //*****************************
    // Test
    //*****************************

    // book with even id => load book
    await changeOngoing([HomeSegment(), BookSegment(id: 2)], 'home/book;id=2');

    // book with odd id => redirect to login
    await changeOngoing([HomeSegment(), BookSegment(id: 1)], 'login');

    // log in => book loaded
    await changeState(() {
      container.read(ongoingPathProvider.notifier).state = [
        HomeSegment(),
        BookSegment(id: 1)
      ];
      container.read(isLoggedProvider.notifier).state = true;
    }, 'home/book;id=1');

    // logoff => redirect to login
    await changeState(
        () => container.read(isLoggedProvider.notifier).state = false, 'login');

    // login screen visible. When set login state to true => redirect to home
    await changeState(
        () => container.read(isLoggedProvider.notifier).state = true, 'home');

    return;
  });
}
