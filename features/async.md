# Async navigation

Navigation is delayed until the asynchronous actions are performed. These actions for each screen are:
- **opening** (before opening a new screen)
- **closing** (before closing the old screen)
- **merging** (before replacing the screen with a screen with the same segment type)

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
              opening: (sNew) => sNew.setAsyncValue(_simulateAsyncResult('Home.opening', 2000)),
            ),
            RRoute<BookSegment>(
              'book',
              BookSegment.fromUrlPars,
              BookScreen.new,
              opening: (sNew) => sNew.setAsyncValue(_simulateAsyncResult('Book ${sNew.id}.opening', 240)),
              replacing: (sOld, sNew) => sNew.setAsyncValue(_simulateAsyncResult('Book ${sOld.id}=>${sNew.id}.replacing', 800)),
              closing: (sOld) => Future.delayed(Duration(milliseconds: 500)),
            ),
          ],
        );

  // It is good practice to place the code for all events specific to navigation in AppNavigator.
  // These can then be used not only for writing screen widgets, but also for testing.

  /// navigate to book
  Future toBook({required int id}) => navigate([HomeSegment(), BookSegment(id: id)]);

  /// navigate to next book
  Future toNextBook() => replaceLast<BookSegment>((old) => BookSegment(id: old.id + 1));

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);

  /// sideEffect
  Future sideEffect() async {
    isNavigating(true);
    try {
      await registerProtectedFuture(Future.delayed(Duration(milliseconds: 5000)));
    } finally {
      isNavigating(false);
    }
  }
}

// simulates an action such as loading external data or saving to external storage
Future<String> _simulateAsyncResult(String asyncResult, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return '$asyncResult: async result after $msec msec';
}
```

#### See:

- [running example](https://pavelpz.github.io/doc_async/)
- [source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/async.dart)
- [test code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/test/async_test.dart)

