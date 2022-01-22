# riverpod_navigator_about

Strictly typed flutter Navigation 2.0 driven by riverpod state

-----------------

I will try to explain the idea with the classic simple example of Home=>Books=>Book applicaton.

## What does mean "Strictly typed"

### url path 
```'home/books/book;id-3'```

### url segments (as string)
```'home', 'books', 'book;id-3'```

### typed url segments (as TypedSegment descendants)
```dart
abstract class TypedSegment {}

class HomeSegment extends TypedSegment {} 

class BooksSegment extends TypedSegment {} 

class BookSegment extends TypedSegment {
    Book({required this.id}) { final int id; 
}
```

### typed url path (as list of TypedSegment)
```dart
typedef TypedPath = List<TypedSegment>;
final typedPath = <TypedSegment>[HomeSegment(), BooksSegment(), BookSegment(id: 3)];
```

### flutter navigation stack
```home page => books page => book #3 page```

## Books example

### Using "freezed" package for all TypedSegment's

```dart
@freezed
class ExampleSegments with _$ExampleSegments, TypedSegment {
  factory ExampleSegments.home() = HomeSegment;
  factory ExampleSegments.books() = BooksSegment;
  factory ExampleSegments.book({required int id}) = BookSegment;
}
```

### "ExampleRiverpodNavigator" for app navigation logic in 

```dart
class ExampleRiverpodNavigator extends RiverpodNavigator {
    void toHome() => navigate([HomeSegment]);
    void toHome() => navigate([HomeSegment]);
    void toHome() => navigate([HomeSegment]);
}

```
## Notifier, Provider, typedPathNotifierProvider and RiverpodNavigator


```dart
class TypedPathNotifier extends StateController<TypedPath> {
  TypedPathNotifier() : super([]);
  TypedPath get actualTypedPath => ref.read(typedPathNotifierProvider);
}

final typedPathNotifierProvider = 
    StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier());

final typedPathNotifierProvider = StateNotifierProvider<TypedPathNotifier, TypedPath>((_) => TypedPathNotifier();

class RiverpodNavigator {
    navigate(TypedPath newPath) {...} // <== all navigation magic here
    
    //--- helper methods ---
    TypedPath get actualTypedPath => ref.read(typedPathNotifierProvider);
    void push(TypedSegment segment) => navigate([...state, segment]);
    void pop(TypedSegment segment) => navigate([for (var i = 0; i < actualTypedPath.length - 1; i++) actualTypedPath[i]]);
}
```
