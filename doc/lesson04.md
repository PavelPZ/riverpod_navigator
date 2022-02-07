
### Lesson04
It modified [lesson03](/doc/lesson03.md) by:

- introduction of the route concept

See [lesson04.dart source code](/examples/doc/lib/src/lesson04/lesson04.dart)

### 2. App-specific navigator

- contains actions related to navigation. The actions are then used in the screen widgets.
- configures various navigation properties

```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          dependsOn: [userIsLoggedProvider],
          initPath: [HomeSegment()],
          splashBuilder: SplashScreen.new,
          router: AppRouter(), // <========================
        );

  /// The needLogin logic is handled by the router
  bool needsLogin(TypedSegment segment) => (router as AppRouter).needsLogin(segment);
```

