# Other feartures

## Code simplification

Subsequent examples are prepared with simpler code:

- using the functional_widget package simplifies widgets typing
- some code is moved to common dart file

A modified version of the first example is here: [simple_modified.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/simple_modified.dart).

## Async navigation and splash screen

Navigation is delayed until the asynchronous actions are performed. These actions are:
- **creating** (before inserting a new screen into the navigation stack)
- **deactivating** (before removing the old screen from the navigation stack)
- **merging** (before screen replacement with the same segment type in the navigation stack)

```dart
// simulates an async action such as loading external data or saving to external storage
Future<String> simulateAsyncResult(String actionName, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return '$actionName: async result after $msec msec';
}

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [HomeSegment()],
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
        );
}
```

#### Code of the example

See [async.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/async.dart)

## Login flow application

A slightly more complicated example, implementing a login flow as follows:

1. there is a home screen, five book screens (with id = 1...5) and a login screen
2. each screen (except login one) has a Login x Logout button
3. the book screen with odd 'id' is not accessible without login (for such screens the application is redirected to the login page)
4. after logging in, the application redirects to the page that requires a login

#### Code of the example

See [login_flow.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/login_flow.dart).

## Testing 

Navigation logic can be developed and tested without typing a single flutter widget.

#### Code of the example

See [login_flow_test.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/test/login_flow_test.dart).

## More TypedSegment roots

In a real application with many dozens of screens, it would not be practical to define typed-segments using one class (as SegmentGrp is).
Use the unique "unionKey" for the second and next segment group.

!!!! jsonNameSpace for ```@Freezed(unionKey: SecondGrp.jsonNameSpace)``` must start with an underscore. !!!!

!!!! There must be at least two factory constructors in one class !!!!

#### Code of the example

See [more_groups.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/more_groups.dart).

## Comparison with go_router

This chapter is inspired by this riverpod issue: [Examples of go_router using riverpod](https://github.com/rrousselGit/river_pod/issues/1122).

| example | go_router | code lines | riverpod_navigator | code lines |
| --- | --- | --- | --- | --- |
| main | [source code](https://github.com/csells/go_router/blob/main/go_router/example/lib/main.dart) | 70 | [source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/go_router/lib/main.dart) | 84  |
| redirection | [source code](https://github.com/csells/go_router/blob/main/go_router/example/lib/redirection.dart) | 167 | [source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/go_router/lib/redirection.dart) | 149 |

If you are interested in preparing another go_router example, I will try to do it.

