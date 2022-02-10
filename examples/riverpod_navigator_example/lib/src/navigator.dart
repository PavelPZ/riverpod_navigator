import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

import 'routerDelegate.dart';

part 'navigator.freezed.dart';
part 'navigator.g.dart';

/// TypedPath = Typed url path, which consists of [TypedSegment]s
typedef TypedPath = List<ExampleSegments>;

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
//   RiverpodNavigator
// ********************************************

/// Helper singleton class for manaing navigation state
class RiverpodNavigator {
  RiverpodNavigator(this.ref, {required List<AlwaysAliveProviderListenable> dependsOn}) : routerDelegate = RiverpodRouterDelegate() {
    routerDelegate.navigator = this;

    // 1. Listen for [ongoingPathProvider, ...dependsOn] riverpod providers - call defer2NextTick.onNavigationStateChanged().
    // 2. Add RemoveListener's to _unlistens
    // 3. Use _unlistens in ref.onDispose
    for (final depend in dependsOn) _unlistens.add(ref.listen<dynamic>(depend, (previous, next) => _onNavigationStateChanged));
    // ignore: avoid_function_literals_in_foreach_calls
    ref.onDispose(() => _unlistens.forEach((f) => f()));
  }

  /// Enter application navigation logic here (redirection, login, etc.).
  /// It can be empty when no redirect or guard is required.
  TypedPath appNavigationLogic(TypedPath ongoingPath) => ongoingPath;

  /// Flutter Navigation 2.0 RouterDelegate
  RiverpodRouterDelegate routerDelegate;

  /// Note: [ongoingPathProvider] state may differ from [currentTypedPath] during navigation calculation.
  TypedPath get currentTypedPath => routerDelegate.currentConfiguration;

  /// synchronize [ongoingPathProvider] with [RouterDelegate.currentConfiguration]
  void _onNavigationStateChanged() {
    //=====> at this point, "ongoingPathProvider state" and "riverpodRouterDelegate.currentConfiguration" could differ
    // get ongoingPath notifier
    final ongoingPathNotifier = ref.read(ongoingPathProvider.notifier);
    // run app specific application navigation logic here (redirection, login, etc.).
    final newOngoingPath = appNavigationLogic(ongoingPathNotifier.state);
    // actualize a possibly changed ongoingPath
    ongoingPathNotifier.state = newOngoingPath;
    // the next two lines will cause Flutter Navigator 2.0 to update the navigation stack according to the ongoingPathProvider state
    routerDelegate.currentConfiguration = newOngoingPath;
    routerDelegate.doNotifyListener();
    //=====> at this point, "ongoingPathProvider state" and  "RiverpodRouterDelegate" are in sync
  }

  /// Main [RiverpodNavigator] method. Provides navigation to the new [TypedPath].
  /// After changing [ongoingPathProvider] state, the navigation state is updated.
  @nonVirtual
  void navigate(TypedPath newPath) {
    ref.read(ongoingPathProvider.notifier).state = newPath;
  }

  @protected
  Ref ref;

  /// for ref.onDispose
  final List<Function> _unlistens = [];

  /// for [Navigator.onPopRoute] in [RiverpodRouterDelegate.build]
  void onPopRoute() {
    final actPath = currentTypedPath;
    if (actPath.length <= 1) return;
    navigate([for (var i = 0; i < actPath.length - 1; i++) actPath[i]]);
  }
}

// ********************************************
//   AppNavigator
// ********************************************

/// navigator is available throw riverpodNavigatorProvider
///
/// Navigator state depends on [ongoingPathProvider] and [userIsLoggedProvider] providers
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          dependsOn: [ongoingPathProvider, userIsLoggedProvider],
        );

  /// ... mark the segments that require login: book with odd id
  bool needsLogin(ExampleSegments segment) => segment is BookSegment && segment.id.isOdd;

  /// Avoid navigation to [BookSegment] with odd [BookSegment.id] (and instead redirects to [HomeSegment (), BooksSegment ()])
  /// when not logged in
  @override
  TypedPath appNavigationLogic(TypedPath ongoingPath) {
    final userIsLogged = ref.read(userIsLoggedProvider);
    if (!userIsLogged && ongoingPath.any(needsLogin)) return [HomeSegment(), BooksSegment()];
    return ongoingPath;
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
