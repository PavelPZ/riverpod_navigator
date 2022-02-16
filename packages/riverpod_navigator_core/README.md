# State management for Flutter Navigator 2.0 using the riverpod

... s podporou asynchronní a cancelable navigation

## Příklad

Problémy, které riverpod_navigator_core řeší, si představme na příkladě.

Na home-screen je link-button s odkazem na book-screen, kde book-screen je dostupná pouze po zalogování.

V riverpod světě se realizace kliku na link-button provede pomocí změny stavu riverpod provideru. 
Tento provider nazýváme **ongiongPathProvider**. 
Ongoing proto, že jeho stav určuje kam chci navigovat ale nikoliv to, kam se ve skutečnosti naviguje.

Skutečná navigace totiž ještě závisí na jiném provideru, který nazýváme **isLoggedProvider** (typu StateProvider<bool>).
Jeho stav obsahuje informaci zdali je uživatel zalogován. 
Když zalogován není (```ref.read(isLoggedProvider) == false```), tak místo na book-screen se skočí na login-screen.

Výsledný stav kliku na link button se tedy spočte ze stavu dvou providerů (ongiongPathProvider a isLoggedProvider) 
a uloží se do dalšího provideru (like riverpod usually do), který nazývýme **navigationStackProvider**.

Note: **Side effects**
*Zobrazení book screen může vyžadovat asynchronní stažení dat. A tato data mohou být třeba cachována.
Neboli zobrazení book screen může přinést vedlejší efekty, ovlivňující stav aplikace*.

#### Schéma

Úlohu riverpod_navigator_core v tomto provesu je pak možná znázornit následujícím schématem:

<p align="center">
<img src="https://github.com/PavelPZ/riverpod_navigator/blob/main/packages/riverpod_navigator_core/README.png" alt="riverpod_navigator_core" />
</p>

## Challenges to address

1. asynchronní navigace
v reálnám světě přechod z jednoho screen obsahuje asynchronní akce, jakými jsou například:
- uschování výsledků ze starého screenu do vzdáleného úložiště
- stažení dat z internetu, potřebných k zobrazení nového screenu

2. cancelable navigation
s příchodem Flutter for Web and Flutter for Desktop se zvyšuje potřeba umožnit cancel právě probíhající asynchronní navigace.
Představme si, že uživatel ve vaší web aplikaci klikne 5x za sebou rychle na Back browser button. 
Intervaly mezi kliky mohou být pod 200 msec.
A v browser historii jsou stránky, vyžadující asynchronní akce.
Je pak velice pravděpodobné, že se některý klik právě probíhající asynchronní akce přeruší.
Toto může způsobit problémy jak udržet *side effects states* zmíněné výše v konsistentním stavu.

Vhodným přístupem je možné těmto problémům zabránit.

## Typed navigation mission

Take a look at the following terms related to url path ```home/book;id=2```

- **string-path:** ```final stringPath = 'home/book;id=2';```
- **string-segment** - the string-path consists of two string-segments: 'home'and 'book;id=2'
- **typed-segment** - the typed-segment is immutable class that defines string-segment: HomeSegment() and BookSegment(id:2)
- **typed-path**: typed-path can be understood as List<typed-segment>: ```final typedPath = [HomeSegment(), BooksSegment(), BookSegment(id:2)];```
- **navigation-stack** of Flutter Navigator 2.0 is a stack of screens, parameterized by typed-segment:
  ```[HomeScreen(HomeSegment())), BookScreen(BookSegment(id:2))]```

The mission of the navigation is to keep *string-path* <= **typed-path** => *navigation-stack* always in sync.
With the **typed-path** as the source of the truth.

## Kde je Flutter Navigator 2.0?

Máme tedy navigationStackProvider, typed-segment, typed-path, asynchronní a cancelable navigaci ... ale kde je Flutter a jeho Navigator 2.0?

Napojení všech těchto mechanismů na Navigator 2.0 již není problém, jak je ukázáno v dartPad na příkladě: https://dartpad.dev/?id=970ba56347a19d86ccafeb551b013fd3.

Tento jednoduchý příklad, který Works for Flutter mobile and Flutter for web and desktop, obsahuje vše potřebné:
- typed navigation (```TypedSegmenbt, TypedPath, HomeSegment, BookSegment```)
- ```navigationStackProvider```
- screens (```HomeScreen(HomeSegment()), BookScreen(BookSegment(id:x))```)
- Flutter Navigator 2.0 RouterDelegate
- string-path <==> typed-path pro Flutter for web

