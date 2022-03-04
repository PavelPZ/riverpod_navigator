import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() => runApp(
      ProviderScope(
        overrides: providerOverrides([HomeSegment()], AppNavigator.new),
        child: App(),
      ),
    );

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

class HomeSegment extends TypedSegment {
  const HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars pars) => HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  factory BookSegment.fromUrlPars(UrlPars pars) => BookSegment(id: pars.getInt('id'));
  final int id;

  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);
}

class AuthorSegment extends TypedSegment {
  const AuthorSegment({required this.id});
  factory AuthorSegment.fromUrlPars(UrlPars pars) => AuthorSegment(id: pars.getInt('id'));
  final int id;

  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);
}

class BooksAuthorsSegment extends TypedSegment {
  const BooksAuthorsSegment();
  // ignore: avoid_unused_constructor_parameters
  factory BooksAuthorsSegment.fromUrlPars(UrlPars pars) => BooksAuthorsSegment();
}

class AppNavigator extends RNavigator {
  /// Constructor for book nested navigator.
  AppNavigator.forBook(Ref ref)
      : super(
          ref,
          [
            RRoute<BookSegment>(
              'book',
              BookSegment.fromUrlPars,
              BookScreen.new,
              screenTitle: (segment) => 'Book ${segment.id}',
            ),
          ],
        );

  /// constructor for author nested navigator
  AppNavigator.forAuthor(Ref ref)
      : super(
          ref,
          [
            RRoute<AuthorSegment>(
              'author',
              AuthorSegment.fromUrlPars,
              AuthorScreen.new,
              screenTitle: (segment) => 'Author ${segment.id}',
            ),
          ],
        );

  // ignore: sort_unnamed_constructors_first
  AppNavigator(Ref ref)
      : super(
          ref,
          [
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
            RRoute<AuthorSegment>(
              'author',
              AuthorSegment.fromUrlPars,
              AuthorScreen.new,
              screenTitle: (segment) => 'Author ${segment.id}',
            ),
            RRoute<BooksAuthorsSegment>(
              'books-authors',
              BooksAuthorsSegment.fromUrlPars,
              BooksAuthorsScreen.new,
              screenTitle: (_) => 'Books and Authors',
            ),
          ],
        );

  // ******* actions used on the screens

  Future toNextBook() => replaceLast<BookSegment>((actualBook) => BookSegment(id: actualBook.id == 5 ? 1 : actualBook.id + 1));

  Future toNextAuthor() =>
      replaceLast<AuthorSegment>((actualAuthor) => AuthorSegment(id: actualAuthor.id == 5 ? 1 : actualAuthor.id + 1));
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
          onPressed: () => navigator.navigate([HomeSegment(), BooksAuthorsSegment()]),
          child: Text('Books & Authors'),
        ),
        Text('Books', style: TextStyle(fontSize: 32)),
        for (var i = 1; i <= count; i++)
          ElevatedButton(
            onPressed: () => navigator.navigate([HomeSegment(), BookSegment(id: i)]),
            child: Text('Book $i'),
          ), // normal page
        Text('Authors', style: TextStyle(fontSize: 32)),
        for (var i = 1; i <= count; i++)
          ElevatedButton(
            onPressed: () => navigator.navigate([HomeSegment(), AuthorSegment(id: i)]),
            child: Text('Author $i'),
          ) // normal page
      ];
}

const count = 3;

class BookScreen extends AppScreen<BookSegment> {
  const BookScreen(BookSegment book) : super(book);

  @override
  List<Widget> buildWidgets(navigator) => [
        ElevatedButton(
          onPressed: navigator.toNextBook,
          child: const Text('Go to next book'),
        ),
      ];
}

class AuthorScreen extends AppScreen<AuthorSegment> {
  const AuthorScreen(AuthorSegment auhor) : super(auhor);

  @override
  List<Widget> buildWidgets(navigator) => [
        ElevatedButton(
          onPressed: navigator.toNextAuthor,
          child: const Text('Go to next author'),
        ),
      ];
}

/// TabBarView screen
class BooksAuthorsScreen extends RScreenHook<AppNavigator, BooksAuthorsSegment> {
  /// TabBarView screen
  const BooksAuthorsScreen(BooksAuthorsSegment booksAuthorsSegment) : super(booksAuthorsSegment);

  @override
  Widget buildScreen(ref, navigator, appBarLeading) {
    /// Remembering RestorePath throughout the widget's lifecycle
    /// Note: *We use **flutter_hooks package** to keep RestorePath instance.
    /// The use of flutter_hooks is not mandatory, it can be implemented using the StatefulWidget*.
    final restoreBook = useMemoized(() => RestorePath());
    final restoreAuthor = useMemoized(() => RestorePath());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: appBarLeading,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Books'),
              Tab(text: 'Authors'),
            ],
          ),
          title: Text(navigator.screenTitle(segment)),
        ),
        body: TabBarView(
          children: [
            ProviderScope(
              // The RestorePath class preserves the last state of the navigator.
              // Used during the next navigator initialization.
              overrides: providerOverrides([BookSegment(id: 2)], AppNavigator.forBook, restorePath: restoreBook),
              child: BooksTab(),
            ),
            ProviderScope(
              overrides: providerOverrides([AuthorSegment(id: 2)], AppNavigator.forAuthor, restorePath: restoreAuthor),
              child: AuthorTab(),
            ),
          ],
        ),
      ),
    );
  }
}
// https://gist.github.com/johnpryan/bbca91e23bbb4d39247fa922533be7c9

class BooksTab extends ConsumerWidget {
  const BooksTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Router(routerDelegate: (ref.read(navigatorProvider) as AppNavigator).routerDelegate);
}

class AuthorTab extends ConsumerWidget {
  const AuthorTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Router(routerDelegate: (ref.read(navigatorProvider) as AppNavigator).routerDelegate);
}
