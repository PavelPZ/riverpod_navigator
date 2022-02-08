
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
