import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() => runApp(
      ProviderScope(
        overrides: providerOverrides([HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );

class HomeSegment extends TypedSegment with AsyncSegment<String> {
  HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars pars) => HomeSegment();
}

class BookSegment extends TypedSegment with AsyncSegment<String> {
  BookSegment({required this.id});
  factory BookSegment.fromUrlPars(UrlPars pars) => BookSegment(id: pars.getInt('id'));
  final int id;

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
              opening: (sNew) => sNew.setAsyncValue(_simulateAsyncResult('Home.opening', 2000)),
            ),
            RRoute<BookSegment>(
              'book',
              BookSegment.fromUrlPars,
              BookScreen.new,
              opening: (sNew) => sNew.setAsyncValue(_simulateAsyncResult('Book ${sNew.id}.opening', 240)),
              replacing: (sOld, sNew) => sNew.setAsyncValue(_simulateAsyncResult('Book ${sOld.id}=>${sNew.id}.replacing', 800)),
              closing: (sOld) => Future.delayed(Duration(milliseconds: 500)),
            ),
          ],
          progressIndicatorBuilder: () => const SpinKitCircle(color: Colors.blue, size: 45),
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
  Future sideEffect() async {
    setIsNavigating(true);
    try {
      await registerProtectedFuture(Future.delayed(Duration(milliseconds: 5000)));
    } finally {
      setIsNavigating(false);
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
  const AppScreen(S segment, this.screenTitle) : super(segment);

  final String screenTitle;

  @override
  Widget buildScreen(context, ref, navigator, appBarLeading) => Scaffold(
        appBar: AppBar(
          title: Text(screenTitle),
          leading: appBarLeading,
        ),
        body: Center(
          child: Column(
            children: [
              for (final w in buildWidgets(navigator)) ...[SizedBox(height: 20), w],
              SizedBox(height: 20),
              Text('Dump actual typed-path: "${navigator.debugSegmentSubpath(segment)}"'),
              SizedBox(height: 20),
              Text('Async result: "${(segment as AsyncSegment<String>).asyncValue}"'),
            ],
          ),
        ),
      );

  List<Widget> buildWidgets(AppNavigator navigator);
}

class HomeScreen extends AppScreen<HomeSegment> {
  const HomeScreen(HomeSegment segment) : super(segment, 'Home');

  @override
  List<Widget> buildWidgets(navigator) => [
        ElevatedButton(
          onPressed: () => navigator.toBook(id: 1),
          child: const Text('Go to Book 1'),
        ),
      ];
}

class BookScreen extends AppScreen<BookSegment> {
  BookScreen(BookSegment segment) : super(segment, 'Book ${segment.id}');

  @override
  List<Widget> buildWidgets(navigator) => [
        ElevatedButton(
          onPressed: navigator.toNextBook,
          child: const Text('Go to next book'),
        ),
        ElevatedButton(
          onPressed: navigator.toHome,
          child: const Text('Go to Home'),
        ),
        ElevatedButton(
          onPressed: navigator.sideEffect,
          child: const Text('Side effect (5000 msec)'),
        ),
      ];
}
