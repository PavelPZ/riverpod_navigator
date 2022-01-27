# Navigator for Riverpod

### Navigation library (based on Flutter Navigator 2.0, [Riverpod](https://riverpod.dev/), and [Freezed](https://github.com/rrousselGit/freezed)) that solves the following problems:

- **Strictly typed navigation:** <br>You can use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId');``` in your code.
- **Easier coding:** <br>The problem of navigation is reduced to manipulation of the immutable collection.
- **Better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
  Navigation logic can be developed and tested in the Dart environment, without typing a single flutter widget.
- **Small codebase with a lot of extensions:**<br>
  The core engine consists of two small .dart files ([riverpod_navigator.dart](packages/riverpod_navigator/lib/src/riverpod_navigator.dart) 
  and [riverpod_navigator_dart.dart](packages/riverpod_navigator_dart/lib/src/riverpod_navigator_dart.dart)).
  Additional features (such as better URL parser, asynchronous navigation, possibility to use routes etc.) are included (and can be created) as configurable extensions.

## Two packages

The "Riverpod navigator" consists of two packages, similar to a "riverpod". The following table explains its similarity:

| Dart only development and testing | Flutter development and testing |
| --- | --- |
| riverpod | flutter_riverpod or hooks_riverpod |
| riverpod_navigation_dart | riverpod_navigation |

## Install and run examples

After clonning repository, go to ```examples/doc/``` subdirectory and execute:

- ```flutter create .```
- ```flutter pub get```
- ```flutter pub run build_runner --delete-conflicting-outputs```
- in [main.dart](examples/doc/lib/main.dart) uncomment the line you want to execute.
- execute ```flutter run```

## Explanation on examples

*For a better understanding, everything is explained on the classic 3-screens example: 
[Home] => [Books] => [Book\*]*

### Examples index

