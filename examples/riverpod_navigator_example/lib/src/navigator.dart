import 'dart:async';
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

import 'routerDelegate.dart';

part 'navigator.freezed.dart';
part 'navigator.g.dart';

// The mission:
//
// Take a look at the following terms:
//
// - **string path:** ```stringPath = 'home/books/book;id=2';```
// - **string segment** - the string path consists of three string segments: 'home', 'books', 'book;id=2'
// - **typed path**: ```typedPath = <TypedSegment>[HomeSegment(), BooksSegment(), BookSegment(id:2)];```
// - **typed segment** - the typed path consists of three instances of [TypedSegment]'s: [HomeSegment], [BooksSegment], [BookSegment]
// - **navigation stack** of Flutter Navigator 2.0: ```HomeScreen(HomeSegment())) => BooksScreen(BooksSegment()) => BookScreen(BookSegment(id:3))```
//
// The mission of navigation is to keep *string path* <= **typed path** => *navigation stack* always in sync.
// And with **typed path** as the source of the truth.

// ********************************************
//  basic classes:  ExampleSegments and TypedPath
// ********************************************

/// From the following definition, [freezed package](https://github.com/rrousselGit/freezed) generates three typed segment classes:
/// HomeSegment, BooksSegment and BookSegment.
@freezed
class ExampleSegments with _$ExampleSegments {
  ExampleSegments._();
  factory ExampleSegments.home() = HomeSegment;
  factory ExampleSegments.books() = BooksSegment;
  factory ExampleSegments.book({required int id}) = BookSegment;

  factory ExampleSegments.fromJson(Map<String, dynamic> json) => _$ExampleSegmentsFromJson(json);

  @override
  String toString() => jsonEncode(toJson());
}

/// TypedPath = Typed url path, which consists of [TypedSegment]s
typedef TypedPath = List<ExampleSegments>;

// ********************************************
// providers
// ********************************************

/// RiverpodNavigator
final riverpodNavigatorProvider = Provider<AppNavigator>((ref) => AppNavigator(ref));

/// [ongoingPathProvider] TypedPath provider, source of truth for flutter navigation
///
/// Note: [ongoingPathProvider] may differ from [RouterDelegate.currentTypedPath] during navigation calculation.
final ongoingPathProvider = StateProvider<TypedPath>((_) => []);

/// the navigation state also depends on the following [userIsLoggedProvider]
final userIsLoggedProvider = StateProvider<bool>((_) => false);

// ********************************************
//   Defer2NextTick
// ********************************************

/// helper class that solves the problem where two providers (on which navigation depends) change in one tick, e.g.
/// ```
/// ref.read(userIsLoggedProvider.notifier).update((s) => !s) // login state changed
/// ref.read(ongoingTypedPath.notifier).state = [HomeSegment(), BooksSegment()]; // navigation path changed
/// ```
/// without the Defer2NextTick class, [RouterDelegate.notifyListeners] will be called twice in this case.
class Defer2NextTick {
  Completer? _completer;
  FutureOr<void> Function()? runOnNextTick;

  void onNavigationStateChanged() {
    if (_completer != null) return;
    _completer = Completer();
    scheduleMicrotask(() async {
      try {
        final value = runOnNextTick?.call();
        if (value is Future) await value;
        _completer?.complete();
      } catch (e, s) {
        _completer?.completeError(e, s);
      }
      _completer = null;
    });
  }

  Future<void> get future => _completer != null ? Future.value() : (_completer as Completer).future;
}

// ********************************************
//   RiverpodNavigatorLow
// ********************************************

