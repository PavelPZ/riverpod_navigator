
## Lesson02
Lesson02 is [lesson01](/doc/lesson01.md) enhanced with:

- asynchronous navigation when screens require some asynchronous actions (when creating, deactivating, or merging)
- the splash screen appears before the HomeScreen is displayed

See [lesson02.dart source code](/examples/doc/lib/src/lesson02/lesson02.dart)

### 1.1. async screen actions

Each screen may require an asynchronous action during its creation, merging, or deactivating.
The asynchronous result is then provided to the screen widget.

```dart
AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
  // 
  /// helper for simulating asynchronous action. Its result is then provided to the screen widget.
  Future<String> simulateAsyncResult(String asyncResult, int msec) async {
    await Future.delayed(Duration(milliseconds: msec));
    return asyncResult;
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

### 2. Type App-specific navigator (aka AppNavigator)

#### 2.1. Navigation parameters



```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          json2Segment: (jsonMap, _) => AppSegments.fromJson(jsonMap),
          screenBuilder: appSegmentsScreenBuilder,
          // ***** new parameters for this example ******
          // asynchronous screen actions
          segment2AsyncScreenActions: segment2AsyncScreenActions,
          // splash screen that appears before the home page is created
          splashBuilder: SplashScreen.new,
        );
```

