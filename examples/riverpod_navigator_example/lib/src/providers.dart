import 'package:riverpod/riverpod.dart';

import 'app/app.dart';
import 'navigator.dart';
import 'routerDelegate.dart';

// ********************************************
// TypedPath changing
// ********************************************

/// Riverpod provider which provides actual [TypedPath] to whole app
///
/// Do not watch for it, it sometimes changes two times during single navig calculation
/// (e.g. when [RiverpodNavigator.appNavigationLogic] performs redirect).
final workingTypedPathProvider = StateProvider<TypedPath>((_) => []);

/// Helper provider. When its value changed, navigation calculation starts, see [appNavigationLogicProvider]:
///
/// Basically, for workingTypedPathProvider we need possibility to changing state WITHOUT calling its listeners
/// It is no possible so we hack it by means of flag4actualTypedPathChangeProvider.
final flag4actualTypedPathChangeProvider = StateProvider<int>((_) => 0);

final appNavigationLogicProvider = Provider<TypedPath>((ref) {
  ref.watch(flag4actualTypedPathChangeProvider);
  final routerDelegate = ref.read(riverpodRouterDelegateProvider);
  final actualTypedNotifier = ref.read(workingTypedPathProvider.notifier);
  final navigator = ref.read(exampleRiverpodNavigatorProvider);
  // app navigation logic
  final newPath = navigator.appLogic(routerDelegate.currentConfiguration, actualTypedNotifier.state);
  // synchronize with RouterDelegate
  routerDelegate.currentConfiguration = actualTypedNotifier.state = newPath;
  routerDelegate.doNotifyListener();
  return newPath;
});

final exampleRiverpodNavigatorProvider = Provider<ExampleRiverpodNavigator>((ref) => ExampleRiverpodNavigator(ref));

final riverpodRouterDelegateProvider =
    Provider<RiverpodRouterDelegate>((ref) => RiverpodRouterDelegate(ref, ref.read(exampleRiverpodNavigatorProvider)));

final isLoggedProvider = StateProvider((_) => false);
