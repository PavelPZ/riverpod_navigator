
## Lesson05
Lesson05 is the same as [lesson03](/doc/lesson03.md) but without screens and widgets.
It has not any GUI, only a test.

See the source code of the test here: [lesson05_test.dart](/examples/doc/test/lesson05_test.dart).

#### 2.1. Navigation parameters



```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          segment2AsyncScreenActions: segment2AsyncScreenActions,
          dependsOn: [userIsLoggedProvider],
          json2Segment: (jsonMap, unionKey) => 
              unionKey == LoginSegments.jsonNameSpace ? LoginSegments.fromJson(jsonMap) : AppSegments.fromJson(jsonMap),
          // remove splashBuilder:
          // splashBuilder: SplashScreen.new,
          // fake screenBuilder:
          screenBuilder: (segment) => SizedBox(),
        );

  /// mark screens which needs login: every 'id.isOdd' book needs it
  bool needsLogin(TypedSegment segment) => segment is BookSegment && segment.id.isOdd;
```

### Ukázka testu



```dart
//
    //**********
    // log in tests
    //**********

    await navigTest(() => navigator.toHome(), 'home');

    // navigate to book 3, book 3 needs login => redirected to login page
    await navigTest(() => navigator.toBook(id: 3), 'login-home;loggedUrl=home%2Fbooks%2Fbook%3Bid%3D3;canceledUrl=home');

    // confirm login => redirect to book 3
    await navigTest(() => navigator.loginPageOK(), 'home/books/book;id=3');

    // to previous book 2
    await navigTest(() => navigator.bookNextPrevButton(isPrev: true), 'home/books/book;id=2');

    // to previous book 1
    await navigTest(() => navigator.bookNextPrevButton(isPrev: true), 'home/books/book;id=1');

    // logout, but book needs login => redirected to login page
    await navigTest(() => navigator.globalLogoutButton(), 'login-home;loggedUrl=home%2Fbooks%2Fbook%3Bid%3D1;canceledUrl=');

    // cancel login => redirect to home
    await navigTest(() => navigator.loginPageCancel(), 'home');
```

