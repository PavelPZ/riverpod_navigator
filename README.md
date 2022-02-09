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

## How does it work

If anyone wants to understand how the riverpod_navigator package works, 
let them look at [riverpod_navigator_example](examples/riverpod_navigator_example/). 
It validates the idea of collaboration [Riverpod](https://riverpod.dev/) + [Freezed](https://github.com/rrousselGit/freezed) + Flutter Navigator 2.0.

## Simple example

The full code is available here
[simple.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/simple.dart).

### Step1 - imutable classes for typed-segment

We use [freezed-package](https://github.com/rrousselGit/freezed) for generation immutable clasess (that defines typed-segments).

It's a good idea to be familiar with the freezed-package (including support for JSON serialization).

From the following SimpleSegment class declaration, the freezed package 
generates two classes: *HomeSegment and PageSegment*.

```dart
@freezed
class SimpleSegment with _$SimpleSegment, TypedSegment {
  SimpleSegment._();
  factory SimpleSegment.home() = HomeSegment;
  factory SimpleSegment.page({required String title}) = PageSegment;

  factory SimpleSegment.fromJson(Map<String, dynamic> json) => _$SimpleSegmentFromJson(json);
}
```

### Step2 - navigator parameterization

Extends the RiverpodNavigator class as follows:

```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          // which screen to run when the application starts
          initPath: [HomeSegment()],
          // JSON serialization of "typed-segment" 
          fromJson: SimpleSegment.fromJson,
          // build a screen from segment
          screenBuilder: (segment) => (segment as SimpleSegment).map(
            home: HomeScreen.new,
            page: PageScreen.new,
          ),
        );
}
```

### Step3 - use the navigator in MaterialApp.router

If you are familiar with the Flutter Navigator 2.0 and the riverpod, the following code is understandable:

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

## Code simplification

- using the functional_widget package simplifies widgets typing. 
- some code repeats - it is moved to common dart file

A modified version of the previous example is here: [simple_modified.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/simple_modified.dart).

## Other feartures

### Async navigation and splash screen

See [async.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/async.dart)

```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          fromJson: SimpleSegment.fromJson,
          screenBuilder: (segment) => (segment as SimpleSegment).map(
            home: HomeScreen.new,
            page: PageScreen.new,
          ),
          // returns a Future with the result of an asynchronous operation for a given segment's screen
          segment2AsyncScreenActions: (segment) => (segment as SimpleSegment).maybeMap(
            home: (_) => AsyncScreenActions(creating: (newSegment) => simulateAsyncResult('Home.creating', 2000)),
            page: (_) => AsyncScreenActions(
              creating: (newSegment) => simulateAsyncResult('Page.creating', 400),
              merging: (oldSegment, newSegment) => simulateAsyncResult('Page.merging', 200),
              // async operation during screen deactivating, null means no action.
              deactivating: (oldSegment) => null,
            ),
            orElse: () => null,
          ),
          // splash screen that appears before the first page is created
          splashBuilder: SplashScreen.new,
        );
}

// simulates an action such as loading external data or saving to external storage
Future<String> simulateAsyncResult(String actionName, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return '$actionName: async result after $msec msec';
}
```

### An alternative way to configure the navigator: using the router concept

See [async_with_routes.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/async_with_routes.dart).

This example is functionally identical to the previous one. 
But it uses the concept of "route", where all the parameters for a given segment and screen are together.
A route-like concept can be used for all examples.

```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super.router(
          ref,
          [HomeSegment()],
          RGroup<SimpleSegment>(SimpleSegment.fromJson, routes: [
            RRoute<HomeSegment>(
              builder: HomeScreen.new,
              creating: (newSegment) => simulateAsyncResult('Home.creating', 2000),
            ),
            RRoute<PageSegment>(
              builder: PageScreen.new,
              creating: (newSegment) => simulateAsyncResult('Page.creating', 400),
              merging: (oldSegment, newSegment) => simulateAsyncResult('Page.merging', 200),
              deactivating: null,
            ),
          ]),
        );
}

// simulates an action such as loading external data or saving to external storage
Future<String> simulateAsyncResult(String asyncResult, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return '$asyncResult: async result after $msec msec';
}
```

### More TypedSegment roots

todo

### When the navigation status depends on other providers

todo

### Testing 

Navigation logic can be developed and tested without typing a single flutter widget.

todo

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
