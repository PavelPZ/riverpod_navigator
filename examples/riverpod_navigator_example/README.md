# Riverpod, freezed and Navigator 2.0 example

... how to use [riverpod](https://riverpod.dev/) and [freezed](https://github.com/rrousselGit/freezed) 
to simplify the use of Flutter [Navigator 2.0](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade).

Classic three-screen example [Home] => [Books] => [Book\*].

The example implements a simple login logic: ```Book screen, id=1``` and ```Book screen, id=3``` screens are not available without login.

**Strictly typed navigation** is used. You can use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId');``` in your code.

> ## News

> I successfully used the idea from the example in my new project. 
It seems to me that it could be useful to others. 
So I prepared a [riverpod_navigator package](https://pub.dev/packages/riverpod_navigator).

## The mission

Take a look at the following terms:

- **string path:** ```stringPath = 'home/books/book;id=2';```
- **string segment** - the string path consists of three string segments: 'home', 'books', 'book;id=2'
- **typed path**: ```typedPath = <TypedSegment>[HomeSegment(), BooksSegment(), BookSegment(id:2)];```
- **typed segment** - the typed path consists of three instances of [TypedSegment]'s: [HomeSegment], [BooksSegment], [BookSegment]
- **navigation stack** of Flutter Navigator 2.0: ```HomeScreen(HomeSegment())) => BooksScreen(BooksSegment()) => BookScreen(BookSegment(id:3))```

The mission of navigation is to keep *string path* <= **typed path** => *navigation stack* always in sync.
With **typed path** as the source of the truth.

## Running example on the web...

... is available [here](https://pavelpz.github.io/).

## To run the example on your computer

- clone the repository
- in ```examples\riverpod_navigator_example\``` subdirectory, execute following commands:
- ```flutter create .```
- ```flutter pub get```
- ```flutter pub run build_runner build --delete-conflicting-outputs```
- ```flutter run``` 

## Publish to the web

- run ```flutter build web --web-renderer html```
- copy the contents of the ```build/web/``` directory to the root directory of your web server
