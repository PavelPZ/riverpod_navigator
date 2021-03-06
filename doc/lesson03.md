
## Lesson03
Lesson03 is [lesson02](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson02.md) extended by:

- login application logic (where some pages are not available without a logged in user)
- more TypedPath roots (AppSegments and LoginSegments)
- navigation state also depends on another provider (userIsLoggedProvider)

See [lesson03.dart source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/lesson03/lesson03.dart)

### 1.2. userIsLoggedProvider

the navigation state also depends on the following [userIsLoggedProvider]

```dart
final userIsLoggedProvider = StateProvider<bool>((_) => false);
```

### 2. Type App-specific navigator (aka AppNavigator)

#### 2.1. Navigation parameters



```dart
class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          segment2AsyncScreenActions: segment2AsyncScreenActions,
          splashBuilder: SplashScreen.new,
          // the following two parameters are modified with respect of two different types of TypedSegment roots: [AppSegments] and [LoginSegments]
          json2Segment: (jsonMap, unionKey) => 
              unionKey == LoginSegments.jsonNameSpace ? LoginSegments.fromJson(jsonMap) : AppSegments.fromJson(jsonMap),
          screenBuilder: (segment) => segment is LoginSegments ? loginSegmentsScreenBuilder(segment) : appSegmentsScreenBuilder(segment),
          // new for this example: the navigation state also depends on the userIsLoggedProvider
          dependsOn: [userIsLoggedProvider],
        );

  /// mark screens which needs login: every 'id.isOdd' book needs it
  bool needsLogin(TypedSegment segment) => segment is BookSegment && segment.id.isOdd;
```

#### 2.1. Login app logic



```dart
@override
  FutureOr<void> appNavigationLogic(Ref ref, TypedPath currentPath) {
    final userIsLogged = ref.read(userIsLoggedProvider);
    final intendedNotifier = ref.read(intendedPathProvider.notifier);

    if (!userIsLogged) {
      final pathNeedsLogin = intendedNotifier.state.any((segment) => needsLogin(segment));

      // login needed => redirect to login page
      if (pathNeedsLogin) {
        // parametters for login screen
        final loggedUrl = pathParser.typedPath2Path(intendedNotifier.state);
        var canceledUrl = currentPath.isEmpty || currentPath.last is LoginHomeSegment ? '' : pathParser.typedPath2Path(currentPath);
        // chance to exit login loop
        if (loggedUrl == canceledUrl) canceledUrl = '';
        // redirect to login screen
        intendedNotifier.state = [LoginHomeSegment(loggedUrl: loggedUrl, canceledUrl: canceledUrl)];
      }
    } else {
      // user logged and navigation to Login page => redirect to home
      if (intendedNotifier.state.isEmpty || intendedNotifier.state.last is LoginHomeSegment) intendedNotifier.state = [HomeSegment()];
    }
  }
```

#### 2.1. Login specific navigation actions



```dart
Future<void> globalLogoutButton() {
    final loginNotifier = ref.read(userIsLoggedProvider.notifier);
    // checking
    assert(loginNotifier.state); // is logged?
    // change login state
    loginNotifier.state = false;
    return navigationCompleted; // wait for the navigation to end
  }

  Future<void> globalLoginButton() {
    // checking
    assert(!ref.read(userIsLoggedProvider)); // is logoff?
    // navigate to login page
    final segment = pathParser.typedPath2Path(currentTypedPath);
    return navigate([LoginHomeSegment(loggedUrl: segment, canceledUrl: segment)]);
  }

  Future<void> loginPageCancel() => _loginPageButtons(true);
  Future<void> loginPageOK() => _loginPageButtons(false);

  Future<void> _loginPageButtons(bool cancel) async {
    assert(currentTypedPath.last is LoginHomeSegment);
    final loginHomeSegment = currentTypedPath.last as LoginHomeSegment;

    var newPath = pathParser.path2TypedPath(cancel ? loginHomeSegment.canceledUrl : loginHomeSegment.loggedUrl);
    if (newPath.isEmpty) newPath = [HomeSegment()];

    // change both providers on which the navigation status depends
    ref.read(intendedPathProvider.notifier).state = newPath;
    if (!cancel) ref.read(userIsLoggedProvider.notifier).state = true;

    return navigationCompleted; // wait for the navigation to end
  }
```

