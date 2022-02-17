# Riverpod navigation

### Simple but powerfull Flutter navigation with [riverpod](https://riverpod.dev/), [freezed](https://github.com/rrousselGit/freezed) and Navigator 2.0 that solves the following problems:

- **strictly typed navigation:** <br>
you can use ```navigate([HomeSegment(),BookSegment(id: 2)]);``` instead of ```navigate('home/book;id:2');``` in your code.
- **asynchronous navigation**<br>
is the case when changing the navigation state requires asynchronous actions (such as loading or saving data from the Internet)
- **multiple providers**<br>
this is the case when the navigation state depends on multiple providers, e.g. on the login state
- **nested navigation**: 
- **easier coding:** <br>
The problem of navigation is reduced to manipulation an immutable collection.
- **better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
navigation logic can be developed and tested without typing a single flutter widget.

## The mission

Take a look at the following terms related to url path ```home/book;id=2```

- **string-path:** ```final stringPath = 'home/book;id=2';```
- **string-segment** - the string-path consists of two string-segments: 'home'and 'book;id=2'
- **typed-segment** - the typed-segment is immutable class that defines string-segment: HomeSegment() and BookSegment(id:2) in this case
- **typed-path**: typed-path can be understood as List<typed-segment>: ```final typedPath = [HomeSegment(), BookSegment(id:2)];```
- **navigation-stack** of Flutter Navigator 2.0 is a stack of screens, parameterized by typed-segment:
  ```[HomeScreen(HomeSegment())), BookScreen(BookSegment(id:2))]```

The mission of the navigation is to keep *string-path* <= **typed-path** => *navigation-stack* always in sync.
With the **typed-path** as the source of the truth.

Note: *There is a one-to-one relationship between the given segment and the screen (HomeSegment <-> HomeScreen, BookSegment <-> BookScreen, ...).
In the following text, I sometimes confuse this two terms.*

## Simple example

### Step1 - imutable classes for typed-segment

We use [freezed-package](https://github.com/rrousselGit/freezed) for generation immutable clasess (that defines typed-segment's).

It's a good idea to be familiar with the freezed-package (including support for JSON serialization).

From the following SegmentGrp class declaration, the freezed package 
generates two classes: *HomeSegment* and *PageSegment*.

```dart
@Freezed(maybeWhen: false, maybeMap: false)
class Segments with _$Segments, TypedSegment {
  Segments._();
  factory Segments.home() = HomeSegment;
  factory Segments.page({required String title}) = PageSegment;

  factory Segments.fromJson(Map<String, dynamic> json) => _$SegmentsFromJson(json);
}```

### Step2 - navigator parameterization

Extends the RNavigator class as follows.

```dart
class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<HomeSegment>(HomeScreen.new), // build a screen from segment
              RRoute<PageSegment>(PageScreen.new),
            ])
          ],
        );

  //******* screen actions

  /// navigate to page
  Future toPage(String title) => navigate([HomeSegment(), PageSegment(title: title)]);

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);
}

/// helper extension for screens
extension WidgetRefApp on WidgetRef {
  AppNavigator get navigator => read(riverpodNavigatorProvider) as AppNavigator;
}

/// helper extension for test
extension RefApp on Ref {
  AppNavigator get navigator => read(riverpodNavigatorProvider) as AppNavigator;
}
```

### Step3 - use the RNavigator in MaterialApp.router

If you are familiar with the Flutter Navigator 2.0 and the riverpod, the following code is clear:

```dart
class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.navigator;
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
        overrides: RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );
```

### Step5 - widgets for screens

```dart 
class HomeScreen extends ConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                // following navigation create navigation stack [HomeScreen(HomeSegment()) => PageScreen(PageSegment(title: 'Page title'))].
                onPressed: () => ref.navigator.toPage('Page'),
                child: const Text('Go to page'),
              ),
            ],
          ),
        ),
      );
}

class PageScreen extends ConsumerWidget {
  const PageScreen(this.segment, {Key? key}) : super(key: key);

  final PageSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: Text(segment.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                // following navigation create navigation stack "HomeScreen(HomeSegment())".
                onPressed: () => ref.navigator.toHome(),
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      );
}
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
