# riverpod_navigator_ideas

Demonstration of ideas on how to use [riverpod](https://riverpod.dev/) and [freezed](https://github.com/rrousselGit/freezed) 
to simplify the use of Flutter [Navigator 2.0](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade).

-----------------

This example of classic ```Home => Books => Book*``` app solves the following problems:

- **Strictly typed navigation:** use ```dart navigate([Home(), Books(), Book(id: bookId)])``` instead of ```dart navigate('home/books/$bookId')```.
- **Easier coding:** Problem of the navigation is reduced to manipulating a immutable collection.
- **Better separation of concerns: UI x Model** (riverpod offers this feature too): 
  Whole app state management (including navigation) can be tested in Dart environment only without typing a single line of widget code.
- **Clean codebase:** This example consists of only 118 lines of generic code (which can be used in other app) and 120 lines of app specific code. 

What is not solved:

- better and nice URL parser for Flutter Web app (parser in this example is really horrible - just Uri-encode x -decode JSON string)
- introduction of the "route" concept. Route can easy customize different navigation aspects
- async navigation (for cases when page needs some async action during activating x deactivating)
- navigation for authentication, route guards etc.

Those problems will be solved by two packages (riverpod_navigator and riverpod_navigator_dart). Preview version of them will be published in a few days.


Generic x app vs. dart x flutter code yelds in this source code matrix:


| | dart | flutter |
|---|---|--- |
| **generic** | packageDart.dart | packageFlutter.dart |
| **app specific** | appDart/ | appFlutter/  |


## Using example

After clonning repository, in ```examples\riverpod_navigator_idea``` directory execute:

- ```flutter create .```
- ```flutter pub get```
- ```flutter pub run build_runner watch --delete-conflicting-outputs```

## What does mean "Strictly typed"

### url path 
```'home/books/book;id-3'```

### url segments (as string)
```'home', 'books', 'book;id-3'```

### typed url segments definition
```dart
class HomeSegment {} 

class BooksSegment {} 

class BookSegment { 
    Book({required this.id}) { final int id; } 
}
```

### typed url path
```dart
final typedPath = [HomeSegment(), BooksSegment(), BookSegment(id: 3)];
```

### using typed url path
instead of 

```dart
navigate('home/books/book;id-3')
``` 

we can use 

```dart
navigate([HomeSegment(), BooksSegment(), BookSegment(id: 3)])
```

## Books example, dart part (with no dependency on Flutter)

### Use "freezed" package for all typed segments:


```dart
@freezed
class ExampleSegments with _$ExampleSegments, TypedSegment {
  factory ExampleSegments.home() = HomeSegment;
  factory ExampleSegments.books() = BooksSegment;
  factory ExampleSegments.book({required int id}) = BookSegment;
}
```

### Use RiverpodNavigator for app navigation logic:

All magic is contained in ```RiverpodNavigator.navigate``` method (explanation see bellow).

```dart
class ExampleRiverpodNavigator extends RiverpodNavigator {
    // ...
    void toHome() => navigate([HomeSegment()]);
    void toBooks() => navigate([HomeSegment(), BooksSegment()]);
    void toBook({required int id}) 
      => navigate([HomeSegment(), BooksSegment(), BookSegment(id:id)]);
    // .... other app navigation-aware actions
}

### Provide "ExampleRiverpodNavigator" to whole app

final exampleRiverpodNavigatorProvider = Provider<ExampleRiverpodNavigator>((_) => ExampleRiverpodNavigator());

```
### Testing app navigation with no dependency on Flutter
```
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
//... import dart part of example

void main() {
    test('example test', () async {
        final container = ProviderContainer();
        final navigator = container.read(exampleRiverpodNavigator);

        navigator.toBook(id:3); 
        await container.pump();
        //... inspect actual typed path by "navigator.actualTypedPath"
        
        navigator.toBooks(); await container.pump(); //...
        navigator.toHome(); await container.pump(); //...
        navigator.pop(); await container.pump(); //...
        navigator.push(BookSegment(id:2)); await container.pump(); //...

    });
}

```

## Books example, flutter part

All magic is contained in ```RiverpodRouterDelegate extends RouterDelegate``` and ```RouteInformationParserImpl```, explanation see bellow.

```dart
class AppRoot extends ConsumerWidget {
  //...
    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final navigator = ref.read(appNavigatorProvider);
        final delegate = RiverpodRouterDelegate(navigator, initPath: [HomeSegment()]);
        ref.listen(typedPathNotifierProvider, (_, __) => delegate.notifyListeners());
        return MaterialApp.router(
            title: 'Books App',
            routerDelegate: delegate,
            routeInformationParser: RouteInformationParserImpl(),
        );
    }
}

void main() {
  runApp(ProviderScope(child: AppRoot());
}

```

## How "RiverpodNavigator", "RiverpodRouterDelegate" and "RouteInformationParserImpl" works

### Dart part with no dependency on Flutter

```dart
class TypedPathNotifier extends StateController<TypedPath> {
  TypedPathNotifier() : super([]);
  TypedPath get actualTypedPath => ref.read(typedPathNotifierProvider);
}

final typedPathNotifierProvider = 
    StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier());

final typedPathNotifierProvider = StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier();

class RiverpodNavigator {
    RiverpodNavigator(this.ref);
    final Ref ref;

    navigate(TypedPath newPath) => ref.read(typedPathNotifierProvider.notifier).state = newPath);
    
    //--- helper methods ---
    TypedPath get actualTypedPath => ref.read(typedPathNotifierProvider);
    void push(TypedSegment segment) => navigate([...state, segment]);
    void pop() 
      => navigate([for (var i = 0; i < actualTypedPath.length - 1; i++) actualTypedPath[i]]);
}
```

### Flutter part
