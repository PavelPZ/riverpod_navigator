import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() => runApp(
      ProviderScope(
        overrides: RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new),
        child: App(),
      ),
    );

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Riverpod Navigator Example',
        routerDelegate: ref.navigator.routerDelegate,
        routeInformationParser: ref.navigator.routeInformationParser,
        debugShowCheckedModeBanner: false,
      );
}

class HomeSegment extends TypedSegment {
  const HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars map) => HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  factory BookSegment.fromUrlPars(UrlPars map) => BookSegment(id: map.getInt('id'));
  final int id;

  @override
  void toUrlPars(UrlPars map) => map.setInt('id', id);
}

class AuthorSegment extends TypedSegment {
  const AuthorSegment({required this.id});
  factory AuthorSegment.fromUrlPars(UrlPars map) => AuthorSegment(id: map.getInt('id'));
  final int id;

  @override
  void toUrlPars(UrlPars map) => map.setInt('id', id);
}

class BooksAuthorsSegment extends TypedSegment {
  const BooksAuthorsSegment();
  // ignore: avoid_unused_constructor_parameters
  factory BooksAuthorsSegment.fromUrlPars(UrlPars map) => BooksAuthorsSegment();
}

/// helper extension for screens
extension WidgetRefApp on WidgetRef {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}

/// helper extension for test
extension RefApp on Ref {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}

class AppNavigator extends RNavigator {
  /// Constructor for book nested navigator.
  AppNavigator.forBook(Ref ref)
      : super(
          ref,
          [
            RRoute<BookSegment>(BookSegment.fromUrlPars, BookScreen.new),
          ],
        );

  /// constructor for author nested navigator
  AppNavigator.forAuthor(Ref ref)
      : super(
          ref,
          [
            RRoute<AuthorSegment>(AuthorSegment.fromUrlPars, AuthorScreen.new),
          ],
        );
  // ignore: sort_unnamed_constructors_first
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoute<HomeSegment>(HomeSegment.fromUrlPars, HomeScreen.new),
            RRoute<BookSegment>(BookSegment.fromUrlPars, BookScreen.new),
            RRoute<AuthorSegment>(AuthorSegment.fromUrlPars, AuthorScreen.new),
            RRoute<BooksAuthorsSegment>(BooksAuthorsSegment.fromUrlPars, BooksAuthorsScreen.new),
          ],
        );

  // ******* actions used on the screens

  Future gotoNextBook() => replaceLast<BookSegment>((actualBook) => BookSegment(id: actualBook.id == 5 ? 1 : actualBook.id + 1));

  Future gotoNextAuthor() => replaceLast<AuthorSegment>((actualAuthor) => AuthorSegment(id: actualAuthor.id == 5 ? 1 : actualAuthor.id + 1));
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PageHelper<AppNavigator>(
        title: 'Home',
        segment: segment,
        buildChildren: (navigator) => [
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
        ],
      );
}

const count = 3;

class BookScreen extends ConsumerWidget {
  const BookScreen(this.book, {Key? key}) : super(key: key);

  final BookSegment book;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PageHelper<AppNavigator>(
        segment: book,
        title: 'Book ${book.id}',
        buildChildren: (navigator) => [
          ElevatedButton(
            onPressed: navigator.gotoNextBook,
            child: const Text('Go to next book'),
          ),
        ],
      );
}

class AuthorScreen extends ConsumerWidget {
  const AuthorScreen(this.book, {Key? key}) : super(key: key);

  final AuthorSegment book;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PageHelper<AppNavigator>(
        segment: book,
        title: 'Author ${book.id}',
        buildChildren: (navigator) => [
          ElevatedButton(
            onPressed: navigator.gotoNextAuthor,
            child: const Text('Go to next author'),
          ),
        ],
      );
}

/// TabBarView screen
class BooksAuthorsScreen extends HookConsumerWidget {
  /// TabBarView screen
  const BooksAuthorsScreen(this.booksAuthorsSegment, {Key? key}) : super(key: key);

  /// TabBarView screen
  final BooksAuthorsSegment booksAuthorsSegment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Remembering RestorePath throughout the widget's lifecycle
    /// Note: *We use **flutter_hooks package** to keep RestorePath instance.
    /// The use of flutter_hooks is not mandatory, it can be implemented using the StatefulWidget*.
    final restoreBook = useMemoized(() => RestorePath());
    final restoreAuthor = useMemoized(() => RestorePath());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Books'),
              Tab(text: 'Authors'),
            ],
          ),
          title: const Text('Books & Authors'),
        ),
        body: TabBarView(
          children: [
            ProviderScope(
              // The RestorePath class preserves the last state of the navigator.
              // Used during the next navigator initialization.
              overrides: RNavigatorCore.providerOverrides([BookSegment(id: 2)], AppNavigator.forBook, restorePath: restoreBook),
              child: BooksTab(),
            ),
            ProviderScope(
              overrides: RNavigatorCore.providerOverrides([AuthorSegment(id: 2)], AppNavigator.forAuthor, restorePath: restoreAuthor),
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
  Widget build(BuildContext context, WidgetRef ref) => Router(routerDelegate: ref.navigator.routerDelegate);
}

class AuthorTab extends ConsumerWidget {
  const AuthorTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Router(routerDelegate: ref.navigator.routerDelegate);
}

class PageHelper<N extends RNavigator> extends ConsumerWidget {
  const PageHelper({Key? key, required this.segment, required this.title, required this.buildChildren}) : super(key: key);

  final TypedSegment segment;

  final String title;

  final List<Widget> Function(N) buildChildren;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.navigator as N;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: (() {
            final res = <Widget>[SizedBox(height: 20)];
            for (final w in buildChildren(navigator)) {
              res.addAll([w, SizedBox(height: 20)]);
            }
            res.addAll([SizedBox(height: 20), Text('Dump actual typed-path: "${navigator.debugSegmentSubpath(segment)}"')]);
            // if (segment.asyncActionResult != null) res.addAll([SizedBox(height: 20), Text('Async result: "${segment.asyncActionResult}"')]);
            return res;
          })(),
        ),
      ),
    );
  }
}
