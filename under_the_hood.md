# What's under the hood

A brief introduction to the riverpod_navigation principle can help with its use.

How is our mission "to keep *string-path* <= **typed-path** => *navigation-stack* always in sync" implemented?

Let's look at the principles of how to implement **login app flow**.

## In the beginning there are riverpod providers and their states

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

## At the end is the navigation stack, represented by Flutter Navigator 2.0 RouterDelegate

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
  @override
  void notifyListeners() : super.notifyListeners();
}
```

## And in the middle is RiverpodNavigator

RiverpodNavigator reacts to changes of the input states (ongoingPathProvider, userIsLoggedProvider in this case) 
and updates the output state (navigation stack) accordingly.

How is it done?

```dart
class RiverpodNavigator {
  RiverpodNavigator(Ref ref) {
    ...
    /// Listen to the providers and call "onStateChanged" every time they change.
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

## Example of appNavigationLogic for Login flow

```dart
@override 
TypedPath appNavigationLogic(TypedPath ongoingPath) {
  final userIsLogged = ref.read(userIsLoggedProvider);

  // if user is not logged in and some of the screen in navigations stack needs login => redirect to LoginScreen
  if (!userIsLogged && ongoingPath.any((segment) => needsLogin(segment)) return [LoginSegment()];

  // user is logged and LogginScreen is going to display => redirect to HomeScreen
  if (userIsLogged && ongoingPath.any((segment) => segment is LoginSegment) return [HomeSegment()];)

  // no redirection is needed
  return ongoingPath;
}
```

Note: *for this appNavigationLogic we need the "needsLogin" function that returns true when a login is required for a given screen*

## That's it

This is all essential for the implementation of the login flow.
With Riverpod, using Flutter Navigator 2.0 is easy.
See how the Loggin button looks:

### Login Button
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
