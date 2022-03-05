import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() => runApp(
      ProviderScope(
        // home=path and navigator constructor are required
        overrides: providerOverrides(const [HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );

class HomeSegment extends TypedSegment {
  const HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars pars) => const HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  factory BookSegment.fromUrlPars(UrlPars pars) => BookSegment(id: pars.getInt('id'));
  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);

  final int id;
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            /// 'home' and 'book' strings are used in web URL, e.g. 'home/book;id=2'
            /// fromUrlPars is used to decode URL to segment
            /// HomeScreen.new and BookScreen.new are screen builders for a given segment
            /// screenTitle is not mandatory but allows a general solution e.g. for [AppBar.title]
            RRoute<HomeSegment>(
              'home',
              HomeSegment.fromUrlPars,
              HomeScreen.new,
              screenTitle: (_) => 'Home',
            ),
            RRoute<BookSegment>(
              'book',
              BookSegment.fromUrlPars,
              BookScreen.new,
              screenTitle: (segment) => 'Book ${segment.id}',
            ),
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

class HomeScreen extends RScreenWithScaffold<AppNavigator, HomeSegment> {
  const HomeScreen(HomeSegment segment) : super(segment);

  @override
  Widget buildBody(ref, navigator) => Center(
        child: Column(
          children: [
            for (var i = 1; i < 4; i++) ...[
              const SizedBox(height: 30),
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
      );
}

class BookScreen extends RScreenWithScaffold<AppNavigator, BookSegment> {
  const BookScreen(BookSegment segment) : super(segment);

  @override
  Widget buildBody(ref, navigator) => Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => ref.read(navigatorProvider).replaceLast<BookSegment>((last) => BookSegment(id: last.id + 1)),
              child: const Text('Go to next book'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => ref.read(navigatorProvider).navigate([HomeSegment()]),
              child: const Text('Go to home'),
            ),
          ],
        ),
      );
}
