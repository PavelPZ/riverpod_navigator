# Navigator for Riverpod

### Simple but powerfull navigation library (based on Flutter Navigator 2.0, [Riverpod](https://riverpod.dev/), and [Freezed](https://github.com/rrousselGit/freezed)) that solves the following problems:

- **Strictly typed navigation:** <br>You can use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId');``` in your code.
- **Easier coding:** <br>The problem of navigation is reduced to manipulation an immutable collection.
- **Better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
  Navigation logic can be developed and tested without typing a single flutter widget.
- **Asynchronous navigation:**<br>
  Before starting navigation, prepare all necessary asynchronous screen operations, e.g.
  - load data for the new screen
  - save data from the previous screen
- **Dependence on external providers:**<br>
  The navigation state may also depend on external riverpod providers, e.g. on login status
- **Nested navigation**

## The mission

Take a look at the following terms related to url path ```home/books/book;id=2```

- **string-path:** ```final stringPath = 'home/books/book;id=2';```
- **string-segment** - the string-path consists of three string-segments: 'home', 'books' and 'book;id=2'
- **typed-segment** - the typed-segment is immutable class that defines string-segment: HomeSegment(), BooksSegment() and BookSegment(id:2)
- **typed-path**: typed-path can be understood as List<typed-segment>: ```final typedPath = [HomeSegment(), BooksSegment(), BookSegment(id:2)];```
- **navigation-stack** of Flutter Navigator 2.0 is a stack of screens, parameterized by typed-segment:
  ```[HomeScreen(HomeSegment())), BooksScreen(BooksSegment()), BookScreen(BookSegment(id:2))]```

The mission of the navigation is to keep *string-path* <= **typed-path** => *navigation-stack* always in sync.
With the **typed-path** as the source of the truth.

Note: *There is a one-to-one relationship between the given segment and the screen (HomeSegment - HomeScreen, BookSegment - BookScreen).
In the following text, I sometimes confuse this two terms.*

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
      : super(
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
    );
  }
}

```

### Step4 - runApp

```dart
void main() => runApp(
      ProviderScope(
        overrides: [
          riverpodNavigatorProvider.overrideWithProvider(Provider(AppNavigator.new)),
        ],
        child: const App(),
      ),
    );
```

### Step5 - widgets for screens

Creating screen widgets is probably an understandable part of the example.

Only the navigation to the new screen is interesting:

```dart
//  create navigation stack [HomeScreen(HomeSegment()), PageScreen(PageSegment(title: 'Page title'))]
ref.read(riverpodNavigatorProvider).navigate([HomeSegment(), PageSegment(title: 'Page')]);
```

or 

```dart
//  create navigation stack [HomeScreen(HomeSegment())]
ref.read(riverpodNavigatorProvider).navigate([HomeSegment()]);
```

#### Code of the example

The full code is available here:
[simple.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/simple.dart).

## Other features doc and samples 

Note: *The following examples are prepared using a **functional_widget package** that simplifies writing widgets.
The use of functional_widget is not mandatory*

- [Async navigation and splash screen](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/async_navigation_splash_screen.md)
- [Login flow](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/login_flow.md)
- [Testing](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/testing.md)
- [More TypedSegment roots](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/more_typedSegment_roots.md)
- [Nested navigation](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/nested_navigation.md)

## See [What's under the hood](https://github.com/PavelPZ/riverpod_navigator/blob/main/under_the_hood.md) for riverpod_navigation principle

## Installation of examples

After clonning repository, go to ```examples\doc``` subdirectory and execute:

- ```flutter create .```
- ```flutter pub get```

## Comparison with go_router

This chapter is inspired by this riverpod issue: [Examples of go_router using riverpod](https://github.com/rrousselGit/river_pod/issues/1122).

| example | go_router | code lines | riverpod_navigator | code lines |
| --- | --- | --- | --- | --- |
| main | [source code](https://github.com/csells/go_router/blob/main/go_router/example/lib/main.dart) | 70 | [source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/go_router/lib/main.dart) | 84  |
| redirection | [source code](https://github.com/csells/go_router/blob/main/go_router/example/lib/redirection.dart) | 167 | [source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/go_router/lib/redirection.dart) | 149 |

If you are interested in preparing another go_router example, I will try to do it.

## Roadmap

I prepared this package for my new project. Its further development depends on whether it will be used by the community.

- proofreading because my English is not good. Community help is warmly welcomed.
- BlockGUI widget (block the GUI while asynchronous navigation is waiting to complete)
- parameterization allowing  cupertino
