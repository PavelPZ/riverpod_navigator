import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() => runApp(
      ProviderScope(
        // home=path and navigator constructor are required
        overrides: RNavigatorCore.providerOverrides(const [HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );

class HomeSegment extends TypedSegment {
  const HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars pars) => const HomeSegment();
}

class PageSegment extends TypedSegment {
  const PageSegment({required this.title});
  factory PageSegment.fromUrlPars(UrlPars pars) => PageSegment(title: pars.getString('title'));
  final String title;

  @override
  void toUrlPars(UrlPars pars) => pars.setString('title', title);
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoute<HomeSegment>(HomeSegment.fromUrlPars, HomeScreen.new), // build a HomeScreen for HomeSegment
            RRoute<PageSegment>(PageSegment.fromUrlPars, PageScreen.new), // build a PageScreen for PageSegment
          ],
        );
}

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.read(navigatorProvider) as AppNavigator;
    return MaterialApp.router(
      title: 'Riverpod Navigator Example',
      routerDelegate: navigator.routerDelegate,
      routeInformationParser: navigator.routeInformationParser,
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => ref.read(navigatorProvider).navigate([HomeSegment(), PageSegment(title: 'Page')]),
                child: const Text('Go to page'),
              ),
            ],
          ),
        ),
      );
}

class PageScreen extends ConsumerWidget {
  const PageScreen(this.segment, {Key? key}) : super(key: key);

  final PageSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: Text(segment.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => ref.read(navigatorProvider).navigate([HomeSegment()]),
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      );
}
