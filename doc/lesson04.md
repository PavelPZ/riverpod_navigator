
### Lesson04
Lesson04 is [lesson03](/doc/lesson03.md) prepared using the router concept.

See [lesson04.dart source code](/examples/doc/lib/src/lesson04/lesson04.dart)

### 2. Type App-specific navigator (aka AppNavigator)

### Navigation parameters



```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          dependsOn: [userIsLoggedProvider],
          splashBuilder: SplashScreen.new,
          //******* router configuration ********
          // the router replaces the following parameters: json2Segment, screenBuilder, segment2AsyncScreenActions
          router: AppRouter(), 
        );

  /// The needLogin logic is handled by the router
  bool needsLogin(TypedSegment segment) => (router as AppRouter).needsLogin(segment);
```

