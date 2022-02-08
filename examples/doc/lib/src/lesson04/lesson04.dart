// ignore: unused_import
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screens.dart';

part 'lesson04.freezed.dart';
part 'lesson04.g.dart';



// *************************************
// Lesson04
// Lesson04 is [lesson03](https://github.com/PavelPZ/riverpod_navigator/blob/main/doc/lesson03.md) prepared using the router concept.
// 
// 
// *************************************

// *** 1. define classes for typed-segments (aka TypedSegment)

/// From the following AppSegments and LoginSegments class declaration, the [freezed package](https://github.com/rrousselGit/freezed) 
/// generates four typed-segment classes: *HomeSegment, BooksSegment, BookSegment and LoginHomeSegment*.
@freezed
class AppSegments with _$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _$AppSegmentsFromJson(json);
}

@Freezed(unionKey: LoginSegments.jsonNameSpace)
class LoginSegments with _$LoginSegments, TypedSegment {
  /// json serialization hack: must be at least two constructors
  factory LoginSegments() = _LoginSegments;
  LoginSegments._();
  factory LoginSegments.home({String? loggedUrl, String? canceledUrl}) = LoginHomeSegment;

  factory LoginSegments.fromJson(Map<String, dynamic> json) => _$LoginSegmentsFromJson(json);
  static const String jsonNameSpace = '_login';
}

// *** 1.1. App route definition

//***********************
// AppRouter
//***********************
class AppRouter extends TypedRouter {
  AppRouter() : super([AppRouteGroup(), LoginRouteGroup()]);

  bool needsLogin(TypedSegment segment) {
    final route = segment2Group(segment).segment2Route(segment);
    return route is! AppRoute || route.needsLogin(segment);
  }
}

//***********************
// 
//***********************
class AppRouteGroup extends TypedRouteGroup<AppSegments> {
  @override
  AppSegments json2Segment(JsonMap jsonMap) => AppSegments.fromJson(jsonMap);

  @override
  TypedRoute segment2Route(AppSegments segment) => segment.map(home: (_) => homeRoute, books: (_) => booksRoute, book: (_) => bookRoute);

  final homeRoute = HomeRoute();
  final booksRoute = BooksRoute();
  final bookRoute = BookRoute();
}

/// extends route for "needsLogin" information
abstract class AppRoute<T extends TypedSegment> extends TypedRoute<T> {
  bool needsLogin(T segment) => false;
}
class HomeRoute extends AppRoute<HomeSegment> {
  @override
  Widget screenBuilder(HomeSegment segment) => HomeScreen(segment);
  @override
  Future<void>? creating(HomeSegment newPath) => _simulateAsyncResult('Home.creating: async result after 1000 msec', 1000);
}

class BooksRoute extends AppRoute<BooksSegment> {
  @override
  Widget screenBuilder(BooksSegment segment) => BooksScreen(segment);
}

class BookRoute extends AppRoute<BookSegment> {
  @override
  Widget screenBuilder(BookSegment segment) => BookScreen(segment);

  @override
  Future<void>? creating(BookSegment newPath) => _simulateAsyncResult('Book.creating: async result after 700 msec', 700);
  @override
  Future<void>? merging(oldPath, BookSegment newPath) =>
      newPath.id.isOdd ? _simulateAsyncResult('Book.merging: async result after 500 msec', 500) : null;
  @override
  Future<void>? deactivating(BookSegment oldPath) => oldPath.id.isEven ? _simulateAsyncResult('', 500) : null;

  @override
  bool needsLogin(BookSegment segment) => segment.id.isOdd;
}

class LoginRouteGroup extends TypedRouteGroup<LoginSegments> {
  LoginRouteGroup() : super(unionKey: LoginSegments.jsonNameSpace);

  @override
  LoginSegments json2Segment(JsonMap jsonMap) => LoginSegments.fromJson(jsonMap);

  @override
  TypedRoute segment2Route(LoginSegments segment) => segment.map((value) => throw UnimplementedError(), home: (_) => loginHomeRoute);

  final loginHomeRoute = LoginHomeRoute();
}

class LoginHomeRoute extends TypedRoute<LoginHomeSegment> {
  @override
  Widget screenBuilder(LoginHomeSegment segment) => LoginHomeScreen(segment);
}

Future<String> _simulateAsyncResult(String title, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return title;
}

// *** 1.2. userIsLoggedProvider

/// the navigation state also depends on the following [userIsLoggedProvider]
final userIsLoggedProvider = StateProvider<bool>((_) => false);

// *** 2. Type App-specific navigator (aka AppNavigator)

/// AppNavigator is a singleton class that does the following:
/// - configures various navigation parameters 
/// - contains actions related to navigation. The actions are then used in the screen widgets.


