# State management for navigation using the riverpod

### Tiny dart library that solves the following problems:

... s podporou asynchronní navigation

## Příklad

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
<img src="https://github.com/PavelPZ/riverpod_navigator/blob/main/packages/riverpod_navigator_core/READMEx.png" width="565" height="424" alt="riverpod_navigator_core" />
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

