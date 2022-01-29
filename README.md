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

## Classic navigation vs. Strictly typed navigation

With a great deal of simplification and abstraction, we can imagine the whole complex flutter navigation as follows:

1. what we see in the flutter application is the top page in the NavigationStack.
2. app has some app specific inner NavigationState
3. changing this NavigationState will also change NavigationStack

NavigationStack can be understood as a collection of [here](https://api.flutter.dev/flutter/widgets/Page-class.html) widgets.

There are several cases when the NavigationState changes
1. the first page appears when the application starts
2. for Flutter for Web: url in browser is changed
3. in the android application: back action is called
4. navigation to another screen is called in the application code using something like a ```navigate (newAppNavigationState)``` function.

Flutter Navigator 2.0 provide solutions and connections of navigation to the surrounding Flutter system my means of **RouterDelegate** and **RouteInformationParser**. 
However, they require the app to provide the following functions:

```dart
NavigationState stringUrl2NavigationState (String url);
String navigationState2StringUrl (NavigationState navigationState);
NavigationStack navigationState2NavigationStack (NavigationState navigationState);
/// called when e.g. back Android button is presses:
NavigationState changeNavigationStateOnPopPage (NavigationState navigationState);
/// navigation in the application code to a new page
void navigate(NavigationState newNavigationState);
```




Riverpod_navigator

```dart
class BookRoutePath {
  final int? id;
  BookRoutePath.home() : id = null;
  BookRoutePath.details(this.id);
  bool get isHomePage => id == null;
  bool get isDetailsPage => id != null;
}
```

```dart
List<Page> flutterNavigation(String stringUrl);
```


### Classic navigation

With a great deal of simplification and abstraction, we can imagine the whole complex flutter navigation as a function:

```dart
List<Page> flutterNavigation(String stringUrl);
```

where Page is defined [here](https://api.flutter.dev/flutter/widgets/Page-class.html);

### Strictly typed navigation

In **riverpod_navigator**, navigation is understood as two functions:

```dart
List<Page> flutterNavigation(TypedPath typedUrl );
String flutterNavigation(TypedPath typedUrl);
TypedPath flutterNavigation(TypedPath typedUrl);
```


## Explanation on examples

*For a better understanding, everything is explained on the classic example:<br>
[Home] => [Books] => [Book\*]*

Annotated examples [can be found here](/examples.md).




...
class RiverpodRouterDelegate extends RouterDelegate ... {
  @override
  Widget build(BuildContext context) => Navigator(pages: flutterNavigation(currentConfiguration));
  ...
}
...
navigate('home/books/1') => 

