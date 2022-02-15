# Nested navigation

In the following example, the same navigator is used in three contexts:
- as the root navigator for the application
- as a nested navigator on the "Books" tab in the TabBarView widget
- as a nested navigator on the "Authors" tab in the TabBarView widget

The nested navigator has a "RestorePath restorePath" parameter: its purpose is to remember the state of the navigator during Tab's switching.

```dart
class AppNavigator extends RNavigator {
  /// Constructor for book nested navigator.
  AppNavigator.forBook(Ref ref, RestorePath restorePath)
      : super(
          ref,
          [BookSegment(id: 2)],
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<BookSegment>(BookScreen.new),
            ])
          ],

          /// The RestorePath class preserves the last state of the nested navigator.
          restorePath: restorePath,
        );

  /// constructor for author nested navigator
  AppNavigator.forAuthor(Ref ref, RestorePath restorePath)
      : super(
          ref,
          [AuthorSegment(id: 2)],
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<AuthorSegment>(AuthorScreen.new),
            ])
          ],
          restorePath: restorePath,
        );
```

```dart
/// TabBarView screen
@hcwidget
Widget booksAuthorsScreen(WidgetRef ref, BooksAuthorsSegment booksAuthorsSegment) {
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
            overrides: [
              /// initialize the navigator using restoreBook
              riverpodNavigatorProvider.overrideWithProvider(Provider((ref) => AppNavigator.forBook(ref, restoreBook))),
              /// pass all navigator dependsOn to the nested ProviderScope
              ...ref.read(riverpodNavigatorProvider).dependsOn.map((e) => e as Override).toList(),
            ],
            child: BooksTab(),
          ),
          ProviderScope(
            overrides: [
              riverpodNavigatorProvider.overrideWithProvider(Provider((ref) => AppNavigator.forAuthor(ref, restoreAuthor))),
              ...ref.read(riverpodNavigatorProvider).dependsOn.map((e) => e as Override).toList(),
            ],
            child: AuthorTab(),
          ),
        ],
      ),
    ),
  );
}
```

#### Code of the example

See [nested_navigation.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/nested_navigation.dart)
