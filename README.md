# Riverpod navigation

### Simple but powerfull Flutter navigation with [riverpod](https://riverpod.dev/), [freezed](https://github.com/rrousselGit/freezed) and Navigator 2.0 that solves the following:

- **Strictly typed navigation:** <br>
you can use ```navigate([HomeSegment(),BookSegment(id: 2)]);``` instead of ```navigate('home/book;id:2');``` in your code.
- **asynchronous navigation**<br>
is the case when changing the navigation state requires asynchronous actions (such as loading or saving data from the Internet)
- **multiple providers**<br>
is the case when the navigation state depends on multiple providers
- **easier coding:** <br>
the problem of navigation is reduced to manipulation an immutable collection.
- **better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
navigation logic can be developed and tested without typing a single flutter widget.
- **nested navigation**<br>
just use the nested riverpod ```ProviderScope()```

#### Two packages

Use [riverpod_navigator package](https://pub.dev/packages/riverpod_navigator) to develop in Flutter.

Note: Most of the code is in the *[riverpod_navigator_core](https://pub.dev/packages/riverpod_navigator_core)* dart library thai is independent of Flutter.
*[riverpod_navigator](https://pub.dev/packages/riverpod_navigator)* addresses the connection to Flutter Navigator 2.0.

## Terminology used

Take a look at the following terms related to url path ```home/book;id=2```

- **string-path:** ```final stringPath = 'home/book;id=2';```
- **string-segment** - the string-path consists of two slash-delimited string-segments: ```home``` and ```book;id=2```
- **typed-segment** - the typed-segment (aka ```class TypedSegment {}``` ) defines string-segment: ```HomeSegment()``` and ```BookSegment(id:2)``` in this case
- **typed-path**: typed-path (aka ```typedef TypedPath = List<TypedSegment>```) : ```[HomeSegment(), BookSegment(id:2)];```
- Flutter Navigator 2.0 **navigation-stack** is specified by TypedPath, where each TypedPath's TypedSegment instance corresponds to a screen and page instance<br>
  ```[MaterialPage (child: HomeScreen(HomeSegment())), MaterialPage (child: BookScreen(BookSegment(id:2)))]```.

## Navigator Data Flow Diagram:

<p align="center">
<img src="https://raw.githubusercontent.com/PavelPZ/riverpod_navigator/master/README.png" alt="riverpod_navigator" />
</p>

As you can see, changing the **Input state** starts the async calculation.
The result of the calculations is **Output state** in navigationStackProvider and possibly app specific **Side effects**.
Connecting *navigationStackProvider* to Flutter Navigator 2.0 is then easy.

The appLogic procedure returns the future with the new navigationStack and its signature is as follows:

```dart
FutureOr<TypedPath> appNavigationLogic(TypedPath oldNavigationStack, TypedPath ongoingPath)
```

## Simple example

### Step1 - imutable classes for typed-segment

We use [freezed-package](https://github.com/rrousselGit/freezed) to generate immutable TypedSegment descendant classes.

It's a good idea to be familiar with the freezed-package (including support for JSON serialization).

From the following SegmentGrp class declaration, the freezed generates two classes: *HomeSegment* and *PageSegment*.

```dart
@freezed
class Segments with _$Segments, TypedSegment {
  Segments._();
  factory Segments.home() = HomeSegment;
  factory Segments.page({required String title}) = PageSegment;

  factory Segments.fromJson(Map<String, dynamic> json) => _$SegmentsFromJson(json);
}
```

### Step2 - navigator parameterization

Extends the RNavigator class as follows.

```dart
class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoutes<Segments>(Segments.fromJson, [ // json deserialize to HomeSegment or PageSegment
              RRoute<HomeSegment>(HomeScreen.new), // assign HomeScreen builder for HomeSegment
              RRoute<PageSegment>(PageScreen.new), // assign PageScreen builder for PageSegment
            ])
          ],
        );

  /// navigate to page
  Future toPage(String title) => navigate([HomeSegment(), PageSegment(title: title)]);

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);
}
```

#### useful extension for screen code

```dart
extension WidgetRefApp on WidgetRef {
  AppNavigator get navigator => read(riverpodNavigatorProvider) as AppNavigator;
}
```

Use in your application:

```dart
   ElevatedButton(onPressed: () => ref.navigator.toPage('Page title'), ...
```

#### useful extension for test code

```dart 
extension ProviderContainerApp on ProviderContainer {
  AppNavigator get navigator => read(riverpodNavigatorProvider) as AppNavigator;
}
```

Use in your test:

```dart
  final container = ProviderContainer();
  await container.navigator.toPage('Page title');
```

### Step3 - the AppNavigator in MaterialApp.router

If you are familiar with the Flutter Navigator 2.0 and the riverpod, the following code is clear:

```dart
class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Riverpod Navigator Example',
        routerDelegate: ref.navigator.routerDelegate,
        routeInformationParser: ref.navigator.routeInformationParser,
      );
}
```

### Step4 - main entry point

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
                onPressed: () => ref.navigator.toHome(),
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      );
}
```

### Step6 - 

Before developing a GUI, it's a good idea to develop and test an invisible application core.

```dart 
ProviderContainer createContainer() {
  final res = ProviderContainer(overrides: RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new));
  addTearDown(res.dispose);
  return res;
}

void main() {
  test('navigation test', () async {
    final container = createContainer();
    final start = DateTime.now();

    Future navigTest(Future action(), String expected) async {
      await action();
      print('${DateTime.now().difference(start).inMilliseconds} msec ($expected)');
      await container.pump();
      expect(container.navigator.navigationStack2Url, expected);
    }

    await navigTest(() => container.navigator.toHome(), 'home');

    await navigTest(() => container.navigator.toPage('Page'), 'home/page;title=Page');

    await navigTest(() => container.navigator.pop(), 'home');

    await navigTest(() => container.navigator.push(PageSegment(title: 'Page2')), 'home/page;title=Page2');

    await navigTest(() => container.navigator.replaceLast((_) => PageSegment(title: 'Page3')), 'home/page;title=Page3');

    return;
  });
}
```

#### Full source code:

[simple.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/simple.dart),
[simple_test.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/test/simple_test.dart)

## Other features doc and samples 

Note: *The following examples are prepared using a **functional_widget package** that simplifies writing widgets.
The use of functional_widget is optional.*

- [Async navigation and splash screen](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/async.md)
- [Login flow](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/login_flow.md)
- [More TypedSegment roots](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/more_groups.md)
- [Nested navigation](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/nested_navigation.md)

## Installation of examples

After clonning repository, go to ```examples\doc``` subdirectory and execute:

- ```flutter create .```
- ```flutter pub get```

You can then run the examples in the */lib* subdirectory of project.

## Roadmap

I prepared this package for my new project. Its further development depends on whether it will be used by the community.

- proofreading because my English is not good. Community help is warmly welcomed.
- BlockGUI widget (block the GUI while asynchronous navigation is waiting to complete)
- parameterization allowing cupertino
