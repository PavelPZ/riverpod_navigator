
### Lesson03
It enriches  [Lesson02](doc/Lesson02.md)  by:

- login application logic (where some pages are not available without a logged in user)
- more TypedPath roots (AppSegments and LoginSegments)
- navigation state also depends on another provider (userIsLoggedProvider)
- extension of the Lesson02

See [lesson03.dart source code](examples/doc/lib/src/lesson03/lesson03.dart)

### 1. classes for typed path segments (aka TypedSegment)



```dart
@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
}

@Freezed(unionKey: LoginSegments.jsonNameSpace)
class LoginSegments with _$LoginSegments, TypedSegment {
  /// json serialization hack: must be at least two constructors
  factory LoginSegments() = _LoginSegments;
  LoginSegments._();
  factory LoginSegments.home({String? loggedUrl, String? canceledUrl}) = LoginHomeSegment;

  factory LoginSegments.fromJson(Map<String, dynamic> json) => _$LoginSegmentsFromJson(json);
  static const String jsonNameSpace = '_login';
}
```

### 1.1. async screen actions

Each screen may require an asynchronous action during its creation, merging, or deactivating.

```dart
AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
  /// helper for simulating asynchronous action
  Future<String> simulateAsyncResult(String title, int msec) async {
    await Future.delayed(Duration(milliseconds: msec));
    return title;
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



```dart
/// the navigation state also depends on the following [userIsLoggedProvider]
final userIsLoggedProvider = StateProvider<bool>((_) => false);
```

### 2. App-specific navigator

- contains actions related to navigation. The actions are then used in the screen widgets.
- configures various navigation properties

```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          /// the navigation state also depends on the userIsLoggedProvider
          dependsOn: [userIsLoggedProvider],
          initPath: [HomeSegment()],
          segment2AsyncScreenActions: segment2AsyncScreenActions,
          splashBuilder: SplashScreen.new,
          //----- the following two parameters respect two different types of segment roots: [AppSegments] and [LoginSegments]
          json2Segment: (jsonMap, unionKey) => 
              unionKey == LoginSegments.jsonNameSpace ? LoginSegments.fromJson(jsonMap) : AppSegments.fromJson(jsonMap),
          screenBuilder: (segment) => segment is LoginSegments ? loginSegmentsScreenBuilder(segment) : appSegmentsScreenBuilder(segment),
        );

  /// mark screens which needs login: every 'id.isOdd' book needs it
  bool needsLogin(TypedSegment segment) => segment is BookSegment && segment.id.isOdd;
```



```dart
@override
  FutureOr<void> appNavigationLogic(Ref ref, TypedPath currentPath) {
    final userIsLogged = ref.read(userIsLoggedProvider);
    final ongoingNotifier = ref.read(ongoingPathProvider.notifier);

    if (!userIsLogged) {
      final pathNeedsLogin = ongoingNotifier.state.any((segment) => needsLogin(segment));

      // login needed => redirect to login page
      if (pathNeedsLogin) {
        // parametters for login screen
        final loggedUrl = pathParser.typedPath2Path(ongoingNotifier.state);
        var canceledUrl = currentPath.isEmpty || currentPath.last is LoginHomeSegment ? '' : pathParser.typedPath2Path(currentPath);
        // chance to exit login loop
        if (loggedUrl == canceledUrl) canceledUrl = '';
        // redirect to login screen
        ongoingNotifier.state = [LoginHomeSegment(loggedUrl: loggedUrl, canceledUrl: canceledUrl)];
      }
    } else {
      // user logged and navigation to Login page => redirect to home
      if (ongoingNotifier.state.isEmpty || ongoingNotifier.state.last is LoginHomeSegment) ongoingNotifier.state = [HomeSegment()];
    }
    // here can be async action for <oldPath, ongoingNotifier.state> pair
    return null;
  }

  Future<void> toHome() => navigate([HomeSegment()]);
  Future<void> toBooks() => navigate([HomeSegment(), BooksSegment()]);
  Future<void> toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  Future<void> bookNextPrevButton({bool? isPrev}) {
    assert(currentTypedPath.last is BookSegment);
    var id = (currentTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    return toBook(id: id);
  }

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

    var newSegment = pathParser.path2TypedPath(cancel ? loginHomeSegment.canceledUrl : loginHomeSegment.loggedUrl);
    if (newSegment.isEmpty) newSegment = [HomeSegment()];

    // change both providers on which the navigation status depends
    ref.read(ongoingPathProvider.notifier).state = newSegment;
    if (!cancel) ref.read(userIsLoggedProvider.notifier).state = true;

    return navigationCompleted; // wait for the navigation to end
  }
}
```

### 3. Root widget

Note: *To make it less verbose, we use the functional_widget package to generate widgets.
See generated "lesson??.g.dart"" file for details.*

```dart
@cwidget
Widget booksExampleApp(WidgetRef ref) {
  final navigator = ref.read(riverpodNavigatorProvider);
  return MaterialApp.router(
    title: 'Books App',
    routerDelegate: navigator.routerDelegate as RiverpodRouterDelegate,
    routeInformationParser: RouteInformationParserImpl(navigator.pathParser),
    debugShowCheckedModeBanner: false,
  );
}
```

### 4. App entry point

app entry point with ProviderScope's override

```dart
void runMain() => runApp(
    ProviderScope(
      overrides: [
        riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new /*See Constructor tear-offs in Dart ^2.15*/),
      ],
      child: const BooksExampleApp(),
    ),
  );
const booksLen = 5;
```

### 5. Map TypedSegment's to Screens

Only the *TypedSegment => Screen* mapping is displayed.. You can view all application widgets here: [screen.dart source code](examples/doc/lib/src/lesson01/screens.dart)

```dart
final ScreenBuilder appSegmentsScreenBuilder = (segment) => (segment as AppSegments).map(
  // See Constructor tear-offs in Dart ^2.15, "HomeScreen.new" is equivalent to "(segment) => HomeScreen(segment)"
      home: HomeScreen.new,
      books: BooksScreen.new,
      book: BookScreen.new,
    );
```

