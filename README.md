# Navigator for Riverpod

### Simple but powerfull navigation library (based on Flutter Navigator 2.0, [Riverpod](https://riverpod.dev/), and [Freezed](https://github.com/rrousselGit/freezed)) that solves the following problems:

- **Strictly typed navigation:** <br>You can use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId');``` in your code.
- **Easier coding:** <br>The problem of navigation is reduced to manipulation an immutable collection.
- **Better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
  Navigation logic can be developed and tested without typing a single flutter widget.
- **Asynchronous navigation:**<br>
  Before starting navigation, prepare all necessary asynchronous operations, e.g.
  - loading data for new screen
  - save data from the previous screen
- **Dependence on external providers:**<br>
  The navigation state may also depend on external providers, e.g. on login status
- **Possibility to configure many navigation parameters**

## The mission

Take a look at the following terms related to url path ```home/books/book;id=2```

- **string-path:** ```final stringPath = 'home/books/book;id=2';```
- **string-segment** - the string-path consists of three string-segments: 'home', 'books' and 'book;id=2'
- **typed-segment** - the typed-segment is immutable class that defines string-segment: HomeSegment(), BooksSegment() and BookSegment(id:2)
- **typed-path**: typed-path can be understood as List<typed-segment>: ```final typedPath = [HomeSegment(), BooksSegment(), BookSegment(id:2)];```
- **navigation-stack** of Flutter Navigator 2.0 is a stack of screens, parameterized by typed-segment:
  ```HomeScreen(HomeSegment())) => BooksScreen(BooksSegment()) => BookScreen(BookSegment(id:3))```

The mission of navigation is to keep *string-path* <= **typed-path** => *navigation-stack* always in sync.
With the **typed-path** as the source of the truth.

Note: *There is a one-to-one relationship between the given segment and the screen (HomeSegment - HomeScreen, BookSegment - BookScreen).
In the following text, I sometimes confuse the two terms.*.

## Simple example

### Step1 - imutable classes for typed-segment

