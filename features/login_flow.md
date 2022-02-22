# Login flow

A slightly more complicated example, implementing a login flow as follows:

1. there is a home screen, five book screens (with id = 1...5), and a login screen
2. each screen (except login one) has a Login x Logout button on AppBar
3. the book screen with odd 'id' is not accessible without login (for such screens, if the user is not logged in, the application is redirected to the login page)
4. after logging in, the application redirects to the page that requires a login

## Application logic

Redirect when:
- if the user is not logged in and some screen in the navigation stack requires a login
- if the user is logged in and goes to the login screen

```dart
  @override
  TypedPath appNavigationLogic(TypedPath ongoingPath) {
    final userIsLogged = ref.read(userIsLoggedProvider);

    // if user is not logged-in and some of the screen in navigations stack needs login => redirect to LoginScreen
    if (!userIsLogged && ongoingPath.any((segment) => needsLogin(segment))) {
      // prepare URLs for confirmation or cancel cases on the login screen
      final navigationStack = getNavigationStack();
      final loggedUrl = pathParser.typedPath2Path(ongoingPath);
      var canceledUrl = navigationStack.isEmpty || navigationStack.last is LoginSegment ? '' : pathParser.typedPath2Path(navigationStack);
      if (loggedUrl == canceledUrl) canceledUrl = ''; // chance to exit login loop

      // redirect to login screen
      return [LoginSegment(loggedUrl: loggedUrl, canceledUrl: canceledUrl)];
    } else {
      // user is logged and LogginScreen is going to display => redirect to HomeScreen
      if (userIsLogged && (ongoingPath.isEmpty || ongoingPath.last is LoginSegment)) return [HomeSegment()];
    }
    // no redirection is needed
    return ongoingPath;
  }
```

## Navigation actions

```dart
  //*** Login x Logout button on AppBar

  Future onLogin() {
    // current navigation stack as string
    final navigStackAsString = pathParser.typedPath2Path(getNavigationStack());
    // redirect to login screen
    return navigate([LoginSegment(loggedUrl: navigStackAsString, canceledUrl: navigStackAsString)]);
  }

  Future onLogout() {
    // actualize login state
    ref.read(userIsLoggedProvider.notifier).state = false;
    // wait for the navigation to complete
    return navigationCompleted;
  }

  //*** LoginScreen actions

  Future loginScreenCancel() => _loginScreenActions(true);
  Future loginScreenOK() => _loginScreenActions(false);

  Future _loginScreenActions(bool cancel) {
    final navigationStack = getNavigationStack();

    // get return path
    final loginHomeSegment = navigationStack.last as LoginSegment;
    var returnPath = pathParser.path2TypedPath(cancel ? loginHomeSegment.canceledUrl : loginHomeSegment.loggedUrl);
    if (returnPath.isEmpty) returnPath = [HomeSegment()];

    // start navigating to a return path
    ref.read(ongoingPathProvider.notifier).state = returnPath;

    // actualize login state
    if (!cancel) ref.read(userIsLoggedProvider.notifier).state = true;

    // wait for the navigation to complete
    return navigationCompleted;
  }
```

#### Running applications, source code and test, see:

- [running example](https://pavelpz.github.io/doc_login_flow/)
- [source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/login_flow.dart)
- [test code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/test/login_flow_test.dart)
