# State management for Flutter Navigator 2.0 using the riverpod

... s podporou asynchronní a cancelable navigation

## Příklad

Problémy, které riverpod_navigator_core řeší, si představme na příkladě.

Na home-screen je link-button s odkazem na book-screen, kde book-screen je dostupná pouze po zalogování.

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
*tato stažená data mohou být třeba cachována v globální cache. Změna cache je tak vedlejší efekt zobrazení book-screen*.


#### Schéma

Úlohu riverpod_navigator v tomto procesu je pak možná znázornit následujícím schématem:

<p align="center">
<img src="https://github.com/PavelPZ/riverpod_navigator/blob/main/packages/riverpod_navigator_core/README.png" alt="riverpod_navigator_core" />
</p>

## Challenges to address

Podívejme se podrobněji, jaké výzvy z uvedeného příkladu plynou.

### 1. potřeba asynchronní navigace<br/>
v reálnám světě navigace z jednoho screen na druhý může potřebovat asynchronní akci, jakou je např:

    - starý screen ukládá výsledky do vzdáleného úložiště 
    - nový screen stahuje potřebná data z internetu

### 2. cancelable navigation

#### rychlá změna ongiongPathProvider stavu
S příchodem Flutter for Web and Flutter for Desktop se zvyšuje potřeba umožnit cancel právě probíhající asynchronní navigace.
Představme si, že uživatel ve vaší web aplikaci klikne 5x za sebou rychle na Back browser button. 
To může stihnout za méně než jednu vteřinu.
Intervaly mezi kliky tak mohou být pod 200 msec.
Je pak velice pravděpodobné, že některý klik právě probíhající asynchronní akci přeruší.
Toto může způsobit problémy jak udržet zmíněné výše *side effects states* v konsistentním stavu.

#### kompletní změna ongiongPathProvider stavu
Dalším důsledkem vývoje Flutter web aplikace je možná změna kompletního navigation stack. 
V mobilní aplikaci se uživatel k určitému navigation state postupně prokliká.
OngiongPathProvider tak udržuje postupně pomocí ```push``` resp. ```pop```. 
Ve webovém světě si uložením a následným použitím webové url adresy vynutíme kompletní změnu ongiongPathProvider stavu.

#### závěr


Vhodným přístupem je možné těmto problémům zabránit.

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

riverpod_navigator_core je dart library, without dependency on Flutter. 

Máme tedy nyní navigationStackProvider, typed-segment, typed-path, asynchronní a cancelable navigaci ... ale kde je Flutter a jeho Navigator 2.0?

Napojení všech těchto mechanismů na Navigator 2.0 již není problém, jak je ukázáno zde: [dartPad example](https://dartpad.dev/?id=970ba56347a19d86ccafeb551b013fd3).

Tento jednoduchý příklad, který works for Flutter mobile and Flutter for web and desktop, obsahuje vše potřebné:
- typed navigation (```TypedSegment, TypedPath, HomeSegment, BookSegment```)
- ```navigationStackProvider```
- screens (```HomeScreen(HomeSegment()), BookScreen(BookSegment(id:x))```)
- Flutter Navigator 2.0 ```RouterDelegate```
- Flutter for web ```RouteInformationParser``` (url string-path <==> typed-path)

Rozšířením riverpod_navigator_core je [riverpod_navigator package](https://pub.dev/packages/riverpod_navigator). 
Obsahuje vše potřebné co usnadní použít výše zmíněné principy ve Flutter alikaci.

## Cancellation Token

Můžete být štastný, když se vám podaří navrhnout vaší aplikaci tak, aby jste se důsledkům cancelable navigation vyhnuli.



