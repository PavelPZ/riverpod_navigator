
## Lesson04
Lesson04 is [lesson03](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson03.md) prepared using the router concept.

See [lesson04.dart source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/lesson04/lesson04.dart)

### 2. Type App-specific navigator (aka AppNavigator)

#### 2.1. Navigation parameters



```dart
class AppNavigator extends RNavigator {
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

