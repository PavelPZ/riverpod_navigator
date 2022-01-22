# Riverpod, freezed and Navigator 2.0

... how to use [riverpod](https://riverpod.dev/) and [freezed](https://github.com/rrousselGit/freezed) 
to simplify Flutter [Navigator 2.0](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade) usage.

-----------------

This is an example of the classic ```Home => Books => Book*``` navigation app. 

### It solves the following problems:

- **Strictly typed navigation:** <br>use ```navigate([Home(), Books(), Book(id: bookId)])``` instead of ```navigate('home/books/$bookId')```.
- **Easier coding:** <br>Problem of the navigation is reduced to immutable collection manipulation.
- **Better separation of concerns: UI x Model** (riverpod offers this feature too): <br>
  Whole app state management (including navigation) can be developed and tested in Dart environment. And without typing a single widget.
- **Clean codebase:** <br>This example consists of only 120 lines of the generic code (which can be used in other app) and 120 lines of the app specific code.

### What is not solved:

- better and nice URL parser for Flutter Web app (the url visible in a browser is really horrible - just Uri encoded/decoded JSON string)
- introduction of the "route" concept. Route can easy customize different navigation aspects
- async navigation for cases when the page needs some async action before first display/deactivation
- navigation for authentication, route guards etc.
- more TypedSegment-like classes in single app

Those problems will be solved by two packages (riverpod_navigator and riverpod_navigator_dart). Preview version of them will be published in a few days.

## Using example

After clonning repository, go to ```examples\riverpod_navigator_idea``` subdirectory and execute:

- ```flutter create .```
- ```flutter pub get```
- ```flutter pub run build_runner watch --delete-conflicting-outputs```
- ```flutter create .```

## Source code

The best documentation is a simple source code.

To better understand it, see the following matrix (regarding generic x app specific, dart code x flutter code):

| | dart | flutter |
|---|---|--- |
| **generic** | *lib/src/packageDart.dart* | *lib/src/packageFlutter.dart* |
| **app specific** | *lib/src/appDart/appDart.dart* | *lib/src/appFlutter/appFlutter.dart/*  |

Testing without flutter is available in *test/example_test.dart*

## Next steps

Feel free to create issue with your ideas. This project is intended as a platform for better understanding and using of Flutter Navigation 2.0.

And sorry for my english :-)