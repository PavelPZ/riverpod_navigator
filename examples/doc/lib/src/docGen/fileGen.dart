import 'dart:convert';

const all = 0xffffff;
const l1 = 1;
const l2 = 2; // async screen actions with splash screen
const l3 = 4; // login
const l4 = 8;
const l5 = 16;
const l6 = 32;
const l7 = 64;

const lessonMasks = <int>[0, l1, l2, l3, l4, l5, l6, l7];

String int2LessonId(int id) => id.toString().padLeft(2, '0');

String fileGen(
  bool isLesson,
  int id,
  // =true => dart only, =false => flutter only, null => single file for flutter and dart
  bool forDoc, {
  bool? screenSplitDartFlutterOnly, // =true => for splited example, null => single file for flutter and dart
}) {
  assert(screenSplitDartFlutterOnly != false);

  final lessonMask = lessonMasks[id];
  final lessonId = int2LessonId(id);

  String filter(int maskPlus, int? maskMinus, String body) {
    final mask = maskPlus & ~(maskMinus ?? 0);
    if ((lessonMask & mask) == 0) return '';

    return body;
  }

  String filterScreen(bool? forSplitDartFlutter, String body) {
    assert(forSplitDartFlutter != false);
    if (screenSplitDartFlutterOnly != null) {
      if (forSplitDartFlutter != screenSplitDartFlutterOnly) return '';
    } else {
      if (forSplitDartFlutter != null) return '';
    }
    return body;
  }

  String filter2(int maskPlus, int? maskMinus, String title, String subTitle, String body) {
    final mask = maskPlus & ~(maskMinus ?? 0);
    if ((lessonMask & mask) == 0) return '';

    return title + subTitle + body;
  }

  String comment(String body) => LineSplitter().convert(body).map((l) => '// $l').join('\n');

  String t(String title) => (title = title.trim()).isEmpty ? '' : '// *** $title\n\n';
  String st(String subTitle) => (subTitle = subTitle.trim()).isEmpty ? '' : '${comment(subTitle)}\n';
  String b(String body) => (body = body.trim()).isEmpty ? '' : '$body\n\n';

  String exHeader(String body) => '''
// *************************************
${comment(body)}
// *************************************
// 
''';

  String lessonGen() => filter(all, null, b('''
// ignore: unused_import
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screens.dart';

part 'lesson$lessonId.freezed.dart';
part 'lesson$lessonId.g.dart';
''')) + filter(l1, null, exHeader('''
Example01
- Simple example
''')) + filter(l2, null, exHeader('''
Example02
- Screens require some asynchronous actions (when creating, deactivating or merging)
- The splash screen appeared before the HomeScreen was created
''')) + filter(l3, null, exHeader('''
Example03
- More TypedPath roots
- Login application logic (where some pages are not available without a logged in user)
''')) + filter(l4, null, exHeader('''
Example04
- introduction route concept
''')) + filter(l5, null, exHeader('''
Example05
''')) + filter(l6, null, exHeader('''
Example06
''')) + filter(l7, null, exHeader('''
Example07
''')) + filter2(all, l3 + l4, t('''
1. classes for typed path segments (TypedSegment)
'''), st('''
Terminology:
- string path:
```
final stringPath = 'home/books/book;id=2';
```
- the string path consists of three string segments: 'home', 'books', 'book;id=2'
- typed path:
```
final typedPath = <ExampleSegments>[HomeSegment(), BooksSegment(), BookSegment(id:2)];
```
- the typed path consists of three typed segments: HomeSegment(), BooksSegment(), BookSegment(id:2)
---------------------
From the following definition, [Freezed](https://github.com/rrousselGit/freezed) generates three typed segment classes,
HomeSegment, BooksSegment and BookSegment.

See [Freezed](https://github.com/rrousselGit/freezed) for details.
'''), b(''' 
@freezed
class AppSegments with _\$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _\$AppSegmentsFromJson(json);
}
''')) + filter2(l3 + l4, null, t('''
1. classes for typed path segments (TypedSegment)
'''), st('''
'''), b(''' 
@freezed
class AppSegments with _\$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _\$AppSegmentsFromJson(json);
}

@Freezed(unionKey: LoginSegments.jsonNameSpace)
class LoginSegments with _\$LoginSegments, TypedSegment {
  /// json serialization hack: must be at least two constructors
  factory LoginSegments() = _LoginSegments;
  LoginSegments._();
  factory LoginSegments.home({String? loggedUrl, String? canceledUrl}) = LoginHomeSegment;

  factory LoginSegments.fromJson(Map<String, dynamic> json) => _\$LoginSegmentsFromJson(json);
  static const String jsonNameSpace = '_login';
}
''')) + filter2(l2 + l3, null, t('''
1.1. async screen actions  
'''), st('''
Each screen may require an asynchronous action during its creation, merging, or deactivating.
'''), b('''
AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
  /// helper for simulating asynchronous action
  Future<String> simulateAsyncResult(String title, int msec) async {
    await Future.delayed(Duration(milliseconds: msec));
    return title;
  }

  return (segment as AppSegments).maybeMap(
    book: (_) => AsyncScreenActions<BookSegment>(
      // for every Book screen: creating takes some time
      creating: (newSegment) => simulateAsyncResult('Book creating async result after 1 sec', 1000),
      // for every Book screen with odd id: changing to another Book screen takes some time
      merging: (_, newSegment) => newSegment.id.isOdd ? simulateAsyncResult('Book merging async result after 500 msec', 500) : null,
      // for every Book screen with even id: deactivating takes some time
      deactivating: (oldSegment) => oldSegment.id.isEven ? Future.delayed(Duration(milliseconds: 500)) : null,
    ),
    home: (_) => AsyncScreenActions<HomeSegment>(
      creating: (_) async => simulateAsyncResult('Home creating async result after 1 sec', 1000),
    ),
    orElse: () => null,
  );
}
''')) + filter2(l4, null, t('''
1.1. App route definition
'''), st('''
'''), b('''
abstract class AppRoute<T extends TypedSegment> extends TypedRoute<T> {
  bool needsLogin(T segment) => false;
}

class AppRouter extends TypedRouter {
  AppRouter() : super([AppRouteGroup(), LoginRouteGroup()]);

   bool needsLogin(TypedSegment segment) => (segment2Group(segment).segment2Route(segment) as AppRoute).needsLogin(segment);
}

class AppRouteGroup extends RouteGroup<AppSegments> {
  @override
  AppSegments json2Segment(JsonMap jsonMap) => AppSegments.fromJson(jsonMap);

  @override
  TypedRoute segment2Route(AppSegments segment) => segment.map(home: (_) => homeRoute, books: (_) => booksRoute, book: (_) => bookRoute);

  final homeRoute = HomeRoute();
  final booksRoute = BooksRoute();
  final bookRoute = BookRoute();
}

class LoginHomeRoute extends TypedRoute<LoginHomeSegment> {
  @override
  Widget screenBuilder(LoginHomeSegment segment) => LoginHomeScreen(segment);
}

class HomeRoute extends AppRoute<HomeSegment> {
  @override
  Widget screenBuilder(HomeSegment segment) => HomeScreen(segment);
  @override
  Future<void>? creating(HomeSegment newPath) => _simulateAsyncResult('Home creating async result after 1 sec', 1000);
}

class BooksRoute extends AppRoute<BooksSegment> {
  @override
  Widget screenBuilder(BooksSegment segment) => BooksScreen(segment);
}

class BookRoute extends AppRoute<BookSegment> {
  @override
  Widget screenBuilder(BookSegment segment) => BookScreen(segment);

  @override
  Future<void>? creating(BookSegment newPath) => _simulateAsyncResult('Book creating async result after 1 sec', 1000);
  @override
  Future<void>? merging(oldPath, BookSegment newPath) =>
      newPath.id.isOdd ? _simulateAsyncResult('Book merging async result after 500 msec', 500) : null;
  @override
  Future<void>? deactivating(BookSegment oldPath) => oldPath.id.isEven ? _simulateAsyncResult('', 500) : null;

  @override
  bool needsLogin(BookSegment segment) => segment.id.isOdd;
}

class LoginRouteGroup extends RouteGroup<LoginSegments> {
  @override
  LoginSegments json2Segment(JsonMap jsonMap) => LoginSegments.fromJson(jsonMap);

  @override
  TypedRoute segment2Route(LoginSegments segment) => segment.map((value) => throw UnimplementedError(), home: (_) => loginHomeRoute);

  final loginHomeRoute = LoginHomeRoute();
}

Future<String> _simulateAsyncResult(String title, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return title;
}
''')) + filter2(all, l2 + l3 + l4, t('''
2. Specify navigation-aware actions in the navigator. The actions are then used in the screen widgets.
'''), st('''
'''), b('''
const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          json2Segment: (jsonMap, _) => AppSegments.fromJson(jsonMap),
          screenBuilder: appSegmentsScreenBuilder,
        );

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
''')) + filter2(l2, 0, t('''
2. Specify navigation-aware actions in the navigator. The actions are then used in the screen widgets.
'''), st('''
'''), b('''
const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          json2Segment: (jsonMap, _) => AppSegments.fromJson(jsonMap),
          screenBuilder: appSegmentsScreenBuilder,
          segment2AsyncScreenActions: segment2AsyncScreenActions, // <============================
        );

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
''')) + filter2(l3 + l4, null, t('''
2. App-specific navigator with navigation aware actions (used in screens)  
'''), st('''
'''), filter(l3, 0, b('''
/// the navigation state also depends on the following [userIsLoggedProvider]
final userIsLoggedProvider = StateProvider<bool>((_) => false);

const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          /// the navigation state also depends on the userIsLoggedProvider
          dependsOn: [userIsLoggedProvider],
          initPath: [HomeSegment()],
          segment2AsyncScreenActions: segment2AsyncScreenActions,
          //----- the following two parameters respect two different types of segment roots: [AppSegments] and [LoginSegments]
          json2Segment: (jsonMap, unionKey) => 
              unionKey == LoginSegments.jsonNameSpace ? LoginSegments.fromJson(jsonMap) : AppSegments.fromJson(jsonMap),
          screenBuilder: (segment) => segment is LoginSegments ? loginSegmentsScreenBuilder(segment) : appSegmentsScreenBuilder(segment),
        );

  /// mark screens which needs login: every 'id.isOdd' book needs it
  bool needsLogin(TypedSegment segment) => segment is BookSegment && segment.id.isOdd;
''')) + filter(l4, 0, b('''
/// the navigation state also depends on the following [userIsLoggedProvider]
final userIsLoggedProvider = StateProvider<bool>((_) => false);

const booksLen = 5;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          dependsOn: [userIsLoggedProvider],
          initPath: [HomeSegment()],
          router: AppRouter(), // <========================
        );

  /// The needLogin logic is handled by the router
  bool needsLogin(TypedSegment segment) => (router as AppRouter).needsLogin(segment);
''')) + filter(l3 + l4, 0, b('''
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
    // here can be async action for <oldPath, ongoingNotifier.state> pair
    return null;
  }

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

    var newSegment = pathParser.path2TypedPath(cancel ? loginHomeSegment.canceledUrl : loginHomeSegment.loggedUrl);
    if (newSegment.isEmpty) newSegment = [HomeSegment()];

    // change both providers on which the navigation status depends
    ref.read(ongoingPathProvider.notifier).state = newSegment;
    if (!cancel) ref.read(userIsLoggedProvider.notifier).state = true;

    return navigationCompleted; // wait for the navigation to end
  }
}
'''))) + filter2(all, null, t('''
3. Root widget and entry point (same for all examples)
'''), st('''
Root app widget

To make it less verbose, we use the functional_widget package to generate widgets.
See *.g.dart file for details.
'''), b('''
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

/// app entry point with ProviderScope  
void runMain() => runApp(
    ProviderScope(
      overrides: [
        riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new),
      ],
      child: const BooksExampleApp(),
    ),
  );
''')) + filter2(all, null, t('''
'''), st('''
'''), b('''
'''));

  String screenGen() => filterScreen(null, b('''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'lesson$lessonId.dart';

part 'screens.g.dart';

final ScreenBuilder appSegmentsScreenBuilder = (segment) => (segment as AppSegments).map(
      home: HomeScreen.new,
      books: BooksScreen.new,
      book: BookScreen.new,
    );

// ************************************
// Using "functional_widget" package to be less verbose.
// ************************************

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(onPressed: onPressed, child: Text(title));
''')) + filterScreen(true, b('''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'dart_lesson$lessonId.dart';

part 'screens.g.dart';

final ScreenBuilder appSegmentsScreenBuilder = (segment) => (segment as AppSegments).map(
      home: HomeScreen.new,
      books: BooksScreen.new,
      book: BookScreen.new,
    );

// ************************************
// Using "functional_widget" package to be less verbose.
// ************************************

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(onPressed: onPressed, child: Text(title));
''')) + filter(all, 0, b('''
@swidget
Widget homeScreen(HomeSegment segment) => PageHelper(
      title: 'Home Screen',
      buildChildren: (navigator) => [
        LinkHelper(title: 'Books Page', onPressed: navigator.toBooks),
      ],
    );

@swidget
Widget booksScreen(BooksSegment segment) => PageHelper(
      title: 'Books Screen',
      buildChildren: (navigator) =>
          [for (var id = 0; id < booksLen; id++) LinkHelper(title: 'Book Screen, id=\$id', onPressed: () => navigator.toBook(id: id))],
    );

@swidget
Widget bookScreen(BookSegment segment) => PageHelper(
      title: 'Book Screen, id=\${segment.id}',
      buildChildren: (navigator) => [
        LinkHelper(title: 'Next >>', onPressed: navigator.bookNextPrevButton),
        LinkHelper(title: '<< Prev', onPressed: () => navigator.bookNextPrevButton(isPrev: true)),
      ],
    );
''')) + filter(l2, 0, b('''
@swidget
Widget splashScreen() =>
    SizedBox.expand(child: Container(color: Colors.white, child: Center(child: Icon(Icons.circle_outlined, size: 150, color: Colors.deepPurple))));
''')) + filter(l3 + l4, 0, b('''
final ScreenBuilder loginSegmentsScreenBuilder = (segment) => (segment as LoginHomeSegment).map(
      (value) => throw UnimplementedError(),
      home: LoginHomeScreen.new,
    );

@swidget
Widget loginHomeScreen(LoginHomeSegment segment) => PageHelper(
      title: 'Login Page',
      isLoginPage: true,
      buildChildren: (navigator) => [
        ElevatedButton(onPressed: navigator.loginPageOK, child: Text('Login')),
      ],
    );
''')) + filter(all, l3 + l4, b('''
@cwidget
Widget pageHelper(WidgetRef ref, {required String title, required List<Widget> buildChildren(AppNavigator navigator)}) {
  final navigator = ref.read(riverpodNavigatorProvider) as AppNavigator;
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: (() {
          final res = <Widget>[SizedBox(height: 20)];
          for (final w in buildChildren(navigator)) res.addAll([w, SizedBox(height: 20)]);
          return res;
        })(),
      ),
    ),
  );
}
''')) + filter(l3 + l4, 0, b('''
@cwidget
Widget pageHelper(WidgetRef ref, {required String title, required List<Widget> buildChildren(AppNavigator navigator), bool? isLoginPage}) {
  final navigator = ref.read(riverpodNavigatorProvider) as AppNavigator;
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: isLoginPage == true
          ? IconButton(
              onPressed: navigator.loginPageCancel,
              icon: Icon(Icons.cancel),
            )
          : null,
      actions: [
        if (isLoginPage != true)
          Consumer(builder: (_, ref, __) {
            final isLogged = ref.watch(userIsLoggedProvider);
            return ElevatedButton(
              onPressed: () => isLogged ? navigator.globalLogoutButton() : navigator.globalLoginButton(),
              child: Text(isLogged ? 'Logout' : 'Login'),
            );
          }),
      ],
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (() {
          final res = <Widget>[SizedBox(height: 20)];
          for (final w in buildChildren(navigator)) res.addAll([w, SizedBox(height: 20)]);
          return res;
        })(),
      ),
    ),
  );
}
'''));

  return isLesson ? lessonGen() : screenGen();
}