// *** 2.1. Navigation parameters

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          dependsOn: [userIsLoggedProvider],
          splashBuilder: SplashScreen.new,
          //******* router configuration ********
          // the router replaces the following parameters: json2Segment, screenBuilder, segment2AsyncScreenActions
          router: AppRouter(), 
        );

  /// The needLogin logic is handled by the router
  bool needsLogin(TypedSegment segment) => (router as AppRouter).needsLogin(segment);

// *** 2.1. Login app logic

@override
  FutureOr<void> appNavigationLogic(Ref ref, TypedPath currentPath) {
    final userIsLogged = ref.read(userIsLoggedProvider);
    final ongoingNotifier = ref.read(ongoingPathProvider.notifier);

    if (!userIsLogged) {
      final pathNeedsLogin = ongoingNotifier.state.any((segment) => needsLogin(segment));

      // login needed => redirect to login page
      if (pathNeedsLogin) {
        // parametters for login screen
        final loggedUrl = pathParser.typedPath2Path(ongoingNotifier.state);
        var canceledUrl = currentPath.isEmpty || currentPath.last is LoginHomeSegment ? '' : pathParser.typedPath2Path(currentPath);
        // chance to exit login loop
        if (loggedUrl == canceledUrl) canceledUrl = '';
        // redirect to login screen
        ongoingNotifier.state = [LoginHomeSegment(loggedUrl: loggedUrl, canceledUrl: canceledUrl)];
      }
    } else {
      // user logged and navigation to Login page => redirect to home
      if (ongoingNotifier.state.isEmpty || ongoingNotifier.state.last is LoginHomeSegment) ongoingNotifier.state = [HomeSegment()];
    }
  }

// *** 2.1. Login specific navigation actions

Future<void> globalLogoutButton() {
    final loginNotifier = ref.read(userIsLoggedProvider.notifier);
    // checking
    assert(loginNotifier.state); // is logged?
    // change login state
    loginNotifier.state = false;
    return navigationCompleted; // wait for the navigation to end
  }

  Future<void> globalLoginButton() {
    // checking
    assert(!ref.read(userIsLoggedProvider)); // is logoff?
    // navigate to login page
    final segment = pathParser.typedPath2Path(currentTypedPath);
    return navigate([LoginHomeSegment(loggedUrl: segment, canceledUrl: segment)]);
  }

  Future<void> loginPageCancel() => _loginPageButtons(true);
  Future<void> loginPageOK() => _loginPageButtons(false);

  Future<void> _loginPageButtons(bool cancel) async {
    assert(currentTypedPath.last is LoginHomeSegment);
    final loginHomeSegment = currentTypedPath.last as LoginHomeSegment;

    var newPath = pathParser.path2TypedPath(cancel ? loginHomeSegment.canceledUrl : loginHomeSegment.loggedUrl);
    if (newPath.isEmpty) newPath = [HomeSegment()];

    // change both providers on which the navigation status depends
    ref.read(ongoingPathProvider.notifier).state = newPath;
    if (!cancel) ref.read(userIsLoggedProvider.notifier).state = true;

    return navigationCompleted; // wait for the navigation to end
  }

// *** 2.2. Common navigation actions

//
  Future<void> toHome() => navigate([HomeSegment()]);

  Future<void> toBooks() => navigate([HomeSegment(), BooksSegment()]);

  Future<void> toBook({required int id}) => navigate([HomeSegment(), BooksSegment(), BookSegment(id: id)]);

  Future<void> bookNextPrevButton({bool? isPrev}) {
    assert(currentTypedPath.last is BookSegment);
    var id = (currentTypedPath.last as BookSegment).id;
    if (isPrev == true)
      id = id == 0 ? booksLen - 1 : id - 1;
    else
      id = booksLen - 1 > id ? id + 1 : 0;
    return toBook(id: id);
  }

}

const booksLen = 5;
// *** 3. Root widget

/// Note: *To make it less verbose, we use the functional_widget package to generate widgets.
/// See generated "lesson??.g.dart"" file for details.*
@cwidget
Widget booksExampleApp(WidgetRef ref) {
  final navigator = ref.read(riverpodNavigatorProvider);
  return MaterialApp.router(
    title: 'Books App',
    routerDelegate: navigator.routerDelegate as RiverpodRouterDelegate,
    routeInformationParser: RouteInformationParserImpl(navigator.pathParser),
    debugShowCheckedModeBanner: false,
  );
}

// *** 4. App entry point

/// app entry point with ProviderScope's override
void runMain() => runApp(
    ProviderScope(
      overrides: [
        riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new /*See Constructor tear-offs in Dart ^2.15*/),
      ],
      child: const BooksExampleApp(),
    ),
  );

