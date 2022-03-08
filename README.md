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

## Index

[Terminology used](#terminology-used)
[Simple example](#simple-example)
    [Step1 - define classes for the typed-segment](#step1---define-classes-for-the-typed-segment)

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
  factory HomeSegment.fromUrlPars(UrlPars pars) => const HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  factory BookSegment.fromUrlPars(UrlPars pars) => BookSegment(id: pars.getInt('id'));

  final int id;
  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);
}
```

Note: *fromUrlPars* and *toUrlPars* helps to convert **typed-segment** to **string-segment** and back.

### Step2 - configure AppNavigator...

... by extending the RNavigator class. 

```dart
class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            /// 'home' and 'book' strings are used in web URL, e.g. 'home/book;id=2'
            /// fromUrlPars is used to decode URL to HomeSegment/BookSegment
            /// HomeScreen/BookScreen.new are screen builders for a given segment
            RRoute<HomeSegment>(
              'home',
              HomeSegment.fromUrlPars,
              HomeScreen.new,
            ),
            RRoute<BookSegment>(
              'book',
              BookSegment.fromUrlPars,
              BookScreen.new,
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
        // [HomeSegment()] as home TypedPath and navigator constructor are required
        overrides: providerOverrides([HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );
```

### Step5 - code screen widgets

There are two screen to code: *HomeScreen* and *BookScreen*. 
Extend this screens from **RScreen** widget.

*RScreen* widget:
- replaces the standard Android back button behavior (using Flutter BackButtonListener widget)
- will provide appBarLeading icon to replace the standard AppBar back button behavior

This is essential for asynchronous navigation to function properly.

```dart
class BookScreen extends RScreen<AppNavigator, BookSegment> {
  const BookScreen(BookSegment segment) : super(segment);

  @override
  Widget buildScreen(ref, navigator, appBarLeading) => Scaffold(
        appBar: AppBar(
          title: Text('Book ${segment.id}'),
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
But it shows the navigation to the four-screen navigation stack:

- **string-path** = ```home/book;id=3/book;id=13/book;id=103```. 
- **typed-path** = ```[HomeSegment(), BookSegment(id:3), BookSegment(id:13), BookSegment(id:103)]```. 
- **navigation-stack** (flutter Navigator.pages) = ```[MaterialPage (child: HomeScreen(HomeSegment())), MaterialPage (child: BookScreen(BookSegment(id:3))), MaterialPage (child: BookScreen(BookSegment(id:13))), MaterialPage (child: BookScreen(BookSegment(id:103)))]```. 

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

## URL parsing

Flutter Navigator 2.0 and its *MaterialApp.router* constructor requires a URL parser (*RouteInformationParser*).
We use URL syntax, see [section 3.3. of RFC 3986](https://www.ietf.org/rfc/rfc3986.txt), note 
*For example, one URI producer might use a segment such as "name;v=1.1"..."

Each *TypedSegment* must be converted to *string-segment* and back. 
The format of *string-segment* is 

```<unique TypedSegment id>[;<property name>=<property value>]*```

e.g. ```book;id=3```.

Instead of directly converting to/from the string, we convert to/from ```typedef UrlPars = Map<String,String>```, e.g.:
```
  factory BookSegment.fromUrlPars(UrlPars pars) => BookSegment(id: pars.getInt('id'));
  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);
```

So far, we support the following types of TypedSegment property: **int, double, bool, String, int?, double?, bool?, String?**. See ```extension UrlParsEx on UrlPars``` in 
[path_parser.dart](https://github.com/PavelPZ/riverpod_navigator/blob/main/packages/riverpod_navigator_core/lib/src/path_parser.dart).

Every aspect of URL conversion can be customized, e.g.
- support another property type (as a DateTime, providing *getDateTime*, *getDateTimeNull* and *setDateTime* *UrlPars*'s extension)
- rewrite the entire *IPathParser* and use a completely different URL syntax. Then use your parser in AppNavigator:

```
class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
....
  	pathParserCreator: (router) => MyPathParser(router),
...         
```

#### TestSegment example:
```dart
class TestSegment extends TypedSegment {
  const TestSegment({required this.i, this.s, required this.b, this.d});

  factory TestSegment.fromUrlPars(UrlPars pars) => TestSegment(
        i: pars.getInt('id'),
        s: pars.getStringNull('s'),
        b: pars.getBool('b'),
        d: pars.getDoubleNull('d'),
      );

  @override
  void toUrlPars(UrlPars pars) => 
    pars.setInt('i', i).setString('s', s).setBool('b', b).setDouble('d', d);

  final int i;
  final String? s;
  final bool b;
  final double? d;
}
```

## Place navigation events in AppNavigator

It is good practice to place the code for all events specific to navigation in AppNavigator.
These can then be used not only for writing screen widgets, but also for testing.

```dart
class AppNavigator extends RNavigator {
  ......
  /// navigate to next book
  Future toNextBook() => replaceLast<BookSegment>((last) => BookSegment(id: last.id + 1));
  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);
}
```

In the screen code, it is used as follows:

```dart
...
ElevatedButton(
  onPressed: navigator.toNextBook,
  child: Text('Book $id'),
), 
... 
```

and in the test code as follows:

```dart
  await navigTest(navigator.toNextBook, 'home/book;id=3');
```

## Async navigation

Navigation is delayed until the asynchronous actions are performed. These actions for each screen are:
- **opening** (before opening a new screen)
- **closing** (before closing the old screen)
- **merging** (before replacing the screen with a screen with the same segment type)

### Define classes for the typed-segment 

Create *asyncHolder* to save the result of the asynchronous action. The screen then uses this result.

```dart
class HomeSegment extends TypedSegment {
  ....
  /// for async navigation: holds async opening or replacing result
  @override
  final asyncHolder = AsyncHolder<String>();
}

class BookSegment extends TypedSegment {
  ....
  /// for async navigation: holds async opening or replacing result
  @override
  final asyncHolder = AsyncHolder<String>();
}
```

### Configure AppNavigator

```dart
class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoute<HomeSegment>(
              'home',
              HomeSegment.fromUrlPars,
              HomeScreen.new,
              opening: (newSegment) => _simulateAsyncResult('Home.opening', 2000),
            ),
            RRoute<BookSegment>(
              'page',
              BookSegment.fromUrlPars,
              BookScreen.new,
              opening: (newSegment) => _simulateAsyncResult('Book.opening', 240),
              replacing: (oldSegment, newSegment) => _simulateAsyncResult('Book.replacing', 800),
              closing: null,
            ),
          ],
        );
....
}

// simulates an action such as loading external data or saving to external storage
Future<String> _simulateAsyncResult(String asyncResult, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return '$asyncResult: async result after $msec msec';
}
```

#### See:

- [running example](https://pavelpz.github.io/doc_async/)
- [source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/async.dart)
- [test code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/test/async_test.dart)

## Other features and examples 

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
