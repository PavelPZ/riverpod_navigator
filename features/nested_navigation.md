# Nested navigation

In the following example, the same navigator is used in three contexts:
- as the root navigator for the application
- as a nested navigator on the "Books" tab in the TabBarView widget
- as a nested navigator on the "Authors" tab in the TabBarView widget

The nested navigator has a "RestorePath restorePath" parameter: its purpose is to remember the state of the navigator during Tab's switching.

Note: *We use **flutter_hooks package** to keep RestorePath instance. The use of flutter_hooks is not mandatory, it can be implemented using the StatefulWidget*.

The nested navigator requires the ```isNested: true``` parameter.

```dart
class AppNavigator extends RiverpodNavigator {
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

          /// required nested flag
          isNested: true,

          /// The RestorePath class preserves the last state of the navigator.
          /// Used during the next navigator initialization.
          restorePath: restorePath,
        );

```

```dart
/// TabBarView screen
@hcwidget
Widget booksAuthorsScreen(WidgetRef ref, BooksAuthorsSegment booksAuthorsSegment) {
  /// Remembering RestorePath throughout the widget's lifecycle
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

See [async.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/nested_navigation.dart)