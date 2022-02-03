import 'dart:async';
import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tuple/tuple.dart';

import 'routerDelegate.dart';

part 'navigator.freezed.dart';
part 'navigator.g.dart';

typedef JsonMap = Map<String, dynamic>;

// ********************************************
//  basic classes:  TypedSegment and TypedPath
// ********************************************

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

/// Helper singleton class for navigating to [TypedPath]
class RiverpodNavigatorLow {
  RiverpodNavigatorLow(this.ref) : routerDelegate = RiverpodRouterDelegate() {
    routerDelegate.navigator = this;
    ref.onDispose(() => _unlistenNavigationState?.call());
  }

  @protected
  Ref ref;

  Function? _unlistenNavigationState;

  RiverpodRouterDelegate routerDelegate;

  /// put all change-route application logic here (redirects, needs login etc.)
  ///
  /// Returns redirect path or null (if newPath is already processed)
  TypedPath? appNavigationLogic(TypedPath oldPath, TypedPath newPath, bool isLogged) => null;

  /// Main [RiverpodNavigatorLow] method. Provides navigation to the new [TypedPath].
  ///
  /// If the navigation logic depends on another state (e.g. whether the user is logged in or not),
  /// use watch for this state in overrided [RiverpodNavigatorLow.appNavigationLogic]
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

    // this line is necessary to activate the [navigationStateProvider] provider
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

const booksLen = 5;

bool needsLogin(ExampleSegments segment) => segment is BookSegment && segment.id.isOdd;

class RiverpodNavigator extends RiverpodNavigatorLow {
  RiverpodNavigator(Ref ref) : super(ref);

  /// Returns redirect to BooksScreeb for Book's with odd Book.id
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
