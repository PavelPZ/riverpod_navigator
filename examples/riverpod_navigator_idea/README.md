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

## Using example

After clonning repository, in ```examples\riverpod_navigator_idea``` subdirectory execute:

- ```flutter create .```
- ```flutter pub get```
- ```flutter pub run build_runner watch --delete-conflicting-outputs```
- ```flutter create .```

## Documentation

See the example code. 

Generic x app vs. dart x flutter code yelds in this source code matrix:

| | dart | flutter |
|---|---|--- |
| **generic** | *lib/src/packageDart.dart* | *lib/src/packageFlutter.dart* |
| **app specific** | *lib/src/appDart/appDart.dart* | *lib/src/appFlutter/appFlutter.dart/*  |

Testing without flutter is in *test/example_test.dart*

## Next steps

Feel free to create issue with your ideas. The project is intended as a platform for better understanding and use of Flutter Navigation 2.0.

And sorry for my english :-)