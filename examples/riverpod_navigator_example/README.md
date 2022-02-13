# Riverpod, freezed and Navigator 2.0 example

... how to use [riverpod](https://riverpod.dev/) and [freezed](https://github.com/rrousselGit/freezed) 
to simplify the use of Flutter [Navigator 2.0](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade).

## The mission

Take a look at the following terms related to url path ```home/books/book;id=2```

- **string-path:** ```final stringPath = 'home/books/book;id=2';```
- **string-segment** - the string-path consists of three string-segments: 'home', 'books' and 'book;id=2'
- **typed-segment** - the typed-segment is immutable class that defines string-segment: HomeSegment(), BooksSegment() and BookSegment(id:2)
- **typed-path**: typed-path can be understood as List<typed-segment>: ```final typedPath = [HomeSegment(), BooksSegment(), BookSegment(id:2)];```
- **navigation-stack** of Flutter Navigator 2.0 is a stack of screens, parameterized by typed-segment:
  ```[HomeScreen(HomeSegment())), BooksScreen(BooksSegment()), BookScreen(BookSegment(id:2))]```

The mission of navigation is to keep *string-path* <= **typed-path** => *navigation-stack* always in sync.
With the **typed-path** as the source of the truth.

Note: *There is a one-to-one relationship between the given segment and the screen (HomeSegment - HomeScreen, BookSegment - BookScreen).
In the following text, I sometimes confuse the two terms.*

## Example

I have prepared classic three-screen example [Home] => [Books] => [Book\*]. 
The example implements a **simple login logic**, where some screens (```Book screen, id=1``` and ```Book screen, id=3```) are not available without login.

**Strictly typed navigation** is used there. You can use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId');``` in your code.

Here is a brief introduction to the idea of the example: [what's under the hood](https://github.com/PavelPZ/riverpod_navigator/blob/main/under_the_hood.md).

## Running example on the web...

... is available [here](https://pavelpz.github.io/).

## To run the example on your computer

- clone this repository
- in ```examples\riverpod_navigator_example\``` subdirectory, execute following commands:
- ```flutter create .```
- ```flutter pub get```
- ```flutter run``` 

## Publish to the web

- run ```flutter build web --web-renderer html```
- copy the contents of the ```build/web/``` directory to the root directory of your web server

> ## News

I successfully used the idea from the example in my new project. 
It seems to me that it could be useful to others. 

So I prepared a [riverpod_navigator package](https://pub.dev/packages/riverpod_navigator).

