# Navigator for Riverpod

### Simple but powerfull navigation library (based on Flutter Navigator 2.0, [Riverpod](https://riverpod.dev/), and [Freezed](https://github.com/rrousselGit/freezed)) that solves the following problems:

- **Strictly typed navigation:** <br>You can use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId');``` in your code.
- **Easier coding:** <br>The problem of navigation is reduced to manipulation of the immutable collection.
- **Better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
  Navigation logic can be developed and tested without typing a single flutter widget.
- **Asynchronous navigation:**<br>
  Prepare all necessary asynchronous operations before the navigation starts, e.g.
  - save data from the previous screen
  - data loading for the new screen
- **External providers dependency:**<br>
  Navigation status may also depend on external providers, e.g.
  - the status of the user's login
  - subscription status for electronic books
- **Ability to configure many navigation parameters**, e.g.
  - Page builder
  - Navigator builder
  - Splash screen

## The mission

- **string path:** ```stringPath = 'home/books/book;id=2';```
- **string segment** (the string path consists of three string segments, delimited by slash): 'home', 'books', 'book;id=2'
- **typed path**: ```typedPath = <TypedSegment>[HomeSegment(), BooksSegment(), BookSegment(id:2)];```
- **typed segment** (the typed path consists of three instances of [TypedSegment]'s): [HomeSegment], [BooksSegment], [BookSegment]
- **navigation stack** of Flutter Navigator 2.0: ```HomeScreen(HomeSegment())) => BooksScreen(BooksSegment()) => BookScreen(BookSegment(id:3))```

The mission of navigation is to keep **string path** <=> **typed path** <=> **navigation stack** always in a synchronous state.

