
### Lesson05
Lesson05 includes a test for [lesson03](/doc/lesson03.md).

See the source code of the test here: [lesson03_test.dart](/examples/doc/test/lesson03_test.dart).

Ukázka testu

```dart
//
    //**********
    // log in tests
    //**********

    await navigTest(() => navigator.toHome(), 'home');

    // navigate to book 3, book 3 needs login => redirected to login page
    await navigTest(() => navigator.toBook(id: 3), 'login-home;loggedUrl=home%2Fbooks%2Fbook%3Bid%3D3;canceledUrl=home');

    // confirm login => redirect book 3
    await navigTest(() => navigator.loginPageOK(), 'home/books/book;id=3');

    // to previous book 2
    await navigTest(() => navigator.bookNextPrevButton(isPrev: true), 'home/books/book;id=2');

    // to previous book 1
    await navigTest(() => navigator.bookNextPrevButton(isPrev: true), 'home/books/book;id=1');

    // logout but book 1needs login => redirected to login page
    await navigTest(() => navigator.globalLogoutButton(), 'login-home;loggedUrl=home%2Fbooks%2Fbook%3Bid%3D1;canceledUrl=');

    // cancel login => goto home
    await navigTest(() => navigator.loginPageCancel(), 'home');
```

