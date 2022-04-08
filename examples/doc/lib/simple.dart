import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() => runApp(
      ProviderScope(
        // home path and navigator constructor are required
        overrides: riverpodNavigatorOverrides(const [HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );

class HomeSegment extends TypedSegment {
  const HomeSegment();

  /// used for creating HomeSegment from URL pars
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.decode(UrlPars pars) => const HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});

  /// used for creating BookSegment from URL pars
  factory BookSegment.decode(UrlPars pars) => BookSegment(id: pars.getInt('id'));

  /// used for encoding BookSegment props to URL pars
  @override
  void encode(UrlPars pars) => pars.setInt('id', id);

  final int id;
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            /// 'home' and 'book' strings are used in web URL, e.g. 'home/book;id=2'
            /// decode is used to decode URL to segment
            /// HomeScreen.new and BookScreen.new are screen builders for a given segment
            RRoute<HomeSegment>(
              'home',
              HomeSegment.decode,
              HomeScreen.new,
            ),
            RRoute<BookSegment>(
              'book',
              BookSegment.decode,
              BookScreen.new,
            ),
          ],
          progressIndicatorBuilder: () => const SpinKitCircle(color: Colors.blue, size: 45),
        );

  // It is good practice to place the code for all events specific to navigation in AppNavigator.
  // These can then be used not only for writing screen widgets, but also for testing.

  /// navigate to next book
  Future toNextBook() => replaceLast<BookSegment>((last) => BookSegment(id: last.id + 1));

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);
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

class HomeScreen extends RScreen<AppNavigator, HomeSegment> {
  const HomeScreen(HomeSegment segment) : super(segment);

  @override
  Widget buildScreen(context, ref, navigator, appBarLeading) => Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          leading: appBarLeading,
        ),
        body: Center(
          child: Column(
            children: [
              for (var i = 1; i < 4; i++) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => navigator.navigate([
                    HomeSegment(),
                    BookSegment(id: i),
                    if (i > 1) BookSegment(id: 10 + i),
                    if (i > 2) BookSegment(id: 100 + i),
                  ]),
                  child: Text('Go to Book: [$i${i > 1 ? ', 1$i' : ''}${i > 2 ? ', 10$i' : ''}]'),
                ),
              ]
            ],
          ),
        ),
      );
}

class BookScreen extends RScreen<AppNavigator, BookSegment> {
  const BookScreen(BookSegment segment) : super(segment);

  @override
  Widget buildScreen(context, ref, navigator, appBarLeading) => Scaffold(
        appBar: AppBar(
          title: Text('Book ${segment.id}'),
          leading: appBarLeading,
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: navigator.toNextBook,
                child: const Text('Go to next book'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: navigator.toHome,
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      );
}
