# Riverpod navigation

### Simple but powerful Flutter navigation with [riverpod](https://riverpod.dev/) and Navigator 2.0 that solves the following:

- **Strictly typed navigation:** <br>
you can use ```navigate([HomeSegment(),BookSegment(id: 2)]);``` instead of ```navigate('home/book;id:2');``` in your code
- **asynchronous navigation** ...<br>
... is the case when changing the navigation state requires asynchronous actions (such as loading or saving data from the Internet)
- **multiple providers** ...<br>
... is the case when the navigation state depends on multiple riverpod providers
- **easier coding:** <br>
the navigation problem is reduced to manipulating the class collection
- **better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
navigation logic can be developed and tested without typing a single flutter widget
- **nested navigation**<br>
just use the nested riverpod ```ProviderScope()``` and Flutter ```Router``` widget

## Terminology used

Take a look at the following terms related to URL path ```home/book;id=2```

- **string-path:** e.g. ```home/book;id=2```
- **string-segment:** the *string-path* consists of two slash-delimited *string-segment*s (```home``` and ```book;id=2```)
- **typed-segment** describes coresponding *string-segment*s (```HomeSegment()``` for 'home' and ```BookSegment(id:2)``` for 'book;id=2')<br>
*typed-segment* is ```class TypedSegment {}```'s descendant.
- **typed-path** describes coresponding *string-path* (```[HomeSegment(), BookSegment(id:2)]```)<br>
*typed-path* is ```typedef TypedPath = List<TypedSegment>```
- Flutter Navigator 2.0 **navigation-stack** is uniquely determined by the TypedPath (where each TypedPath's *TypedSegment* instance corresponds to a screen and page instance):<br>
  ```pages = [MaterialPage (child: HomeScreen(HomeSegment())),  MaterialPage (child: BookScreen(BookSegment(id:2)))]```

## Simple example

Create an application using these simple steps:

### Step1 - define classes for the typed-segment 

```dart
class HomeSegment extends TypedSegment {
  const HomeSegment();

  /// used for decoding HomeSegment from URL
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars pars) => const HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});

  /// used for decoding BookSegment from URL
  factory BookSegment.fromUrlPars(UrlPars pars) => BookSegment(id: pars.getInt('id'));

  /// used for encoding BookSegment to URL
  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);

  final int id;
}
```

Note: *fromUrlPars* and *toUrlPars* helps to convert **typed-segment** to **string-segment** and back.
This is needed for Flutter on the Web.

### Step2 - configure AppNavigator...

... by extending the RNavigator class. 

```dart
class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            /// 'home' and 'book' strings are used in web URL, e.g. 'home/book;id=2'
            /// fromUrlPars is used to decode URL to segment
            /// HomeScreen.new and BookScreen.new are screen builders for a given segment
            /// screenTitle is not mandatory but allows a general solution e.g. for [AppBar.title]
            RRoute<HomeSegment>(
              'home',
              HomeSegment.fromUrlPars,
              HomeScreen.new,
              screenTitle: (_) => 'Home',
            ),
            RRoute<BookSegment>(
              'book',
              BookSegment.fromUrlPars,
              BookScreen.new,
              screenTitle: (segment) => 'Book ${segment.id}',
            ),
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
    );
  }
}
```

### Step4 - configure riverpod ProviderScope ...

... in main entry point

```dart
void main() => runApp(
      ProviderScope(
        // ProviderScope.overrides: home typed-path and navigator constructor are required
        overrides: providerOverrides([HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );
```

### Step5 - code screen widgets

There are two screen to code: *HomeScreen* and *BookScreen*. 
Extends this screens from RScreen widget.

RScreen widget:
- replaces the standard Android back button behavior (using Flutter BackButtonListener widget)
- will provide appBarLeading icon to replace the standard AppBar back button behavior

This is essential for asynchronous navigation to function properly.

```dart
class BookScreen extends RScreen<AppNavigator, BookSegment> {
  const BookScreen(BookSegment segment) : super(segment);

  @override
  Widget buildScreen(ref, navigator, appBarLeading) => Scaffold(
        appBar: AppBar(
          /// navigator.screenTitle(segment) returns screen title defined in 
          /// RRoute<BookSegment>.screenTitle: (segment) => 'Book ${segment.id}'
          title: Text(navigator.screenTitle(segment)),
          /// [appBarLeading] overrides standard back button behavior
          leading: appBarLeading,
        ),
        body: 
  ...
```

#### And that's all

See:

- [running example](https://pavelpz.github.io/doc_simple/)
- [source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/simple.dart)
- [test code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/test/simple_test.dart)

*Note*: The link ```Go to book: [3, 13, 103]``` in the [running example](https://pavelpz.github.io/doc_simple/) would not make much sense in the real Books application.
It shows the navigation to the four-screen navigation stack:

- **string-path** = ```home/book;id=3/book;id=13/book;id=103```. 
- **typed-path** = ```[HomeSegment(), BookSegment(id:3), BookSegment(id:13), BookSegment(id:103)]```. 
- **navigation-stack** flutter Navigator.pages = ```[MaterialPage (child: HomeScreen(HomeSegment())), MaterialPage (child: BookScreen(BookSegment(id:3))), MaterialPage (child: BookScreen(BookSegment(id:13))), MaterialPage (child: BookScreen(BookSegment(id:103)))]```. 

### Development and testing without GUI

Navigation logic can be developed and tested without typing a single flutter widget:

```dart 
  test('navigation model', () async {
    final container = ProviderContainer(
      overrides: providerOverrides([HomeSegment()], AppNavigator.new),
    );
    final navigator = container.read(navigatorProvider);
    
    Future navigTest(Future action(), String expected) async {
      await action();
      await container.pump();
      expect(navigator.navigationStack2Url, expected);
    }

    await navigTest(
      () => navigator.navigate([HomeSegment(), BookSegment(id: 1)]),
      'home/book;id=1',
    );
    await navigTest(
      () => navigator.pop(),
      'home',
    );
    await navigTest(
      () => navigator.push(BookSegment(id: 2)),
      'home/book;id=2',
    );
    await navigTest(
      () => navigator.replaceLast<BookSegment>((old) => BookSegment(id: old.id + 1)),
      'home/book;id=3',
    );
  });
```

## Navigation aware events to AppNavigator

It is good practice to place the code for all events specific to navigation in AppNavigator.
These can then be used not only for writing screen widgets, but also for testing.
See ```toNextBook``` action bellow:

```dart
class AppNavigator extends RNavigator {
  ......
  /// navigate to next book
  Future toNextBook() => replaceLast<BookSegment>((last) => BookSegment(id: last.id + 1));
  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);
  /// navigate to book
  Future toBook({required int id}) => navigate([HomeSegment(), BookSegment(id: id)]);
}
```

The use in the widget code then looks like this

```dart
...
ElevatedButton(
  onPressed: () => navigator.toBook(id),
  child: Text('Book $id'),
), 
... 
```

and in test like this:

```dart
  await navigTest(() => navigator.toBook(2), 'home/book;id=2');
```

## The screen title can be used in the screen link as well.

In a Simple example, we used *RRoute<BookSegment>* parameter ```screenTitle: (segment) => 'Book ${segment.id}'``` for the value of the screen ```AppBar.title```. The same title can be used in the screen link (in *ListTile*, *ElevatedButton* etc.). 

Use the *Path* variant of the helper methods (*navigatePath*, *replaceLastPath*, *pushPath*, *popPath*)
in AppNavigator:

```dart
class AppNavigator extends RNavigator {
  ......
  /// navigate to next book
  NavigatePath toNextBook() => replaceLastPath<BookSegment>((last) => BookSegment(id: last.id + 1));
  /// navigate to home
  NavigatePath toHome() => navigatehPath([HomeSegment()]);
  /// navigate to book
  NavigatePath toBook({required int id}) => navigatePat([HomeSegment(), BookSegment(id: id)]);
}
```

Define a link widget that matches the design of your application, e.g.:

```dart
class MyLinkButton extends ElevatedButton {
  MyLinkButton(NavigatePath navigatePath)
      : super(
          onPressed: navigatePath.onPressed,
          child: Text(navigatePath.title),
        );
}
```

Use MyLinkButton in the screen code:

```dart
...
MyLinkButton(navigator.toBook(id))
... 
```

and in the test code:

```dart
  await navigTest(navigator.toBook(2).navigate, 'home/book;id=2');
```

## Other features and examples 

- ### [Async navigation](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/async.md)
- ### [Login flow](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/login_flow.md)
- ### [Nested navigation](https://github.com/PavelPZ/riverpod_navigator/blob/main/features/nested_navigation.md)

## Installation of examples

After cloning the [riverpod_navigator repository](https://github.com/PavelPZ/riverpod_navigator), go to ```examples/doc``` subdirectory and execute:

- ```flutter create .```
- ```flutter pub get```

See the */lib* subdirectory for examples.

## Navigator Data Flow Diagram:

<p align="center">
<img src="https://raw.githubusercontent.com/PavelPZ/riverpod_navigator/master/README.png" alt="riverpod_navigator" />
</p>

As you can see, changing the **Input state** starts the async calculation.
The result of the calculations is **Output state** which can have app-specific **Side effects**.
Navigator 2.0 RouterDelegate is then synchronized with *navigationStackProvider*

## Roadmap

I prepared this package for my new project. Its further development depends on whether the community will use it.

- proofreading because my English is not good. Community help is warmly welcomed.
- parameterization allowing Cupertino