/// Helper singleton class for manaing navigation state
class RiverpodNavigator {
  RiverpodNavigator(this.ref, {required List<AlwaysAliveProviderListenable> dependsOn}) : routerDelegate = RiverpodRouterDelegate() {
    routerDelegate.navigator = this;

    // _onNavigationStateChanged is called only once on the next tick
    defer2NextTick.runOnNextTick = _onNavigationStateChanged;

    // 1. Listen for [ongoingPathProvider, ...dependsOn] riverpod providers - call defer2NextTick.onNavigationStateChanged().
    // 2. Add RemoveListener's to _unlistens
    // 3. Use _unlistens in ref.onDispose
    for (final depend in dependsOn) _unlistens.add(ref.listen<dynamic>(depend, (previous, next) => defer2NextTick.onNavigationStateChanged()));
    // ignore: avoid_function_literals_in_foreach_calls
    ref.onDispose(() => _unlistens.forEach((f) => f()));
  }

  /// Enter application navigation logic here (redirection, login, etc.).
  /// It can be empty when no redirect or guard is required.
  void appNavigationLogic(Ref ref) {}

  /// Flutter Navigation 2.0 RouterDelegate
  RiverpodRouterDelegate routerDelegate;

  /// Note: [ongoingPathProvider] state may differ from [currentTypedPath] during navigation calculation.
  @nonVirtual
  TypedPath get currentTypedPath => routerDelegate.currentConfiguration;

  /// synchronize [ongoingPathProvider] with [RouterDelegate.currentConfiguration]
  void _onNavigationStateChanged() {
    appNavigationLogic(ref);
    routerDelegate.currentConfiguration = ref.read(ongoingPathProvider);
    routerDelegate.doNotifyListener();
  }

  /// Main [RiverpodNavigator] method. Provides navigation to the new [TypedPath].
  /// After changing [ongoingPathProvider] state, the navigation state is updated.
  @nonVirtual
  Future<void> navigate(TypedPath newPath) {
    ref.read(ongoingPathProvider.notifier).state = newPath;
    return defer2NextTick.future;
  }

  @protected
  Ref ref;

  final Defer2NextTick defer2NextTick = Defer2NextTick();

  /// for ref.onDispose
  final List<Function> _unlistens = [];

  /// for [Navigator.onPopRoute] in [RiverpodRouterDelegate.build]
  @nonVirtual
  void onPopRoute() => pop();

  // *** common navigation-agnostic app actions ***

  @nonVirtual
  void pop() {
    final actPath = currentTypedPath;
    if (actPath.length <= 1) return;
    navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
  }

  @nonVirtual
  void push(ExampleSegments segment) => navigate([...currentTypedPath, segment]);

  @nonVirtual
  void replaceLast(ExampleSegments segment) {
    final actPath = currentTypedPath;
    navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i], segment]);
  }
}

// ********************************************
//   AppNavigator
// ********************************************

/// navigator is available throw riverpodNavigatorProvider
///
/// Navigator state depends on [ongoingPathProvider] and [userIsLoggedProvider] providers
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref) : super(ref, dependsOn: [ongoingPathProvider, userIsLoggedProvider]);

  /// ... mark the segments that require login: book with odd id
  bool needsLogin(ExampleSegments segment) => segment is BookSegment && segment.id.isOdd;

  /// Avoid navigation to [BookSegment] with odd [BookSegment.id] (and instead redirects to [HomeSegment (), BooksSegment ()])
  /// when not logged in
  @override
  void appNavigationLogic(Ref ref) {
    final userIsLogged = ref.read(userIsLoggedProvider);
    final ongoingNotifier = ref.read(ongoingPathProvider.notifier);

    if (!userIsLogged && ongoingNotifier.state.any(needsLogin)) ongoingNotifier.state = [HomeSegment(), BooksSegment()];
  }

  void toHome() => navigate([HomeSegment()]);
  void toBooks() => navigate([HomeSegment(), BooksSegment()]);
  void toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  void bookNextPrevButton({bool? isPrev}) {
    assert(currentTypedPath.last is BookSegment);
    var id = (currentTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    toBook(id: id);
  }

  void toogleLogin() => ref.read(userIsLoggedProvider.notifier).update((s) => !s);
}

/// number of books
const booksLen = 5;
