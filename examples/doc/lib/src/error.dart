import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() => runApp(
      ProviderScope(
        overrides: [navigatorProvider.overrideWithProvider(Provider(RootNavigator.new))],
        child: App(),
      ),
    );
typedef NavigatorCreator = Navigator Function(Ref);

abstract class Navigator {
  Navigator(this.ref);
  final Ref ref;
}

final navigatorProvider = Provider<Navigator>((_) => throw UnimplementedError());
final counterProvider = StateProvider<int>((_) => 1);

class RootNavigator extends Navigator {
  RootNavigator(Ref ref) : super(ref);
}

class InnerNavigator extends Navigator {
  InnerNavigator(Ref ref) : super(ref);
}

class App extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.read(navigatorProvider);
    assert(navigator is RootNavigator);
    // ref for root ProviderScope
    ref.read(counterProvider.notifier).state = 2;
    return ProviderScope(
      overrides: [
        // counterProvider, // MISSING THIS => ERROR BELLOW
        navigatorProvider.overrideWithProvider(Provider(InnerNavigator.new)),
      ],
      child: InnerApp(),
    );
  }
}

class InnerApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.read(navigatorProvider);

    // ref for nested ProviderScope
    final counter = ref.read(counterProvider);
    assert(counter == 1); // <============== ERROR HERE without "counterProvider" in nested ProviderScope.overrides

    assert(navigator is InnerNavigator);
    return SizedBox();
  }
}
