# riverpod_navigator_about

Strictly typed flutter Navigation 2.0 driven by riverpod state

-----------------

I will try to explain the idea with the classic simple example of Home=>Books=>Book applicaton.

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

final exampleRiverpodNavigator = Provider<ExampleRiverpodNavigator>((_) => ExampleRiverpodNavigator());

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
