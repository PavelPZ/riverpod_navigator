# Navigation state management using the riverpod

### riverpod_navigator_core is a dart package that solves the following:

- **Strictly typed navigation:** <br>
You can use ```navigate([HomeSegment(),BookSegment(id: 2)]);``` instead of ```navigate('home/book;id:2');``` in your code.
- **asynchronous navigation**<br>
is the case when changing the navigation state requires asynchronous actions (such as loading or saving data from the Internet)
- **multiple providers**<br>
is the case when the navigation state depends on multipple providers (as a isLoggedProvider)

### Terminology used

Take a look at the following terms related to url path ```home/book;id=2```

- **string-path:** ```final stringPath = 'home/book;id=2';```
- **string-segment** - the string-path consists of two slash-delimited string-segments: ```home``` and ```book;id=2`
- **typed-segment** - the typed-segment (aka ```class TypedSegment {}``` ) defines string-segment: ```HomeSegment()``` and ```BookSegment(id:2)``` in this case
- **typed-path**: typed-path (aka ```typedef TypedPath = List<TypedSegment>```) : ```[HomeSegment(), BookSegment(id:2)];```
- Flutter Navigator 2.0 **navigation-stack** is specified by TypedPath, where each TypedPath's TypedSegment instance corresponds to a flutter screen and page instance<br>
  ```[MaterialPage (child: HomeScreen(HomeSegment())), MaterialPage (child: BookScreen(BookSegment(id:2)))]```.

### Riverpod Data Flow Diagram:

<p align="center">
<img src="https://github.com/PavelPZ/riverpod_navigator/blob/main/packages/riverpod_navigator_core/README.png" alt="riverpod_navigator_core" />
</p>

As you can see, changing the **Input state** starts the async calculation.
The result of the calculations is **Output state** in navigationStackProvider and possibly app specific **Side effects**.

#### Where is the Flutter?

**What's going on?** So far, we can read terms like *"Dart (not flutter) package"*, *"asynchronous navigation"*, *"navigation state"*, *"navigationStackProvider"*, ... but where is the Flutter and its Navigator 2.0?

The beauty of *riverpod* is that it doesn't depend on Flutter. This allows most app logic to be developed and tested without typing a single widget.
It's the same in this case. 
The missing *navigationStackProvider* connection to Flutter Navigator 2.0 to *RouterDelegate* for development and testing purposes is not relevant now.

## Example

Take a look at a simple [DartPad example](https://dartpad.dev/?id=970ba56347a19d86ccafeb551b013fd3).
It shows the following ideas:

- how to connect *navigationStackProvider* to *RouterDelegate*
- what is *navigation-stack*: array of screens where the last of them is visible (and others are available via the Back button)
- what is the meaning of *typed-segment* aka **TypedSegment** class, *typed-path* aka **List<TypedPath>** and how to use them for navigation: <br>
```ref.read(ongoingPathProvider.notifier).state = [HomeSegment(), BookSegment(id: 2)];```
- how easy *navigationStackProvider* connects to RouterDelegate to become **"the source of the truth"** for the navigations stack.

The example may look like a solution to Flutter Navigation 2.0 using the riverpod package.
However, it does not meet the **async navigation** condition.
What problems does async-navigation bring? 
We'll read this later.

## The idea of dart developing and testing ...

... is shown in this pseudocode example:

```dart
import 'package:test/test.dart'; // no package:flutter_test/flutter_test.dart package is needed
...

void main() {
  test('test', () async {
    final container = ProviderContainer()
      // change Input-state
      container.read(ongoingPathProvider.notifier).state = [HomeSegment(), BookSegment(id:2)];
      await container.pump();
      // wait for "Async app logic" to finish. 
      // debug guards, redirects, async data loading and saving etc.
      await ... 
      // check Output-state
      final navigationStack = container.read(navigationStackProvider);
      final url = RouteInformationParserImpl.debugTypedPath2Path(navigationStack);
      expect(url,'{"runtimeType":"home"}/{"id":2,"runtimeType":"book"}');
  });
}
```

Is the pseudocode clear? 
It shows nothing but the [Let's see how Riverpod helps you with testing](https://riverpod.dev/docs/cookbooks/testing).

## Problems with async
