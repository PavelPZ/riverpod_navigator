# Riverpod_Navigator

### Navigation library (based on Flutter Navigator 2.0) that solves the following problems:

- **Strictly typed navigation:** <br>You can use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId');``` in your code.
- **Easier coding:** <br>The problem of navigation is reduced to manipulation of the immutable collection.
- **Better separation of concerns: UI x Model** (riverpod offers this feature too): <br>
  All app state management (including navigation) can be developed and tested in the Dart environment, without typing a single flutter widget. 
  Example of the navigation test see: [example_test.dart](examples/books_dart/test/example_test.dart).
- **Small codebase and a lot of extensions:**<br>
  The core engine consists of two small .dart files ([riverpod_navigator.dart](packages/riverpod_navigator/lib/src/riverpod_navigator.dart) 
  and [riverpod_navigator_dart.dart](packages/riverpod_navigator_dart/lib/src/riverpod_navigator_dart.dart))
  Additional features (such as better URL parser, asynchronous navigation, possibility to use routes etc.) are included as configurable extensions.

## Explanation by example

*For a better understanding, everything is explained on the classic 3-screens example: [Home] => [Book] => [Books*]*



