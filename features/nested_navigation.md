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
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<BookSegment>(BookScreen.new),
            ])
          ],
        );

  /// constructor for author nested navigator
  AppNavigator.forAuthor(Ref ref)
      : super(
          ref,
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<AuthorSegment>(AuthorScreen.new),
            ])
          ],
        );
```

```dart
/// TabBarView screen
@hcwidget
Widget booksAuthorsScreen(WidgetRef ref, BooksAuthorsSegment booksAuthorsSegment) {
  /// Remembering RestorePath throughout the BooksAuthorsScreen's lifecycle
  /// Note: *We use **flutter_hooks package** to keep RestorePath instance.
  /// The use of flutter_hooks is optional, you can save restoreBook and restoreAuthor using the StatefulWidget.*
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
```

#### Full source code:

- [nested_navigation.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/nested_navigation.dart)
