# Navigation state management using the riverpod

### Dart (not flutter) package that solves the following:

- **asynchronous navigation**: changing the navigation state requires asynchronous actions, such as retrieving or saving data from the Internet
- the navigation state depends on **multiple providers** (as a isLoggedProvider)
- **Strictly typed navigation:** <br>You can use ```navigate([HomeSegment(),BookSegment(id: 2)]);``` instead of ```navigate('home/book;id:2');``` in your code.

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
The missing connection of navigationStackProvider to Flutter Navigator 2.0 to RouterDelegate is already easy.

## Typed navigation mission

Take a look at the following terms related to url path ```home/book;id=2```

- **string-path:** ```final stringPath = 'home/book;id=2';```
- **string-segment** - the string-path consists of two string-segments: 'home'and 'book;id=2'
- **typed-segment** - the typed-segment (aka ```TypedSegment``` class) is immutable class that defines string-segment: HomeSegment() and BookSegment(id:2) in this case
- **typed-path**: typed-path (aka ```TypedPath``` list)  can be understood as List<TypedSegment>: ```final typedPath = [HomeSegment(), BookSegment(id:2)];```
- **navigation-stack** of Flutter Navigator 2.0 is a stack of screens, parameterized by typed-segment:
  ```[HomeScreen(HomeSegment())), BookScreen(BookSegment(id:2))]```

The mission of the typed navigation is to keep *string-path* <= **typed-path** => *navigation-stack* always in sync.

With the **typed-path** as the source of the truth.

## Example

