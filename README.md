# Navigator for Riverpod

### Simple but powerfull navigation library (based on Flutter Navigator 2.0, [Riverpod](https://riverpod.dev/), and [Freezed](https://github.com/rrousselGit/freezed)) that solves the following problems:

- **Strictly typed navigation:** <br>You can use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId');``` in your code.
- **Easier coding:** <br>The problem of navigation is reduced to manipulation an immutable collection.
- **Better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
  Navigation logic can be developed and tested without typing a single flutter widget.
- **Asynchronous navigation:**<br>
  Prepare all necessary asynchronous operations before the navigation starts, e.g.
  - loading data for new screen
  - save data from the previous screen
- **Dependence on external providers:**<br>
  The navigation state may also depend on external providers, e.g. on login status
- **Possibility to configure many navigation parameters**

## The mission

Take a look at the following terms:

- **string path:** ```stringPath = 'home/books/book;id=2';```
- **string segment** - the string path consists of three string segments: 'home', 'books', 'book;id=2'
- **typed path**: ```typedPath = <TypedSegment>[HomeSegment(), BooksSegment(), BookSegment(id:2)];```
- **typed segment** - the typed path consists of three instances of [TypedSegment]'s: [HomeSegment], [BooksSegment], [BookSegment]
- **navigation stack** of Flutter Navigator 2.0: ```HomeScreen(HomeSegment())) => BooksScreen(BooksSegment()) => BookScreen(BookSegment(id:3))```

The mission of navigation is to keep *string path* <= **typed path** => *navigation stack* always in sync.
With **typed path** as the source of the truth.

## How does it work

If anyone wants to understand how the riverpod_navigator package works, 
let them look at [riverpod_navigator_example](examples/riverpod_navigator_example/).

The repository verifies the idea of connecting [Riverpod](https://riverpod.dev/) + [Freezed](https://github.com/rrousselGit/freezed) + flutter Navigator 2.0.

## How to use it

The best documentation is a simple source code. 
See an example of the classic ```Home => Books => Book*``` application in Lesson01 ... Lesson05 below.
Lesson03 ... Lesson05 add a simple login logic.
### Lesson01

(whole example see at [lesson01.dart source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/lesson01/lesson01.dart))


### 1. define classes for typed path segments (aka TypedSegment)

From the following AppSegments class declaration, the [freezed package](https://github.com/rrousselGit/freezed) 
generates three typed segment classes: *HomeSegment, BooksSegment and BookSegment*.

```dart
@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
}
```

### 2. Type App-specific navigator (aka AppNavigator)

AppNavigator is a singleton class that does the following:
- configures various navigation parameters 
- contains actions related to navigation. The actions are then used in the screen widgets.

#### 2.1. Navigation parameters



```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          // home (initial) navigation path
          initPath: [HomeSegment()],
          // how to decode JSON to AppSegments
          json2Segment: (jsonMap, _) => AppSegments.fromJson(jsonMap),
          // map TypedSegment's to Screens
          screenBuilder: appSegmentsScreenBuilder,
        );
```

#### 2.2. Common navigation actions



```dart
//
  Future<void> toHome() => navigate([HomeSegment()]);

  Future<void> toBooks() => navigate([HomeSegment(), BooksSegment()]);

  Future<void> toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);

  Future<void> bookNextPrevButton({bool? isPrev}) {
    assert(currentTypedPath.last is BookSegment);
    var id = (currentTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    return toBook(id: id);
  }
```

### 3. Root widget

Note: *To make it less verbose, we use the functional_widget package to generate widgets.
See generated "lesson??.g.dart"" file for details.*

```dart
@cwidget
Widget booksExampleApp(WidgetRef ref) {
  final navigator = ref.read(riverpodNavigatorProvider);
  return MaterialApp.router(
    title: 'Books App',
    routerDelegate: navigator.routerDelegate as RiverpodRouterDelegate,
    routeInformationParser: RouteInformationParserImpl(navigator.pathParser),
    debugShowCheckedModeBanner: false,
  );
}
```

### 4. App entry point

app entry point with ProviderScope's override

```dart
void runMain() => runApp(
    ProviderScope(
      overrides: [
        riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new /*See Constructor tear-offs in Dart ^2.15*/),
      ],
      child: const BooksExampleApp(),
    ),
  );
```

### 5. Map TypedSegment's to Screens

You can view all application screens and widgets here: [screen.dart source code](https://github.com/PavelPZ/riverpod_navigator/blob/main/examples/doc/lib/src/lesson01/screens.dart)

```dart
final ScreenBuilder appSegmentsScreenBuilder = (segment) => (segment as AppSegments).map(
  // See Constructor tear-offs in Dart ^2.15, "HomeScreen.new" is equivalent to "(segment) => HomeScreen(segment)"
      home: HomeScreen.new,
      books: BooksScreen.new,
      book: BookScreen.new,
    );
```

## Other lessons:

### Lesson02
Lesson02 is [lesson01](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson01.md) enhanced with:

- asynchronous navigation when screens require some asynchronous actions (when creating, deactivating, or merging)
- the splash screen appears before the HomeScreen is displayed

See [lesson02 documentation](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson02.md)

### Lesson03
Lesson03 is [lesson02](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson02.md) extended by:

- login application logic (where some pages are not available without a logged in user)
- more TypedPath roots (AppSegments and LoginSegments)
- navigation state also depends on another provider (userIsLoggedProvider)

See [lesson03 documentation](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson03.md)

### Lesson04
Lesson04 is [lesson03](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson03.md) prepared using the router concept.

See [lesson04 documentation](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson04.md)

### Lesson05
Lesson05 is the same as [lesson03](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson03.md) but without screens and widgets.
It has not any GUI, only a test.

See [lesson05 documentation](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson05.md)

### Doc TODO

In this case, it is an advanced parameterization. Applies to the RouterDelegate.build method.

It is possible to parameterize the values **navigator.screen2Page** and **navigator.navigatorWidgetBuilder** below:
```dart
@override
  Widget build(BuildContext context) {
    final actPath = currentConfiguration;
    if (actPath.isEmpty) return navigator.splashBuilder?.call() ?? SizedBox();
    final navigatorWidget = Navigator(
        key: navigatorKey,
        // segment => screen
        pages: actPath.map((segment) => navigator.screen2Page!(segment, navigator.screenBuilder!)).toList(),
        onPopPage: (route, result) {
          //if (!route.didPop(result)) return false;
          // remove last segment from path
          navigator.onPopRoute();
          return false;
        });
    return navigator.navigatorWidgetBuilder == null ? navigatorWidget : navigator.navigatorWidgetBuilder!(context, navigatorWidget);
  }
```

## Roadmap

I prepared the package for my new project. Its further development depends on whether it will be used by the community.

- proofreading because my English is not good. Community help is warmly welcomed.
- testing on mobile (tested so far for windows and web)<br>
  Navigator.onPopPage may need improvements.
- nested navigation flow<br>
  I think everything is ready, nested ProviderScope can solve nested navigation too.
- BlockGUI widget (block the GUI while asynchronous navigation is waiting to complete)
- parameterization alowing cupertino