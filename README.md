# Navigator for Riverpod

### Simple but powerfull navigation library (based on Flutter Navigator 2.0, [Riverpod](https://riverpod.dev/), and [Freezed](https://github.com/rrousselGit/freezed)) that solves the following problems:

- **Strictly typed navigation:** <br>You can use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId');``` in your code.
- **Easier coding:** <br>The problem of navigation is reduced to manipulation an immutable collection.
- **Better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
  Navigation logic can be developed and tested without typing a single flutter widget.
- **Asynchronous navigation:**<br>
  Prepare all necessary asynchronous operations before the navigation starts, e.g.
  - save data from the previous screen
  - loading data for new screen
- **Dependence on external providers:**<br>
  The navigation state may also depend on external providers, e.g. user login status
- **Possibility to configure many navigation parameters**, e.g. Page builder, Navigator builder, Splash screen

## The mission

Let's look at the following concepts:

- **[string path]**, e.g ```stringPath = 'home/books/book;id=2';```
- **string segment** (the string path consists of three string segments), e.g. 'home', 'books', 'book;id=2'
- **[typed path]**, e.g. ```typedPath = <TypedSegment>[HomeSegment(), BooksSegment(), BookSegment(id:2)];```
- **typed segment**, e.g. HomeSegment(), BooksSegment(), BookSegment()
- **[navigation stack]** of Flutter Navigator 2.0. e.g. ```HomeScreen(HomeSegment())) => BooksScreen(BooksSegment()) => BookScreen(BookSegment(id:3))```

The mission of navigation is to keep 

> **[string path]** <=> **[typed path]** <=> **[navigation stack]** 

always in a synchronous state.

## Simple example