Take a look at a simple [DartPad example](https://dartpad.dev/?id=970ba56347a19d86ccafeb551b013fd3),
which shows the following ideas:

- how to connect *navigationStackProvider* to *RouterDelegate*
- what is *navigation-stack*: array of screens where the last of them is visible (and others are available via the Back button)
- what is the meaning of *typed-segment* aka **TypedSegment** class, *typed-path* aka **TypedPath** list and how to use them for navigation: <br>
```ref.read(navigationStackProvider.notifier).state = [HomeSegment(), BookSegment(id: 2)];```
- how easy *navigationStackProvider* connects to RouterDelegate to become **"the source of the truth"**

The example may look like a solution to Flutter Navigation 2.0 using the riverpod package.
However, it does not meet the **async navigation** condition.
What problems does async-navigation bring? Read on...

## The idea of flutter development and testing...

... is shown on the dart-test example pseudocode:

```dart
import 'package:test/test.dart'; // not package:flutter_test/flutter_test.dart
...

void main() {
  test('test', () async {
    final container = ProviderContainer()
      // change Input-state
      container.read(ongoingPathProvider.notifier).state = [HomeSegment(), BookSegment(id:2)];
      await container.pump();
      // wait for "Async app logic" to finish. 
      // Debug guards, redirects, async data loading and saving etc.
      await ... 
      // check Output-state
      final navigationStack = container.read(navigationStackProvider);
      final url = RouteInformationParserImpl.debugTypedPath2Path(navigationStack);
      expect(url,'{"runtimeType":"home"}/{"id":2,"runtimeType":"book"}')');
  });
}
```

Is the idea clear? 

To get further, we will explain the other terms so that we can show what ```StateProvider <TypedPath>``` means in the test example.



## Problems with async



1. It is likely that the asynchronous actions of the new navigation stack will overlap with the old one.

Představme si aplikaci s mnoha různými screens. Tyto screens asynchronně ukládají nebo načítají data z externí storage.




Edge use cases?



- When closing, the screen asynchronously stores its data to the external storage.
In the middle of this unfinished async closing, the Android user performs the Android Back button to the page that needs the same data from the external storage.
- The user click the back button in the web browser 5 times very quickly. Therefore, the entire navigation stack is replaced 5 times.

The pages of each navigation stack may require an asynchronous action (such as saving or retrieving from external storage) when activating or deactivating it.
- Aktuální stránka obsahuje tlačítko save, kterým se spustí asynchronní úschova data do external storage.
Uprostřed této nedokončené async operace provede uživatel Android back button
- ...

If similar cases do not occur in your application, you may be fine.
Otherwise, you should pay attention to how to keep consistent not only the state of the navigation, but also its "side effects" (from the diagram above).



-----------------




Problémy, které riverpod_navigator_core řeší, si představme na příkladě.

Na home-screen je link-button s odkazem na book-screen. 
Book-screen je dostupná pouze po zalogování.

V riverpod světě se realizace kliku na link-button provede pomocí změny stavu riverpod provideru. 
Tento provider nazýváme **ongiongPathProvider**. 
Ongoing proto, že jeho stav určuje kam chci navigovat ale nikoliv to, kam se ve skutečnosti naviguje.

Skutečná navigace totiž ještě závisí na jiném provideru, který nazýváme **isLoggedProvider**.
Jeho stav obsahuje informaci zdali je uživatel zalogován. 
Když zalogován není (```ref.read(isLoggedProvider) == false```), tak místo na book-screen se skočí na login-screen.

Výsledný stav kliku na link-button se tedy spočte ze stavu dvou providerů (ongiongPathProvider a isLoggedProvider) 
a uloží se do dalšího provideru (like riverpod usually do), který nazývýme **navigationStackProvider**.

Note: 
- *book-screen může ke svému zobrazení potřebovat asynchronní akce (např. stažení dat z internetu)*
- **Side effects**
*tato stažená data mohou být třeba cachována v globální cache. Změna cache je tak vedlejší-efekt vzniklý zobrazením book-screen*.


#### Schéma

Úlohu riverpod_navigator v tomto procesu je pak možná znázornit následujícím schématem:

<p align="center">
<img src="https://github.com/PavelPZ/riverpod_navigator/blob/main/packages/riverpod_navigator_core/README.png" alt="riverpod_navigator_core" />
</p>

Neboli se stará o to, aby na základě vstupních provider states (ongiongPathProvider, isLoggedProvider, ...) korektně vytvořil výstupní provider state (navigationStackProvider).

## Challenges to address

Podívejme se podrobněji, jaké výzvy z uvedeného příkladu plynou.

### potřeba asynchronní navigace<br/>
v reálnám světě navigace z jednoho screen na druhý může potřebovat asynchronní akci, např:

- starý screen ukládá data do vzdáleného úložiště
- nový screen stahuje potřebná data ze vzdáleného úložiště

### potřeba koordinovat asynchronní akce

It is likely that the asynchronous actions of the new navigation stack will overlap with the old one.
Například při rychlé změně požadavků na nový navigation stack opakovaným klikem na back-browser-button webového prohlížeče.
Toto může být problém při udržení *side-effects-states* v konsistentním stavu.

Asynchronní akce je tedy potřeba koordinovat.

### riverpod_navigator_core řešení

Riverpod_navigator_core:
- povolí přechod na nový navigation state čeká, až předchozí navigační state ukončí všechny asynchronní akce. Zabrání se tak jejich překrývání.
- čekající přechod na nový navigační stav může být pouze jeden. Pokud se objeví další, ten předchozí se zapomene.<br>
Toto může nastat například při rychlém klikání na back-browser-button webového prohlížeče.

## Typed navigation mission

Take a look at the following terms related to url path ```home/book;id=2```

- **string-path:** ```final stringPath = 'home/book;id=2';```
- **string-segment** - the string-path consists of two string-segments: 'home'and 'book;id=2'
- **typed-segment** - the typed-segment is immutable class that defines string-segment: HomeSegment() and BookSegment(id:2) in this case
- **typed-path**: typed-path can be understood as List<typed-segment>: ```final typedPath = [HomeSegment(), BookSegment(id:2)];```
- **navigation-stack** of Flutter Navigator 2.0 is a stack of screens, parameterized by typed-segment:
  ```[HomeScreen(HomeSegment())), BookScreen(BookSegment(id:2))]```

The mission of the navigation is to keep *string-path* <= **typed-path** => *navigation-stack* always in sync.
With the **typed-path** as the source of the truth.

## Kde je Flutter Navigator 2.0?

Máme nyní navigationStackProvider, typed-segment, typed-path, asynchronní a cancelable navigaci ... ale kde je Flutter a jeho Navigator 2.0? 
Riverpod_navigator_core je dart library, without dependency on Flutter. K vlastně slouží?

Jsou dvě použití:

1. Máme na základě vstupních provider states (ongiongPathProvider, isLoggedProvider, ...) korektní výstupní provider state (navigationStackProvider).
Napojení navigationStackProvider na Navigator 2.0 již není problém, jak je ukázáno zde: [dartPad example](https://dartpad.dev/?id=970ba56347a19d86ccafeb551b013fd3).

Tento jednoduchý příklad, který works for Flutter mobile, Flutter for web and Flutter for desktop, obsahuje vše další:

- typed navigation (```TypedSegment, TypedPath, HomeSegment, BookSegment```)
- ```navigationStackProvider```
- screens (```HomeScreen(HomeSegment()), BookScreen(BookSegment(id:x))```)
- Flutter Navigator 2.0 ```RouterDelegate```
- Flutter for web ```RouteInformationParser``` (web-url <==> TypedPath konverter)

2. Rozšířením riverpod_navigator_core je [riverpod_navigator package](https://pub.dev/packages/riverpod_navigator). 
Obsahuje vše co usnadní použít výše zmíněné principy ve Flutter alikaci.

## Testování


## What the package does not address

- connection to Flutter Navigator 2.0, specifically the dependency of RouterDelegate on navigationStackProvider

