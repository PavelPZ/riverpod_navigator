# Async navigation and splash screen

Navigation is delayed until the asynchronous actions are performed. These actions are:
- **opening** (before opening a new screen)
- **closing** (before closin the old screen)
- **merging** (before screen replacement with the same segment type in the navigation stack)

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

  /// navigate to page
  Future toPage(String title) => navigate([HomeSegment(), PageSegment(title: title)]);

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);
}
```

#### Full source code:

[async.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/async.dart),
[login_flow_test.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/test/async_test.dart)

