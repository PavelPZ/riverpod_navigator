# Riverpod, freezed and Navigator 2.0

... how to use [riverpod](https://riverpod.dev/) and [freezed](https://github.com/rrousselGit/freezed) 
to simplify Flutter [Navigator 2.0](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade) usage.

*For a better understanding, everything is explained on the classic 3-screens example: [Home] => [Book] => [Books*]*

-----------------

### Navigations example (based on Flutter Navigator 2.0) that solves the following navigation problems:

- **Strictly typed navigation:** <br>You can use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId');``` in your code.
- **Easier coding:** <br>The problem of navigation is reduced to manipulation of the immutable collection.
- **Better separation of concerns: UI x Model** (riverpod offers this feature too): <br>
  All app state management (including navigation) can be developed and tested in the Dart environment, without typing a single flutter widget. 
  Example of the navigation test see: [example_test.dart](test/example_test.dart).
- **Small codebase:** <br>This example contains only 150 lines of generic code (which can be used in another application) and 150 lines of application-specific code.

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
