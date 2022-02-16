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
*tato stažená data mohou být třeba cachována v globální cache. Změna cache je tak vedlejší-efekt vzniklý zobrazením book-screen*.


#### Schéma

Úlohu riverpod_navigator v tomto procesu je pak možná znázornit následujícím schématem:

<p align="center">
<img src="https://github.com/PavelPZ/riverpod_navigator/blob/main/packages/riverpod_navigator_core/README.png" width="565" height="424" alt="riverpod_navigator_core" />
</p>

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

riverpod_navigator_core je dart library, without dependency on Flutter. 

Může tedy dojít k nedorozumnění. 
Máme nyní navigationStackProvider, typed-segment, typed-path, asynchronní a cancelable navigaci ... ale kde je Flutter a jeho Navigator 2.0?

Napojení všech těchto mechanismů na Navigator 2.0 již není problém, jak je ukázáno zde: [dartPad example](https://dartpad.dev/?id=970ba56347a19d86ccafeb551b013fd3).

Tento jednoduchý příklad, který works for Flutter mobile, Flutter for web and Flutter for desktop, obsahuje vše potřebné:

- typed navigation (```TypedSegment, TypedPath, HomeSegment, BookSegment```)
- ```navigationStackProvider```
- screens (```HomeScreen(HomeSegment()), BookScreen(BookSegment(id:x))```)
- Flutter Navigator 2.0 ```RouterDelegate```
- Flutter for web ```RouteInformationParser``` (web-url <==> TypedPath konverter)

## Testování




## Je vůbec asynchronní navigace potřeba?

Flutter Navigator 2.0 je ve své podstatě synchronní. 
Zavoláním RouterDelegate.notifyListeners okamžitě spustí vytvoření nové screen a transition staré screen v novou.

Stará screen může při své deaktivaci asynchronně ukládat výsledky do vzdáleného úložiště.
Nová screen se může ihned zobrazit v nedokončeném "waiting" stavu a po načtení potřebných dat se rebuildovat.

Tento přístup má svá úskalí:
- není moc hezký: po hezké transition jedné screen v druhou následuje další přechod mezi "waiting" a "dokončeným" stavem
- je nekorektní, např. pokud nová stránka potřebuje ještě neuložená data té staré
- bez obecného mechanismu asynchronní navigace se musí výše zmínené nekorektnosti řešit pro každý případ individuálně 

## Cancellation Token

Asynchronní akce při změně navigation stack ve spojení s rychlou změnou požadavků na nový navigation stack.




Rozšířením riverpod_navigator_core je [riverpod_navigator package](https://pub.dev/packages/riverpod_navigator). 
Obsahuje vše potřebné co usnadní použít výše zmíněné principy ve Flutter alikaci.



### Flutter for web: kompletní změna navigation stack

V mobilní aplikaci se uživatel k určitému navigation state postupně dostane pomocí ```push```'s resp. ```pop```'s.
Ve webovém světě si uložením a následným použitím url adresy vynutíme kompletní změnu navigation stack.

In other words, more "asynchronous" new screens can replace several "asynchronous" old screens.

