# Navigator for Riverpod

### Simple but powerfull navigation library (based on Flutter Navigator 2.0, [Riverpod](https://riverpod.dev/), and [Freezed](https://github.com/rrousselGit/freezed)) that solves the following problems:

- **Strictly typed navigation:** <br>You can use ```navigate([Home(), Books(), Book(id: bookId)]);``` instead of ```navigate('home/books/$bookId');``` in your code.
- **Easier coding:** <br>The problem of navigation is reduced to manipulation of the immutable collection.
- **Better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
  Navigation logic can be developed and tested in the Dart environment, without typing a single flutter widget.
- **Small codebase with a lot of extensions:**<br>
  The core engine consists of two small .dart files ([riverpod_navigator.dart](packages/riverpod_navigator/lib/src/riverpod_navigator.dart) 
  and [riverpod_navigator_dart.dart](packages/riverpod_navigator_dart/lib/src/riverpod_navigator_dart.dart)).
  Additional features (such as better URL parser, asynchronous navigation, possibility to use routes etc.) are included (and can be created) as configurable extensions.

## Two packages

The "Riverpod navigator" consists of two packages, similar to a "riverpod". The following table explains its similarity:

| Dart only development and testing | Flutter development and testing |
| --- | --- |
| riverpod | flutter_riverpod *or* hooks_riverpod |
| riverpod_navigator_dart | riverpod_navigator |

## Explanation on examples

*For a better understanding, everything is explained on the classic example:<br>
[Home] => [Books] => [Book\*]*

Annotated examples [can be found here](explanation_on_examples.md)

### Install and run examples

After clonning repository, go to ```examples/doc/``` subdirectory and execute:

- ```flutter create .```
- ```flutter pub get```
- ```flutter pub run build_runner --delete-conflicting-outputs```
- in [lib/main.dart)](examples/doc/lib/main.dart), uncomment the line with example you want to execute.
- execute ```flutter run```

