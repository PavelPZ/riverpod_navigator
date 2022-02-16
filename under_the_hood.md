# What's under the hood

A brief introduction to the riverpod_navigation principle can help with its use.

How is our mission "to keep *string-path* <= **typed-path** => *navigation-stack* always in sync" implemented?

We will explain the principles on the implementation of **login app flow**. 
The login app flow application is simple:
- there are 3 screens (and segments): Home, Page and Login
- Page screen may not be visible when the user is not logged in
- login screen may not be visible when the user is already logged in

## 1. In the beginning there are riverpod providers and their states

```dart
/// All **typed-segments** (HomeSegment, PageSegment and LoginSegment) are inherited from this class
abstract class TypedSegment {}
/// **typed-path**
typedef TypedPath = List<TypedSegment>;

/// assigning eg. ref.read(ongoingPathProvider.notifier).state = [HomeSegment(), PageSegment()] causes a new navigation stack to be calculated
final ongoingPathProvider = StateProvider<TypedPath>((_) => []);

/// assigning eg. ref.read(ongoingPathProvider.notifier).state==false causes a new navigation stack to be calculated
final userIsLoggedProvider = StateProvider<bool>((_) => false);
...

// .... and of course HomeSegment, HomeScreen, PageSegment and PageScreen, LoginSegment, LoginScreen ...

...
```

## 2. At the end is the navigation stack, implemented by Flutter Navigator 2.0 RouterDelegate

```dart
class RiverpodRouterDelegate extends RouterDelegate<TypedPath>...
  ...
  //***************************************************
  // Helper property: "navigationStack" getter x setter
  //***************************************************
  TypedPath get navigationStack => currentConfiguration;
  void set navigationStack(TypedPath path) {
    currentConfiguration = path;
    notifyListeners();
  }

  ...
  /// build screens from the navigationStack 
  @override
  Widget build(BuildContext context) => Navigator(
      pages: navigationStack.map((typedSegment) => <... create screen for given typedSegment ...>,
      ...
  )

  // RouterDelegate requires currentConfiguration to process the Flutter for Web URL correctly
  @override
  TypedPath currentConfiguration = [];

}
```

## 3. And in the middle is RNavigator

RNavigator reacts to changes of the input states (ongoingPathProvider, userIsLoggedProvider in this case) 
and updates the output state (RiverpodRouterDelegate.navigationStack) accordingly.

How is it done?

```dart
class RNavigator {
  RNavigator(Ref ref) {
    ...
    /// Listen to the providers and call "onStateChanged" every time they change.
    [ongoingPathProvider,userIsLoggedProvider].foreach((provider) => ref.listen(provider, (_,__) => onStateChanged())));
  }

  /// onStateChanged is called whenever providers change
  void onStateChanged() {
    // get ongoingPath notifier
    final ongoingPathNotifier = ref.read(ongoingPathProvider.notifier);
    // run app specific application navigation logic here (redirection, login, etc.).
    final newOngoingPath = appNavigationLogic(ongoingPathNotifier.state);
    // Flutter Navigator 2.0 to updates the navigation stack according to the ongoingPathProvider state
    riverpodRouterDelegate.navigationStack = newOngoingPath;
  }

  /// RiverpodRouterDelegate is tied to the RNavigator
  final riverpodRouterDelegate = RiverpodRouterDelegate();

  /// Enter application navigation logic here (redirection, login flow, etc.). 
  /// No need to override (eg when the navigation status depends only on the ongoingPathProvider and no redirects or no route guard is required)
  TypedPath appNavigationLogic(TypedPath ongoingPath) => ongoingPath;
}
```

## 4. Example of RNavigator.appNavigationLogic for Login flow

```dart
@override 
TypedPath appNavigationLogic(TypedPath ongoingPath) {
  final userIsLogged = ref.read(userIsLoggedProvider);

  // if user is not logged in and there is any PageSegment in navigations stack => redirect to LoginScreen
  if (!userIsLogged && ongoingPath.any((segment) => segment is PageSegment) return [LoginSegment()];

  // user is logged and LogginScreen is going to display => redirect to HomeScreen
  if (userIsLogged && ongoingPath.any((segment) => segment is LoginSegment) return [HomeSegment()];)

  // else: no redirection is needed
  return ongoingPath;
}
```

## That's it

This is all essential for the implementation of the login flow.
With Riverpod, using Flutter Navigator 2.0 is easy.

See what the application's **Login button** might look like:

#### Login Button
```dart
...
Consumer(builder: (_, ref, __) {
  final userIsLoggedNotifier = ref.watch(userIsLoggedProvider.notifier);
  return ElevatedButton(
    // toogles the login state
    onPressed: () => userIsLoggedNotifier.update((s) => !s),
    // displays correct login button text
    child: Text(userIsLoggedNotifier.state ? 'Logout' : 'Login'),
  );
})
...
```
