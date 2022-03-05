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

class BookSegment extends TypedSegment {
  BookSegment({required this.id});
  factory BookSegment.fromUrlPars(UrlPars pars) => BookSegment(id: pars.getInt('id'));
  final int id;
  @override
  final asyncHolder = AsyncHolder<String>();

  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);
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
              screenTitle: (_) => 'Home',
              opening: (newSegment) => _simulateAsyncResult('Home.opening', 2000),
            ),
            RRoute<BookSegment>(
              'page',
              BookSegment.fromUrlPars,
              BookScreen.new,
              screenTitle: (segment) => 'Book ${segment.id}',
              opening: (newSegment) => _simulateAsyncResult('Book.opening', 240),
              replacing: (oldSegment, newSegment) => _simulateAsyncResult('Book.replacing', 800),
              closing: null,
            ),
          ],
        );

  // It is good practice to place the code for all events specific to navigation in AppNavigator.
  // These can then be used not only for writing screen widgets, but also for testing.

  /// navigate to book
  Future toBook({required int id}) => navigate([HomeSegment(), BookSegment(id: id)]);

  /// navigate to next book
  Future toNextBook() => replaceLast<BookSegment>((old) => BookSegment(id: old.id + 1));

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);

  /// sideEffect
  Future sideEffect() => registerProtectedFuture(Future.delayed(Duration(milliseconds: 5000)));

  /// multi sideEffect
  Future multiSideEffect() async {
    absorbPointer(true);
    try {
      await registerProtectedFuture(Future.delayed(Duration(milliseconds: 5000)));
    } finally {
      absorbPointer(false);
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
abstract class AppScreen<S extends TypedSegment> extends RScreenWithScaffold<AppNavigator, S> {
  const AppScreen(S segment) : super(segment);

  @override
  Widget buildBody(ref, navigator) => Center(
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
      );

  List<Widget> buildWidgets(AppNavigator navigator);
}

class HomeScreen extends AppScreen<HomeSegment> {
  const HomeScreen(HomeSegment segment) : super(segment);

  @override
  List<Widget> buildWidgets(navigator) => [
        ElevatedButton(
          onPressed: () => navigator.toBook(id: 1),
          child: const Text('Go to Page 1'),
        ),
      ];
}

class BookScreen extends AppScreen<BookSegment> {
  const BookScreen(BookSegment segment) : super(segment);

  @override
  List<Widget> buildWidgets(navigator) => [
        ElevatedButton(
          onPressed: navigator.toNextBook,
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
