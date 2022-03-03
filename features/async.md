# Async navigation and splash screen

Navigation is delayed until the asynchronous actions are performed. These actions for each screen are:
- **opening** (before opening a new screen)
- **closing** (before closing the old screen)
- **merging** (before replacing the screen with the same segment type)

```dart
class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoute<HomeSegment>(
              'home',
              HomeSegment.fromUrlPars,
              HomeScreen.new,
              screenTitle: (segment) => 'Home',
              opening: (newSegment) => _simulateAsyncResult('Home.creating', 2000),
            ),
            RRoute<PageSegment>(
              'page',
              PageSegment.fromUrlPars,
              PageScreen.new,
              screenTitle: (segment) => 'Page ${segment.id}',
              opening: (newSegment) => _simulateAsyncResult('Page.creating', 240),
              replacing: (oldSegment, newSegment) => _simulateAsyncResult('Page.merging', 800),
              closing: null,
            ),
          ],
        );

  // It is good practice to place the code for all events specific to navigation in AppNavigator.
  // These can then be used not only for writing screen widgets, but also for testing.

  /// navigate to page
  Future toPage({required int id}) => navigate([HomeSegment(), PageSegment(id: id)]);

  /// navigate to next page
  Future toNextPage() => replaceLast<PageSegment>((old) => PageSegment(id: old.id + 1));

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);

  /// sideEffect
  Future sideEffect() => registerProtectedFuture(Future.delayed(Duration(milliseconds: 5000)));

  /// multi sideEffect
  Future multiSideEffect() async {
    blockGui(true);
    try {
      await registerProtectedFuture(Future.delayed(Duration(milliseconds: 5000)));
    } finally {
      blockGui(false);
    }
  }
}

// simulates an action such as loading external data or saving to external storage
Future<String> _simulateAsyncResult(String asyncResult, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return '$asyncResult: async result after $msec msec';
}
```

#### useful extension for screen code

These extensions will make it easier for you to write and understand the code.

```dart
extension WidgetRefApp on WidgetRef {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}
```

Use in your application:

```dart
   ElevatedButton(onPressed: () => ref.navigator.toPage(id: 1), ...
```

#### useful extension for test code

```dart 
extension ProviderContainerApp on ProviderContainer {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}
```

Use in your test:

```dart
  final container = ProviderContainer();
  await container.navigator.toPage(id: 1);
  await container.navigator.toNextPage();
```

#### See:

- [running example](https://pavelpz.github.io/doc_async/)
- [source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/async.dart)
- [test code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/test/async_test.dart)

