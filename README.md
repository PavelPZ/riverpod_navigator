# Riverpod navigation

### Simple but powerful Flutter navigation with [riverpod](https://riverpod.dev/), [freezed](https://github.com/rrousselGit/freezed) and Navigator 2.0 that solves the following:

- **Strictly typed navigation:** <br>
you can use ```navigate([HomeSegment(),BookSegment(id: 2)]);``` instead of ```navigate('home/book;id:2');``` in your code
- **asynchronous navigation**<br>
is the case when changing the navigation state requires asynchronous actions (such as loading or saving data from the Internet)
- **multiple providers**<br>
is the case when the navigation state depends on multiple riverpod providers
- **easier coding:** <br>
the problem of navigation is reduced to manipulation an immutable collection
- **better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
navigation logic can be developed and tested without typing a single flutter widget
- **nested navigation**<br>
just use the nested riverpod ```ProviderScope()``` and Flutter ```Router``` widget

## Terminology used

Take a look at the following terms related to URL path ```home/book;id=2```

- **string-path:** ```final stringPath = 'home/book;id=2';```
- **string-segment:** the string-path consists of two slash-delimited string-segments (```home``` and ```book;id=2```)
- **typed-segment:** (```class TypedSegment {}```'s descendant) describes coresponding string-segment's (```HomeSegment()``` and ```BookSegment(id:2)```)
- **typed-path**: (```typedef TypedPath = List<TypedSegment>```) describes coresponding string-path (```[HomeSegment(), BookSegment(id:2)];```)
- Flutter Navigator 2.0 **navigation-stack** is uniquely determined by the TypedPath (where each TypedSegment instance corresponds to a screen and page instance):<br>
  ```[MaterialPage (child: HomeScreen(HomeSegment())),  MaterialPage (child: BookScreen(BookSegment(id:2)))]```

## Navigator Data Flow Diagram:

<p align="center">
<img src="https://raw.githubusercontent.com/PavelPZ/riverpod_navigator/master/README.png" alt="riverpod_navigator" />
</p>

As you can see, changing the **Input state** starts the async calculation.
The result of the calculations is **Output state** which can have app-specific **Side effects**.
Navigator 2.0 RouterDelegate is then synchronized with *navigationStackProvider*

## Simple example

Create an application using these simple steps:

### Step1 - define imutable classes for the typed-segment

We use [freezed-package](https://github.com/rrousselGit/freezed) to generate immutable TypedSegment descendant classes.

It's a good idea to be familiar with the freezed-package (including support for JSON serialization).

From the following *Segments* class declaration, the freezed generates two classes: *HomeSegment* and *PageSegment*.

```dart
@freezed
class Segments with _$Segments, TypedSegment {
  Segments._();
  /// Segments.home() means that the string 'home' appears in the web URL, e.g. '/home'
  factory Segments.home() = HomeSegment;
  /// the Segments.page() means that the string 'page' appeares in web url, e.g. '/page;title=title'
  factory Segments.page({required String title}) = PageSegment;

  factory Segments.fromJson(Map<String, dynamic> json) => _$SegmentsFromJson(json);
}
```

### Step2 - Configure AppNavigator...

by extending the RNavigator class:

```dart
class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoutes<Segments>(Segments.fromJson, [ // deserialize HomeSegment or PageSegment
              RRoute<HomeSegment>(HomeScreen.new), // assign HomeScreen builder for HomeSegment
              RRoute<PageSegment>(PageScreen.new), // assign PageScreen builder for PageSegment
            ])
          ],
        );
}
```

### Step3 - use the AppNavigator in MaterialApp.router

If you are familiar with the Flutter Navigator 2.0 and the riverpod, the following code is clear:

```dart
class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.read(navigatorProvider) as AppNavigator;
    return MaterialApp.router(
      title: 'Riverpod Navigator Example',
      routerDelegate: navigator.routerDelegate,
      routeInformationParser: navigator.routeInformationParser,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### Step4 - Place and configure riverpod ProviderScope ...

... in main entry point

```dart
void main() => runApp(
      ProviderScope(
        // home-path and navigator constructor are required
        overrides: RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );
```

### And that's all

Navigation to a specific screen is performed as follows:

```dart
// navigation to PageScreen
ElevatedButton(
  onPressed: () => ref.read(navigatorProvider).navigate([HomeSegment(), PageSegment(title: 'Page')]),

// navigation to HomeScreen
ElevatedButton(
  onPressed: () => ref.read(navigatorProvider).navigate([HomeSegment()]),
```

Whole source code and test see:

- [simple.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/simple.dart)
- [simple_test.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/test/simple_test.dart)

### Testing

Before developing a GUI, it is good practice to develop and test the invisible part of the application (app model and state).
It is advantageous to use a dart test environment, see:

```dart 
  test('navigation test', () async {
    final container = ProviderContainer(overrides: RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new));
    final navigator = container.read(navigatorProvider);

    Future navigTest(Future action(), String expected) async {
      await action();
      await container.pump();
      expect(navigator.navigationStack2Url, expected);
    }

    await navigTest(() => navigator.navigate([HomeSegment()]), 'home');

    await navigTest(() => navigator.navigate([HomeSegment(), PageSegment(title: 'Page')]), 'home/page;title=Page');

    await navigTest(() => navigator.pop(), 'home');

    await navigTest(() => navigator.push(PageSegment(title: 'Page2')), 'home/page;title=Page2');

    await navigTest(() => navigator.replaceLast<PageSegment>((old) => PageSegment(title: 'X${old.title}')), 'home/page;title=XPage2');
  });
```

## Other features and examples 

- [Async navigation and splash screen](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/async.md)
- [Login flow](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/login_flow.md)
- [More TypedSegment roots](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/more_groups.md)
- [Nested navigation](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/nested_navigation.md)

Note: *The examples are prepared using a **[functional_widget package](https://pub.dev/packages/functional_widget)** that simplifies writing widgets.
The use of functional_widget is optional.*

## Installation of examples

After cloning the [riverpod_navigator repository](https://github.com/PavelPZ/riverpod_navigator), go to ```examples/doc``` subdirectory and execute:

- ```flutter create .```
- ```flutter pub get```

See the */lib* subdirectory for examples.

## Roadmap

I prepared this package for my new project. Its further development depends on whether the community will use it.

- proofreading because my English is not good. Community help is warmly welcomed.
- parameterization allowing Cupertino
