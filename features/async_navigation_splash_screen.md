# Async navigation and splash screen

Navigation is delayed until the asynchronous actions are performed. These actions are:
- **creating** (before inserting a new screen into the navigation stack)
- **deactivating** (before removing the old screen from the navigation stack)
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
            RRoutes<SegmentGrp>(SegmentGrp.fromJson, [
              RRoute<HomeSegment>(
                HomeScreen.new,
                creating: (newSegment) => simulateAsyncResult('Home.creating', 2000),
              ),
              RRoute<PageSegment>(
                PageScreen.new,
                creating: (newSegment) => simulateAsyncResult('Page.creating', 400),
                merging: (oldSegment, newSegment) => simulateAsyncResult('Page.merging', 200),
                deactivating: null,
              ),
            ])
          ],
          splashBuilder: () => SplashScreen(),
        );
}
```

#### Code of the example

See [async.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/async.dart)
