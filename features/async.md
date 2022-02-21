# Async navigation and splash screen

Navigation is delayed until the asynchronous actions are performed. These actions for each screen are:
- **opening** (before opening a new screen)
- **closing** (before closing the old screen)
- **merging** (before replacing the screen with the same segment type)

It is good practice to place the code for all events specific to navigation in AppNavigator.
These can then be used not only for writing screen widgets but also for testing.

See ```toPage```, ```toNextPage``` and ```toHome``` bellow.

```dart
Future<String> simulateAsyncResult(String asyncResult, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return '$asyncResult: async result after $msec msec';
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<HomeSegment>(
                HomeScreen.new,
                opening: (newSegment) => simulateAsyncResult('Home.opening', 2000),
              ),
              RRoute<PageSegment>(
                PageScreen.new,
                opening: (newSegment) => simulateAsyncResult('Page.opening', 400),
                replacing: (oldSegment, newSegment) => simulateAsyncResult('Page.replacing', 200),
                closing: null,
              ),
            ])
          ],
          splashBuilder: () => SplashScreen(),
        );

  // It is good practice to place the code for all events specific to navigation in AppNavigator.
  // These can then be used not only for writing screen widgets but also for testing.

  /// navigate to page
  Future toPage({required int id}) => navigate([HomeSegment(), PageSegment(id: id)]);

  /// navigate to next page
  Future toNextPage() => replaceLast<PageSegment>((old) => PageSegment(id: old.id + 1));

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);
}
```

#### useful extension for screen code

These extensions will make it easier for you to write and understand the code.

```dart
extension WidgetRefApp on WidgetRef {
  AppNavigator get navigator => read(riverpodNavigatorProvider) as AppNavigator;
}
```

Use in your application:

```dart
   ElevatedButton(onPressed: () => ref.navigator.toPage(id: 1), ...
```

#### useful extension for test code

```dart 
extension ProviderContainerApp on ProviderContainer {
  AppNavigator get navigator => read(riverpodNavigatorProvider) as AppNavigator;
}
```

Use in your test:

```dart
  final container = ProviderContainer();
  await container.navigator.toPage(id: 1);
  await container.navigator.toNextPage();
```

#### Full source code and test:

- [async.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/async.dart)
- [async_test.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/test/async_test.dart)

