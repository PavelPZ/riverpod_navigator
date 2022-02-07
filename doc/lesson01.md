
### Lesson01
- simple example

See [lesson01.dart source code](/examples/doc/lib/src/lesson01/lesson01.dart)

### 1. classes for typed path segments (aka TypedSegment)

From the following definition, [freezed package](https://github.com/rrousselGit/freezed) generates three typed segment classes: 
HomeSegment, BooksSegment and BookSegment.

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

### 2. App-specific navigator

- contains actions related to navigation. The actions are then used in the screen widgets.
- configures various navigation parameters

```dart
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
  //*** parameters common to all examples
          /// home (initial) navigation path
          initPath: [HomeSegment()],
          /// how to decode JSON to AppSegments
          json2Segment: (jsonMap, _) => AppSegments.fromJson(jsonMap),
          /// map TypedSegment's to Screens
          screenBuilder: appSegmentsScreenBuilder,
        );
```

### Common navigation actions



```dart
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
const booksLen = 5;
```

### 5. Map TypedSegment's to Screens

Only the *TypedSegment => Screen* mapping is displayed.. You can view all application widgets here: [screen.dart source code](/examples/doc/lib/src/lesson01/screens.dart)

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
It enriches [lesson01](/doc/lesson01.md) by:

- screens require some asynchronous actions (when creating, deactivating or merging)
- the splash screen appears before the HomeScreen is displayed

See [lesson02 documentation](/doc/lesson02.md)

### Lesson03
It enriches  [lesson02](/doc/lesson02.md)  by:

- login application logic (where some pages are not available without a logged in user)
- more TypedPath roots (AppSegments and LoginSegments)
- navigation state also depends on another provider (userIsLoggedProvider)

See [lesson03 documentation](/doc/lesson03.md)

### Lesson04
It modified [lesson03](/doc/lesson03.md) by:

- introduction of the route concept

See [lesson04 documentation](/doc/lesson04.md)

### Lesson05
Test for [lesson03](/doc/lesson03.md)

See [lesson05 documentation](/doc/lesson05.md)
