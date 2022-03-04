import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() => runApp(
      ProviderScope(
        overrides: providerOverrides([HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );

class HomeSegment extends TypedSegment {
  HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars pars) => HomeSegment();
  @override
  final asyncHolder = AsyncHolder<String>();
}

class PageSegment extends TypedSegment {
  PageSegment({required this.id});
  factory PageSegment.fromUrlPars(UrlPars pars) => PageSegment(id: pars.getInt('id'));
  final int id;
  @override
  final asyncHolder = AsyncHolder<String>();

  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);
}

/// helper extension for testing
extension ProviderContainerEx on ProviderContainer {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoute<HomeSegment>(
              'home',
              HomeSegment.fromUrlPars,
              HomeScreen.new,
              screenTitle: (segment) => 'Home',
              opening: (newSegment) => _simulateAsyncResult('Home.creating', 2000),
            ),
            RRoute<PageSegment>(
              'page',
              PageSegment.fromUrlPars,
              PageScreen.new,
              screenTitle: (segment) => 'Page ${segment.id}',
              opening: (newSegment) => _simulateAsyncResult('Page.creating', 240),
              replacing: (oldSegment, newSegment) => _simulateAsyncResult('Page.merging', 800),
              closing: null,
            ),
          ],
        );

  // It is good practice to place the code for all events specific to navigation in AppNavigator.
  // These can then be used not only for writing screen widgets, but also for testing.

  /// navigate to page
  Future toPage({required int id}) => navigate([HomeSegment(), PageSegment(id: id)]);

  /// navigate to next page
  Future toNextPage() => replaceLast<PageSegment>((old) => PageSegment(id: old.id + 1));

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);

  /// sideEffect
  Future sideEffect() => registerProtectedFuture(Future.delayed(Duration(milliseconds: 5000)));

  /// multi sideEffect
  Future multiSideEffect() async {
    blockGui(true);
    try {
      await registerProtectedFuture(Future.delayed(Duration(milliseconds: 5000)));
    } finally {
      blockGui(false);
    }
  }
}

// simulates an action such as loading external data or saving to external storage
Future<String> _simulateAsyncResult(String asyncResult, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return '$asyncResult: async result after $msec msec';
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

/// common app screen
abstract class AppScreen<S extends TypedSegment> extends RScreen<AppNavigator, S> {
  const AppScreen(S segment) : super(segment);

  @override
  Widget buildScreen(ref, navigator, appBarLeading) => Scaffold(
        appBar: AppBar(
          title: Text(navigator.screenTitle(segment)),
          leading: appBarLeading,
        ),
        body: Center(
          child: Column(
            children: [
              for (final w in buildWidgets(navigator)) ...[SizedBox(height: 20), w],
              SizedBox(height: 20),
              Text('Dump actual typed-path: "${navigator.debugSegmentSubpath(segment)}"'),
              if (segment.asyncHolder != null) ...[
                SizedBox(height: 20),
                Text('Async result: "${segment.asyncHolder!.value}"'),
              ]
            ],
          ),
        ),
      );

  List<Widget> buildWidgets(AppNavigator navigator);
}

class HomeScreen extends AppScreen<HomeSegment> {
  const HomeScreen(HomeSegment segment) : super(segment);

  @override
  List<Widget> buildWidgets(navigator) => [
        ElevatedButton(
          onPressed: () => navigator.toPage(id: 1),
          child: const Text('Go to Page 1'),
        ),
      ];
}

class PageScreen extends AppScreen<PageSegment> {
  const PageScreen(PageSegment segment) : super(segment);

  @override
  List<Widget> buildWidgets(navigator) => [
        ElevatedButton(
          onPressed: navigator.toNextPage,
          child: const Text('Go to next page'),
        ),
        ElevatedButton(
          onPressed: navigator.toHome,
          child: const Text('Go to home'),
        ),
        ElevatedButton(
          onPressed: navigator.sideEffect,
          child: const Text('Side effect (5000 msec)'),
        ),
        ElevatedButton(
          onPressed: navigator.multiSideEffect,
          child: const Text('Multi side effect (5000 msec)'),
        )
      ];
}
