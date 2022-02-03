import 'dart:async';
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tuple/tuple.dart';

import 'routerDelegate.dart';

part 'navigator.freezed.dart';
part 'navigator.g.dart';

// ********************************************
//  basic classes:  ExampleSegments and TypedPath
// ********************************************

/// Terminology:
/// - string path => 'home/books/book;id=2'
/// - the string path consists of segments => 'home', 'books', 'book;id=2'
/// - typed path => [HomeSegment(), BooksSegment(), BookSegment(id:2)]
/// - the typed path consists of typed segments => HomeSegment(), BooksSegment(), BookSegment(id:2)
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

// ********************************************
// providers
// ********************************************

/// RiverpodNavigator
final riverpodNavigatorProvider = Provider<RiverpodNavigator>((ref) => RiverpodNavigator(ref));

/// Provides actual [TypedPath] to whole app
final typedPathProvider = StateProvider<TypedPath>((_) => []);

/// Provides actual [isLogged] state to whole app
final isLoggedProvider = StateProvider<bool>((_) => false);

/// monitoring of all states that affect navigation
final navigationStateProvider = Provider<Tuple2<TypedPath, bool>>((ref) => Tuple2(ref.watch(typedPathProvider), ref.watch(isLoggedProvider)));

// ********************************************
//   RiverpodNavigatorLow
// ********************************************

/// Helper singleton class for manaing navigation state
class RiverpodNavigatorLow {
  RiverpodNavigatorLow(this.ref) : routerDelegate = RiverpodRouterDelegate() {
    routerDelegate.navigator = this;
    ref.onDispose(() => _unlistenNavigationState?.call());
  }

  @protected
  Ref ref;

  Function? _unlistenNavigationState;

  RiverpodRouterDelegate routerDelegate;

  /// implements all navigation change application logic (redirection, login required, etc.)
  ///
  /// Returns redirect path or null (if newPath is already processed)
  TypedPath? appNavigationLogic(TypedPath oldPath, TypedPath newPath, bool isLogged) => null;

  /// Main [RiverpodNavigatorLow] method. Provides navigation to the new [TypedPath].
  @nonVirtual
  void navigate(TypedPath newPath) {
    // listen for changing navigation state
    _unlistenNavigationState ??= ref.listen<void>(navigationStateProvider, (_, __) {
      final oldPath = actualTypedPath;
      final newPath = ref.read(typedPathProvider);
      final newIsLogged = ref.read(isLoggedProvider);

      final redirectPath = appNavigationLogic(oldPath, newPath, newIsLogged);

      // redirect
      if (redirectPath != null) {
        scheduleMicrotask(() => navigate(redirectPath));
        return;
      }

      // no redirect => actualize navigation stack
      routerDelegate.currentConfiguration = newPath;
      routerDelegate.doNotifyListener();
    });

    // change actualTypedPath => refresh navigation state
    ref.read(typedPathProvider.notifier).state = newPath;

    // This line is necessary to activate the [navigationStateProvider].
    // Without this line [navigationStateProvider] is not listened.
    // ignore: unused_local_variable
    final res = ref.read(navigationStateProvider);
  }

  @nonVirtual
  TypedPath get actualTypedPath => routerDelegate.currentConfiguration;

  /// for [Navigator.onPopPage] in [RiverpodRouterDelegate.build]
  @nonVirtual
  void onPopRoute() => pop();

  // *** common navigation-agnostic app actions ***

  @nonVirtual
  void pop() {
    final actPath = actualTypedPath;
    if (actPath.length <= 1) return;
    navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
  }

  @nonVirtual
  void push(ExampleSegments segment) => navigate([...actualTypedPath, segment]);

  @nonVirtual
  void replaceLast(ExampleSegments segment) {
    final actPath = actualTypedPath;
    return navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i], segment]);
  }
}

// ********************************************
//   RiverpodNavigator
// ********************************************

/// mark the segments that require login: book with odd id
bool needsLogin(ExampleSegments segment) => segment is BookSegment && segment.id.isOdd;

/// navigator is available throw riverpodNavigatorProvider
class RiverpodNavigator extends RiverpodNavigatorLow {
  RiverpodNavigator(Ref ref) : super(ref);

  /// returns redirected TypeedPath when:
  /// - not logged in
  /// - newPath contains a book with an odd id  @override
  @override
  TypedPath? appNavigationLogic(TypedPath oldPath, TypedPath newPath, bool isLogged) {
    return !isLogged && newPath.any(needsLogin) ? [BooksSegment()] : null;
  }

  void toHome() => navigate([HomeSegment()]);
  void toBooks() => navigate([HomeSegment(), BooksSegment()]);
  void toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  void bookNextPrevButton({bool? isPrev}) {
    assert(actualTypedPath.last is BookSegment);
    var id = (actualTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    toBook(id: id);
  }

  void toogleLogin() => ref.read(isLoggedProvider.notifier).update((s) => !s);
}

/// number of books
const booksLen = 5;
