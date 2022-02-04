import 'dart:async';
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

import 'routerDelegate.dart';

part 'navigator.freezed.dart';
part 'navigator.g.dart';

// ********************************************
//  basic classes:  ExampleSegments and TypedPath
// ********************************************

/// Terminology:
/// - string path: 'home/books/book;id=2'
/// - the string path consists of segments: 'home', 'books', 'book;id=2'
/// - typed path: [HomeSegment(), BooksSegment(), BookSegment(id:2)]
/// - the typed path consists of typed segments: HomeSegment(), BooksSegment(), BookSegment(id:2)
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

/// Typed variant of whole url path (which consists of [TypedSegment]s)
typedef TypedPath = List<ExampleSegments>;

/// ... mark the segments that require login: book with odd id
bool needsLogin(ExampleSegments segment) => segment is BookSegment && segment.id.isOdd;

// ********************************************
// providers
// ********************************************

/// RiverpodNavigator
final riverpodNavigatorProvider = Provider<RiverpodNavigator>((ref) => RiverpodNavigator(ref));

/// ongoing TypedPath provider
///
/// [ongoingTypedPath] may differ from [RiverpodNavigatorLow.currentTypedPath] during navigation calculation
final ongoingTypedPath = StateProvider<TypedPath>((_) => []);

/// watching userIsLogged state
final userIsLoggedProvider = StateProvider<bool>((_) => false);

// ********************************************
//   Defer2NextTick
// ********************************************

/// helper class that solves the problem where two providers (on which navigation depends) change in one tick, e.g.
///
/// ```
/// ref.read(userIsLoggedProvider.notifier).update((s) => !s)
/// ref.read(ongoingTypedPath.notifier).state = [HomeSegment(), BooksSegment()];
/// ```
/// without the Defer2NextTick class, [RiverpodRouterDelegate.doNotifyListener] is called twice in code:
/// ```
/// routerDelegate.currentConfiguration = ref.read(ongoingTypedPath);
/// routerDelegate.doNotifyListener();
/// ```
class Defer2NextTick {
  Defer2NextTick({required this.runNextTick});
  Completer? _completer;
  FutureOr<void> Function() runNextTick;

  void start() {
    if (_completer != null) return;
    _completer = Completer();
    scheduleMicrotask(() async {
      try {
        final value = runNextTick();
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
class RiverpodNavigatorLow {
  RiverpodNavigatorLow(this.ref, {required List<AlwaysAliveProviderListenable> dependsOn}) : routerDelegate = RiverpodRouterDelegate() {
    routerDelegate.navigator = this;

    _defer2NextTick = Defer2NextTick(runNextTick: _runNavigation);
    final allDepends = <AlwaysAliveProviderListenable>[ongoingTypedPath, ...dependsOn];
    for (final depend in allDepends) _unlistens.add(ref.listen<dynamic>(depend, (previous, next) => defer2NextTick.start()));
    // ignore: avoid_function_literals_in_foreach_calls
    ref.onDispose(() => _unlistens.forEach((f) => f()));
  }

  @protected
  Ref ref;

  Defer2NextTick get defer2NextTick => _defer2NextTick as Defer2NextTick;
  Defer2NextTick? _defer2NextTick;

  /// for ref.onDispose
  final List<Function> _unlistens = [];

  /// Flutter Navigation 2.0 RouterDelegate
  RiverpodRouterDelegate routerDelegate;

  /// implements all navigation change application logic here (redirection, login required, etc.)
  FutureOr<void> appNavigationLogic(Ref ref, TypedPath currentPath) => null;

  /// synchronize [ongoingTypedPath] with [RiverpodRouterDelegate.currentConfiguration]
  Future<void> _runNavigation() async {
    final appLogic = appNavigationLogic(ref, currentTypedPath);
    if (appLogic is Future) await appLogic;
    routerDelegate.currentConfiguration = ref.read(ongoingTypedPath);
    routerDelegate.doNotifyListener();
  }

  /// Main [RiverpodNavigatorLow] method. Provides navigation to the new [TypedPath].
  /// After changing [ongoingTypedPath], the navigation state is updated
  @nonVirtual
  Future<void> navigate(TypedPath newPath) {
    ref.read(ongoingTypedPath.notifier).state = newPath;
    return defer2NextTick.future;
  }

  @nonVirtual
  TypedPath get currentTypedPath => routerDelegate.currentConfiguration;

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
//   RiverpodNavigator
// ********************************************

/// navigator is available throw riverpodNavigatorProvider
///
/// Navigator state depends on [ongoingTypedPath] and [userIsLoggedProvider] providers
class RiverpodNavigator extends RiverpodNavigatorLow {
  RiverpodNavigator(Ref ref) : super(ref, dependsOn: [ongoingTypedPath, userIsLoggedProvider]);

  /// Avoid navigation to [BookSegment] with odd [BookSegment.id] (and instead redirects to [HomeSegment (), BooksSegment ()])
  /// when not logged in
  @override
  FutureOr<void> appNavigationLogic(Ref ref, TypedPath currentPath) {
    final userIsLogged = ref.read(userIsLoggedProvider);
    final ongoingNotifier = ref.read(ongoingTypedPath.notifier);

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
