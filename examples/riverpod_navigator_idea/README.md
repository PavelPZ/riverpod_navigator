# Riverpod, freezed and Navigator 2.0

... how to use [riverpod](https://riverpod.dev/) and [freezed](https://github.com/rrousselGit/freezed) 
to simplify Flutter [Navigator 2.0](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade) usage.

-----------------

This is an example of the classic ```Home => Books => Book*``` navigation app. 

### It solves the following navigation problems:

- **Strictly typed navigation:** <br>in your code use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId';)```.
- **Easier coding:** <br>Problem of the navigation is reduced to immutable collection manipulation.
- **Better separation of concerns: UI x Model** (riverpod offers this feature too): <br>
  Whole app state management (including navigation) can be developed and tested in Dart environment. Without typing a single flutter widget. 
  For example test see [example_test.dart](test/example_test.dart).
- **Small codebase:** <br>This example consists of only 150 lines of the generic code (which can be used in other app) and 150 lines of the app-specific code.

## Source code

The best documentation is a simple source code.

The source code is contained in five files.
To better understand it, see the following matrix:

| | dart | flutter |
|---|---|--- |
| **generic** | [riverpod_navigator_dart.dart](lib/src/riverpod_navigator_dart.dart) | [riverpod_navigator.dart](lib/src/riverpod_navigator.dart) |
| **app-specific** | [appDart.dart](lib/src/appDart/appDart.dart) | [appFlutter.dart](lib/src/appFlutter/appFlutter.dart)  |

Testing without flutter (dart only) is available in [example_test.dart](test/example_test.dart).

<sub>**Note:** In app-specific code I am using [functional_widget](https://github.com/rrousselGit/functional_widget) and [flutter_hooks](https://github.com/rrousselGit/flutter_hooks) to be less verbose.</sub>

## Installing the example

After clonning repository, go to ```examples\riverpod_navigator_idea``` subdirectory and execute:

- ```flutter create .```
- ```flutter pub get```
- ```flutter pub run build_runner watch --delete-conflicting-outputs```
- ```flutter create .```

## Next steps

Feel free to create issue with your ideas. 
