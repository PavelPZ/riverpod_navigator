# Login flow

A slightly more complicated example, implementing a login flow as follows:

1. there is a home screen, five book screens (with id = 1...5), and a login screen
2. each screen (except login one) has a Login x Logout button
3. the book screen with odd 'id' is not accessible without login (for such screens the application is redirected to the login page)
4. after logging in, the application redirects to the page that requires a login

## Application logic

Redirect when:
- if the user is not logged in and some screen in the navigation stack requires a login
- if the user is logged in and goes to the login screen

```dart
  @override
  TypedPath appNavigationLogic(TypedPath ongoingPath, {CToken? cToken}) {
    final userIsLogged = ref.read(userIsLoggedProvider);
    final navigationStack = getNavigationStack();

    // if user is not logged-in and some of the screen in navigations stack needs login => redirect to LoginScreen
    if (!userIsLogged && ongoingPath.any((segment) => needsLogin(segment))) {
      // loggedUrl: destination path after login
      final loggedUrl = pathParser.typedPath2Path(ongoingPath);
      // canceledUrl: navigationStack
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

#### Code of the example

See [login_flow.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/login_flow.dart).