We use [freezed-package](https://github.com/rrousselGit/freezed) for generation immutable clasess (that defines typed-segment's).

It's a good idea to be familiar with the freezed-package (including support for JSON serialization).

From the following SegmentGrp class declaration, the freezed package 
generates two classes: *HomeSegment* and *PageSegment*.

```dart
@freezed
class SegmentGrp with _$SegmentGrp, TypedSegment {
  SegmentGrp._();
  factory SegmentGrp.home() = HomeSegment;
  factory SegmentGrp.page({required String title}) = PageSegment;

  factory SegmentGrp.fromJson(Map<String, dynamic> json) => _$SimpleSegmentFromJson(json);
}
```

### Step2 - navigator parameterization

Extends the RiverpodNavigator class as follows:

```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super.router(
          ref,
          // which screen to run when the application starts
          [HomeSegment()],
          [
            // JSON serialization of HomeSegment and PageSegment
            RRoutes<SegmentGrp>(SegmentGrp.fromJson, [
              // build a screen from segment
              RRoute<HomeSegment>(HomeScreen.new),
              RRoute<PageSegment>(PageScreen.new),
            ])
          ],
        );
}
```

### Step3 - use the RiverpodNavigator in MaterialApp.router

If you are familiar with the Flutter Navigator 2.0 and the riverpod, the following code is clear:

```dart
class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // for all widgets with riverpod support, the navigator is available via riverpodNavigatorProvider
    final navigator = ref.read(riverpodNavigatorProvider);
    return MaterialApp.router(
      title: 'Riverpod Navigator Example',
      routerDelegate: navigator.routerDelegate,
      routeInformationParser: navigator.routeInformationParser,
      debugShowCheckedModeBanner: false,
    );
  }
}

```

### Step4 - runApp

```dart
void main() => runApp(
      ProviderScope(
        overrides: [
          riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new),
        ],
        child: const App(),
      ),
    );
```

### Step5 - widgets for screens

Creating screen widgets is probably an understandable part of the example.

Only the navigation to the new screen is interesting:

```dart
//  getting navigation stack "HomeScreen(HomeSegment()) => PageScreen(PageSegment(title: 'Page title'))".
ref.read(riverpodNavigatorProvider).navigate([HomeSegment(), PageSegment(title: 'Page')]);
```

or 

```dart
// getting navigation stack "HomeScreen(HomeSegment())".
ref.read(riverpodNavigatorProvider).navigate([HomeSegment()]);
```

#### Code of the example

The full code is available here:
[simple.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/simple.dart).

## What's under the hood

A brief introduction to the riverpod_navigation principle can help with its use.
How is our mission "to keep *string-path* <= **typed-path** => *navigation-stack* always in sync" implemented?

Let's look at the principles of how to implement login app flow.

### In the beginning there are riverpod providers and their states

```dart
/// All "typed-segments" (eg HomeSegment and PageSegment from example) are inherited from this class
abstract class TypedSegment {}
/// **typed-path**
typedef TypedPath = List<TypedSegment>;

/// this TypedPath provider is part of the riverpod_navigation package
final ongoingPathProvider = StateProvider<TypedPath>((_) => []);

/// another provider with a "userIsLogged state" on which the navigation state depends 
/// (and which can be part of the application)
final userIsLoggedProvider = StateProvider<bool>((_) => false);

...
//and of course HomeSegment, HomeScreen, LoginSegment, LoginScreen, PageSegment and PageScreen
...
```

### At the end is the navigation stack, represented by Flutter Navigator 2.0 RouterDelegate

```dart
class RiverpodRouterDelegate extends RouterDelegate<TypedPath> {
  ...
  /// current navigation state
  @override
  TypedPath currentConfiguration = [];
  ...
  /// build screens from currentConfiguration 
  @override
  Widget build(BuildContext context) => Navigator(
      pages: currentConfiguration.map((typedSegment) => <... create screen for given typedSegment ...>,
      ...
  )
  /// a notifyListeners notifies RouterDelegate that it needs to be rebuilt
  void notifyListeners() : super.notifyListeners();
}
```

### And in the middle is RiverpodNavigator

RiverpodNavigator reacts to changes of the input states (ongoingPathProvider, userIsLoggedProvider in this case) 
and updates the output state (navigation stack) accordingly.

How is it done?

```dart
class RiverpodNavigator {
  RiverpodNavigator(Ref ref) {
    ...
    /// Listen to the providers state change. Call "onStateChanged" every time it changes.
    [ongoingPathProvider,userIsLoggedProvider].foreach((provider) => ref.listen(provider, (_,__) => onStateChanged())));
  }

  void onStateChanged() {
    //=====> at this point, "ongoingPathProvider state" and "riverpodRouterDelegate.currentConfiguration" could differ
    // get ongoingPath notifier
    final ongoingPathNotifier = ref.read(ongoingPathProvider.notifier);
    // run app specific application navigation logic here (redirection, login, etc.).
    final newOngoingPath = appNavigationLogic(ongoingPathNotifier.state);
    // actualize a possibly changed ongoingPath
    ongoingPathNotifier.state = newOngoingPath;
    // the next two lines will cause Flutter Navigator 2.0 to update the navigation stack according to the ongoingPathProvider state
    riverpodRouterDelegate.currentConfiguration = newOngoingPath;
    riverpodRouterDelegate.notifyListeners();
    //=====> at this point, "ongoingPathProvider state" and  "RiverpodRouterDelegate" are in sync
  }

  /// Enter application navigation logic here (redirection, login, etc.). 
  /// No need to override (eg when the navigation status depends only on the ongoingPathProvider and no redirects or no route guard is required)
  TypedPath appNavigationLogic(TypedPath ongoingPath) => ongoingPath;

}
```

### Example of appNavigationLogic for Login flow

```dart
@override 
TypedPath appNavigationLogic(TypedPath ongoingPath) {
  final userIsLogged = ref.read(userIsLoggedProvider);

  // if user is not logged in and some of screen in navigations stack needs login => redirect to LoginScreen
  if (!userIsLogged && ongoingPath.any((segment) => needsLogin(segment)) return [LoginSegment()];

  // user is logged and LogginScreen is going to display => redirect to HomeScreen
  if (userIsLogged && ongoingPath.any((segment) => segment is LoginSegment) return [HomeSegment()];)

  // no redirection is needed
  return ongoingPath;
}
```

Note: *we need the "needsLogin" function that returns true when a login is required for given screen*

### Thats it

This is all essential for the implementation of the login flow.
With Riverpod, using Flutter Navigator 2.0 is really easy.
See how the Loggin button looks:

#### Login Button
```dart
Consumer(builder: (_, ref, __) {
  final userIsLoggedNotifier = ref.watch(userIsLoggedProvider.notifier);
    return ElevatedButton(
      // toogles the login state
      onPressed: () => userIsLoggedNotifier.update((s) => !s),
      // displays correct login button text
      child: Text(userIsLoggedNotifier.state ? 'Logout' : 'Login'),
    );
}),
```

### Verification of the riverpod_navigator idea

If anyone wants to understand in detail how the riverpod_navigator package works, 
let them look at [riverpod_navigator_example](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/riverpod_navigator_example/). 
It validates the idea of collaboration [Riverpod](https://riverpod.dev/) + [Freezed](https://github.com/rrousselGit/freezed) + Flutter Navigator 2.0.

## Other feartures

### Code simplification

Subsequent examples are prepared with simpler code:

- using the functional_widget package simplifies widgets typing
- some code is moved to common dart file

A modified version of the first example is here: [simple_modified.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/simple_modified.dart).

### Async navigation and splash screen

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
      : super.router(
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

### Login flow application

A slightly more complicated example, implementing a login flow as follows:

1. there is a home screen, five book screens (with id = 1...5) and a login screen
2. each screen (except login one) has a Login x Logout button
3. the book screen with odd 'id' is not accessible without login (for such screens the application is redirected to the login page)
4. after logging in, the application redirects to the page that requires a login

#### Code of the example

See [login_flow.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/login_flow.dart).

### Testing 

Navigation logic can be developed and tested without typing a single flutter widget.

See [login_flow.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/test/login_flow_test.dart).

todo: finish test

### More TypedSegment roots

See [async-more-groups.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/async-more-groups.dart).

In a real application with many dozens of screens, it would not be practical to define typed-segments using one class (as SegmentGrp is).
Use the unique "unionKey" for the second and next segment group.
!!!! "unionKey" must start with an underscore. !!!


```dart
@freezed
class HomeGrp with _$HomeGrp, TypedSegment {
  /// JsonSerialization curiosity: add this unused factory constructor.
  /// If there is only one constructor (like "factory HomeGrp () = _HomeGrp;"), the resulting JSON has a different format.
  factory HomeGrp() = _HomeGrp;
  HomeGrp._();
  factory HomeGrp.home() = HomeSeg;

  factory HomeGrp.fromJson(Map<String, dynamic> json) => _$HomeGrpFromJson(json);
}

/// The second and another segment group needs unique "unionKey".
/// !!!! It have to start with underscore. !!!
@Freezed(unionKey: PageGrp.jsonNameSpace)
class PageGrp with _$PageGrp, TypedSegment {
  factory PageGrp() = _PageGroup;
  PageGrp._();
  factory PageGrp.home() = PageSeg;

  factory PageGrp.fromJson(Map<String, dynamic> json) => _$PageGrpFromJson(json);

  static const String jsonNameSpace = '_page';
}
```

todo: finish an example

## Roadmap

I prepared this package for my new project. Its further development depends on whether it will be used by the community.

- finish examples
- proofreading because my English is not good. Community help is warmly welcomed.
- testing on mobile (tested so far for windows desktop and web)<br>
  Navigator.onPopPage may need improvements.
- nested navigation flow<br>
  I think everything is ready, nested ProviderScope can solve nested navigation too.
- BlockGUI widget (block the GUI while asynchronous navigation is waiting to complete)
- parameterization alowing cupertino
