# Nested navigation

In the following example, the same navigator is used in three contexts:
- as the root navigator for the application
- as a nested navigator on the "Books" tab in the TabBarView widget
- as a nested navigator on the "Authors" tab in the TabBarView widget

The nested navigator has a "RestorePath restorePath" parameter: its purpose is to remember the state of the navigator during Tab's switching.

```dart
class AppNavigator extends RNavigator {
  /// Constructor for book nested navigator.
  AppNavigator.forBook(Ref ref)
      : super(
          ref,
          [
            RRoute<BookSegment>('book', BookSegment.fromUrlPars, BookScreen.new),
          ],
        );

  /// constructor for author nested navigator
  AppNavigator.forAuthor(Ref ref)
      : super(
          ref,
          [
            RRoute<AuthorSegment>('author', AuthorSegment.fromUrlPars, AuthorScreen.new),
          ],
        );
```

```dart
/// TabBarView screen
class BooksAuthorsScreen extends RScreenHook<AppNavigator, BooksAuthorsSegment> {
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
          title: Text('Books and Authors'),
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
```

#### See:

- [running example](https://pavelpz.github.io/doc_nested_navigation/)
- [source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/nested_navigation.dart)
