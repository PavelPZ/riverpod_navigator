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

/// ... mark the segments that require login: book with odd id
bool needsLogin(ExampleSegments segment) => segment is BookSegment && segment.id.isOdd;

// ********************************************
// navigation state
// ********************************************

@freezed
class NavigationState with _$NavigationState {
  factory NavigationState({required TypedPath path, required bool userIsLogged}) = _NavigationState;
}

// ********************************************
// providers
// ********************************************

/// RiverpodNavigator
final riverpodNavigatorProvider = Provider<RiverpodNavigator>((ref) => RiverpodNavigator(ref));

/// monitoring of all states that affect navigation
final navigationStateProvider = StateProvider<NavigationState>((ref) => NavigationState(path: [], userIsLogged: false));

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

  /// Flutter Navigation 2.0 RouterDelegate
  RiverpodRouterDelegate routerDelegate;

  /// implements all navigation change application logic (redirection, login required, etc.)
  ///
  /// Returns:
  /// - redirect path, when application logic requires redirect to other typed path
  /// - null if newPath is already processed
  TypedPath? appNavigationLogic(TypedPath oldPath, NavigationState navigationState) => null;

  /// Main [RiverpodNavigatorLow] method. Provides navigation to the new [TypedPath].
  @nonVirtual
  void navigate(TypedPath newPath) {
    // listen for changing navigation state
    _unlistenNavigationState ??= ref.listen<NavigationState>(navigationStateProvider, (_, newNavigationState) {
      final oldPath = routerDelegatePath;

      final redirectPath = appNavigationLogic(oldPath, newNavigationState);

      // redirect
      if (redirectPath != null) {
        scheduleMicrotask(() => navigate(redirectPath));
        return;
      }

      // no redirect => actualize navigation stack
      routerDelegate.currentConfiguration = newNavigationState.path;
      routerDelegate.doNotifyListener();
    });

    // change actualTypedPath => refresh navigation state
    ref.read(navigationStateProvider.notifier).update((state) => state.copyWith(path: newPath));

    // This line is necessary to activate the [navigationStateProvider].
    // Without this line [navigationStateProvider] is not listened.
    // ignore: unused_local_variable
    final res = ref.read(navigationStateProvider);
  }

  @nonVirtual
  TypedPath get routerDelegatePath => routerDelegate.currentConfiguration;

  /// for [Navigator.onPopRoute] in [RiverpodRouterDelegate.build]
  @nonVirtual
  void onPopRoute() => pop();

  // *** common navigation-agnostic app actions ***

  @nonVirtual
  void pop() {
    final actPath = routerDelegatePath;
    if (actPath.length <= 1) return;
    navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
  }

  @nonVirtual
  void push(ExampleSegments segment) => navigate([...routerDelegatePath, segment]);

  @nonVirtual
  void replaceLast(ExampleSegments segment) {
    final actPath = routerDelegatePath;
    return navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i], segment]);
  }
}

// ********************************************
//   RiverpodNavigator
// ********************************************

/// navigator is available throw riverpodNavigatorProvider
class RiverpodNavigator extends RiverpodNavigatorLow {
  RiverpodNavigator(Ref ref) : super(ref);

  /// returns redirected TypeedPath when:
  /// - not logged in
  /// - newPath contains a book with an odd id  @override
  @override
  TypedPath? appNavigationLogic(TypedPath oldPath, NavigationState navigationState) {
    return !navigationState.userIsLogged && navigationState.path.any(needsLogin) ? [HomeSegment(), BooksSegment()] : null;
  }

  void toHome() => navigate([HomeSegment()]);
  void toBooks() => navigate([HomeSegment(), BooksSegment()]);
  void toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);
  void bookNextPrevButton({bool? isPrev}) {
    assert(routerDelegatePath.last is BookSegment);
    var id = (routerDelegatePath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    toBook(id: id);
  }

  void toogleLogin() => ref.read(navigationStateProvider.notifier).update((s) => s.copyWith(userIsLogged: !s.userIsLogged));
}

/// number of books
const booksLen = 5;
