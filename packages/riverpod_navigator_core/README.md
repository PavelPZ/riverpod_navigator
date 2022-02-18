# Navigation state management using riverpod ...

### ... that solves the following:

- **Strictly typed navigation:** <br>
You can use ```navigate([HomeSegment(),BookSegment(id: 2)]);``` instead of ```navigate('home/book;id:2');``` in your code.
- **asynchronous navigation**<br>
is the case when changing the navigation state requires asynchronous actions (such as loading or saving data from the Internet)
- **multiple providers**<br>
is the case when the navigation state depends on multiple providers
- **easier coding:** <br>
The problem of navigation is reduced to manipulation an immutable collection.
- **better separation of concerns: UI x Model** (thanks to [riverpod](https://riverpod.dev/) :+1:):<br>
navigation logic can be developed and tested without typing a single flutter widget.

## Terminology used

Take a look at the following terms related to url path ```home/book;id=2```

- **string-path:** ```final stringPath = 'home/book;id=2';```
- **string-segment** - the string-path consists of two slash-delimited string-segments: ```home``` and ```book;id=2```
- **typed-segment** - the typed-segment (aka ```class TypedSegment {}``` ) defines string-segment: ```HomeSegment()``` and ```BookSegment(id:2)``` in this case
- **typed-path**: typed-path (aka ```typedef TypedPath = List<TypedSegment>```) : ```[HomeSegment(), BookSegment(id:2)];```
- Flutter Navigator 2.0 **navigation-stack** is specified by TypedPath, where each TypedPath's TypedSegment instance corresponds to a screen and page instance<br>
  ```[MaterialPage (child: HomeScreen(HomeSegment())), MaterialPage (child: BookScreen(BookSegment(id:2)))]```.

## Riverpod Data Flow Diagram:

<p align="center">
<img src="https://github.com/PavelPZ/riverpod_navigator/blob/main/packages/riverpod_navigator_core/README.png" alt="riverpod_navigator_core" />
</p>

As you can see, changing the **Input state** starts the async calculation.
The result of the calculations is **Output state** in navigationStackProvider and possibly app specific **Side effects**.

#### Where is the Flutter?

What's going on? So far, we can read  *"dart package"*, *"asynchronous navigation"*, *"navigation state"*, *"navigationStackProvider"*, ... but where is the Flutter and its Navigator 2.0?

The beauty of *riverpod* is that it doesn't depend on Flutter. This allows most app logic to be developed and tested without typing a single widget.
It's the same in this case.



The missing *navigationStackProvider* connection to Flutter Navigator 2.0 to *RouterDelegate* is quite simple, 
as shown in the [DartPad example](https://dartpad.dev/?id=970ba56347a19d86ccafeb551b013fd3).

## Used in [riverpod_navigator package](https://github.com/PavelPZ/riverpod_navigator/tree/main/packages/riverpod_navigator)

This package is a dart library independent of Flutter.
"riverpod_navigator" is a slim flutter extensions of this package.

## Used in [riverpod_navigator package](https://github.com/PavelPZ/riverpod_navigator/tree/main/packages/riverpod_navigator)...

... is slim flutter extensions of this package

## Problems with async
