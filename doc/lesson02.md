
### Lesson02
It enriches [lesson01](/doc/lesson01.md) by:

- screens require some asynchronous actions (when creating, deactivating or merging)
- the splash screen appears before the HomeScreen is displayed

See [lesson02.dart source code](/examples/doc/lib/src/lesson02/lesson02.dart)

### 1.1. async screen actions

Each screen may require an asynchronous action during its creation, merging, or deactivating.

```dart
AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
  /// helper for simulating asynchronous action
  Future<String> simulateAsyncResult(String title, int msec) async {
    await Future.delayed(Duration(milliseconds: msec));
    return title;
  }

  if (segment is! AppSegments) return null;

  return segment.maybeMap(
    book: (_) => AsyncScreenActions<BookSegment>(
      // for every Book screen: creating takes some time
      creating: (newSegment) => simulateAsyncResult('Book.creating: async result after 700 msec', 700),
      // for every Book screen with odd id: changing to another Book screen takes some time
      merging: (_, newSegment) => newSegment.id.isOdd ? simulateAsyncResult('Book.merging: async result after 500 msec', 500) : null,
      // for every Book screen with even id: deactivating takes some time
      deactivating: (oldSegment) => oldSegment.id.isEven ? Future.delayed(Duration(milliseconds: 500)) : null,
    ),
    home: (_) => AsyncScreenActions<HomeSegment>(
      creating: (_) async => simulateAsyncResult('Home.creating: async result after 1000 msec', 1000),
    ),
    orElse: () => null,
  );
}
```

### 2. App-specific navigator

- contains actions related to navigation. The actions are then used in the screen widgets.
- configures various navigation properties

```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          json2Segment: (jsonMap, _) => AppSegments.fromJson(jsonMap),
          screenBuilder: appSegmentsScreenBuilder,
          segment2AsyncScreenActions: segment2AsyncScreenActions,
          splashBuilder: SplashScreen.new,
        );
```