- [Lesson01: simple example](#lesson01-simple-example)
- [Lesson02: example with Dart testing](#lesson02-example-with-dart-testing)
- [Lesson03: asynchronous navigation](#lesson03-asynchronous-navigation)
- [Lesson03.1: splash screen](#lesson031-splash-screen)
- [Lesson04: app logic, more TypedSegment classes per app](#lesson04-app-logic-more-typedsegment-classes-per-app)
- [Lesson05: using the Route concept](#lesson05-using-the-route-concept)
- [Lesson06: splash screen](#lesson06-splash-screen)
- [Lesson07: waiting indicator, navigatorWidgetBuilder](#lesson07-waiting-indicator-navigatorwidgetbuilder)
- [Lesson08: screenBuilder](#lesson08-screenbuilder)

### Lesson01: simple example

Example file is available here: [lesson01.dart](examples/doc/lib/src/lesson01/lesson01.dart) 

#### 1. Classes for typed "url path segments" (TypedSegment)

The Freezed package generates three immutable classes used for writing typed navigation path, e.g<br>
```TypedPath newPath = <TypedSegment>[HomeSegment (), BooksSegment (), BookSegment (id: 3)];```

```dart
@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;
  factory AppSegments.splash() = SplashSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
}
```

#### 2. Dart part of app configuration

Tell the application how to convert segments from JSON.

```dart
final config4DartCreator = () => Config4Dart(initPath: [HomeSegment()], json2Segment: (json, _) => AppSegments.fromJson(json));
```

#### 3. app specific navigator with navigation aware actions

... actions are then used in app widgets.

```dart
const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref, Config4Dart config) : super(ref, config);

  /// navigate to home page
  void toHome() => navigate([HomeSegment()]);
  /// navigate to books page
  void toBooks() => navigate([HomeSegment(), BooksSegment()]);
  /// navigate to book;id=3 page
  void toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  /// cyclic book's navigation (Prev and Next buttons)
  void bookNextPrevButton({bool? isPrev}) {
    assert(getActualTypedPath().last is BookSegment);
    var id = (getActualTypedPath().last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    toBook(id: id);
  }
}
```

#### 4. providers

```dart
final appNavigatorProvider = 
  Provider<AppNavigator>((ref) => AppNavigator(ref, ref.watch(config4DartProvider)));

/// Provider for Flutter 2.0 RouterDelegate
final appRouterDelegateProvider =
    Provider<RiverpodRouterDelegate>((ref) => 
      RiverpodRouterDelegate(ref, ref.watch(configProvider), ref.watch(appNavigatorProvider)));
```
#### 5. Flutter-part of app configuration

```dart
final configCreator = (Config4Dart config4Dart) => Config(
      /// Which widget will be builded for which [TypedSegment].
      /// Used in [RiverpodRouterDelegate] to build pages from [TypedSegment]'s
      screenBuilder: (segment) => (segment as AppSegments).map(
        home: (home) => HomeScreen(home),
        books: (books) => BooksScreen(books),
        book: (book) => BookScreen(book),
      ),
      config4Dart: config4Dart,
    );

```
#### 6. root widget for app

Using functional_widget package to be less verbose. Package generates "class BooksExampleApp extends ConsumerWidget...", see *.g.dart.
"functional_widget" is not a mandatory app dependency.

```dart
@cwidget
Widget booksExampleApp(WidgetRef ref) => MaterialApp.router(
      title: 'Books App',
      routerDelegate: ref.watch(appRouterDelegateProvider),
      routeInformationParser: RouteInformationParserImpl(ref.watch(config4DartProvider)),
    );
```
#### 7. app entry point...

... with ProviderScope and ProviderScope.overrides

```dart
void main() {
  runApp(ProviderScope(
    // initialize providers with the configurations defined above
    overrides: [
      config4DartProvider.overrideWithValue(config4DartCreator()),
      configProvider.overrideWithValue(configCreator(config4DartCreator())),
    ],
    child: const BooksExampleApp(),
  ));
}
```

#### 8. app screens

File with screen widgets is available here: [screens.dart](examples/doc/lib/src/lesson01/screens.dart) 

-------------------------

### Lesson02: example with Dart testing

An example that allows flutter-independent testing.

*to be done*

-------------------------

### Lesson03: asynchronous navigation

See changes against Example01 (added part 1.1, parts 2. and 3. are modified).

Example file is available here: [lesson03.dart](examples/doc/lib/src/lesson03/lesson03.dart). 

#### 1.1 async screen actions

Add new code for async screen actions.

```dart
AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
  Future<String> simulateAsyncResult(String title, int msec) async {
    await Future.delayed(Duration(milliseconds: msec));
    return title;
  }

  return (segment as AppSegments).maybeMap(
    book: (_) => AsyncScreenActions<BookSegment>(
      // for every Book screen: creating takes some time
      creating: (newSegment) async => simulateAsyncResult('Book creating async result after 1 sec', 1000),
      // for every Book screen with odd id: changing to another Book screen takes some time
      merging: (_, newSegment) async => 
        newSegment.id.isOdd ? simulateAsyncResult('Book merging async result after 500 msec', 500) : null,
      // for every Book screen with even id: creating takes some time
      deactivating: (oldSegment) => 
        oldSegment.id.isEven ? Future.delayed(Duration(milliseconds: 500)) : null,
    ),
    home: (_) => AsyncScreenActions<HomeSegment>(
        // Home screen takes some timefor creating
        creating: (_) async => simulateAsyncResult('Home creating async result after 1 sec', 1000)),
    orElse: () => null,
  );
}}
```

#### 2. Configure dart-part of app

Add ```segment2AsyncScreenActions``` to config

```dart
final config4DartCreator = () => Config4Dart(
      json2Segment: (json, _) => AppSegments.fromJson(json),
      initPath: [HomeSegment()],
      segment2AsyncScreenActions: segment2AsyncScreenActions,
    );
```

#### 3. app-specific navigator with navigation aware actions

AppNavigator extends AsyncRiverpodNavigator instead of RiverpodNavigator

```dart
class AppNavigator extends AsyncRiverpodNavigator {
  ...
```

-------------------------

### Lesson03.1: splash screen

#### 1. Classes for typed "url path segments" (TypedSegment)

Add SplashSegment definition

```dart
@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;
  factory AppSegments.splash() = SplashSegment; // <========

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
}
```

#### 2. Dart part of app configuration

Specify splashPath.

```dart
final config4DartCreator = () => Config4Dart(
      json2Segment: (json, _) => AppSegments.fromJson(json),
      segment2AsyncScreenActions: segment2AsyncScreenActions,
      initPath: [HomeSegment()],
      splashPath: [SplashSegment()], // <========
    );
```  

#### 5. Flutter-part of app configuration

Specify splash screen builder.

```dart
final configCreator = (Config4Dart config4Dart) => Config(
      /// Which widget will be builded for which [TypedSegment].
      /// Used in [RiverpodRouterDelegate] to build pages from [TypedSegment]'s
      screenBuilder: (segment) => (segment as AppSegments).map(
        home: (s) => HomeScreen(s),
        books: (s) => BooksScreen(s),
        book: (s) => BookScreen(s),
        splash: (s) => SplashScreen(s), // <========
      ),
      config4Dart: config4Dart,
    );
```

#### 8. app screens

Add SplashScreen widget to [screens.dart](examples/doc/lib/src/lesson031/screens.dart)

-------------------------

### Lesson04: app logic, more TypedSegment classes per app

Simple Login navigation flow

*to be done*

-------------------------

### Lesson05: using the Route concept

*to be done*

-------------------------

### Lesson06: splash screen

*to be done*

-------------------------

### Lesson07: waiting indicator, navigatorWidgetBuilder

*to be done*

-------------------------

### Lesson08: screenBuilder

*to be done*

