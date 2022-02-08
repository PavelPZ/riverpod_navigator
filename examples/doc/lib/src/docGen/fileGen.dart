import 'dart:convert';

const all = 0xffffff;
const l1 = 1;
const l2 = 2; // async screen actions with splash screen
const l3 = 4; // login
const l4 = 8;
const l5 = 16;
const l6 = 32;
const l7 = 64;

const l35 = l3 + l5;

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

  String filter2(int maskPlus, int? maskMinus, int docWhen, String title, String subTitle, String body) {
    final mask = maskPlus & ~(maskMinus ?? 0);
    if ((lessonMask & mask) == 0) return '';

    if (forDoc && ((lessonMask & docWhen) == 0)) return '';

    return title + subTitle + body;
  }

  String comment(String body, {bool twoSlash = false}) =>
      forDoc ? '\n$body\n' : LineSplitter().convert(body).map((l) => '${twoSlash ? '//' : '///'} $l').join('\n');

  String t(String title, {bool h4 = false}) => (title = title.trim()).isEmpty ? '' : (forDoc ? (h4 ? '#### ' : '### ') : '// *** ') + '$title\n\n';
  String st(String subTitle) => (subTitle = subTitle.trim()).isEmpty ? '' : (forDoc ? '$subTitle' : '${comment(subTitle)}\n');
  String b(String body) => (body = body.trim()).isEmpty ? '' : (forDoc ? '\n\n```dart\n$body\n```\n\n' : '$body\n\n');

  String lName(String name) => forDoc ? '### $name' : name;
  String docIgn(String body) => forDoc ? '' : body;
  String codeIgn(String body) => forDoc ? body : '';

  String sourceUrl(String lesson, {bool isScreen = false}) =>
      '[${isScreen == true ? 'screen' : lesson}.dart source code](/examples/doc/lib/src/$lesson/${isScreen == true ? 'screens' : lesson}.dart)';

  String lessonDocUrl(String lesson, {bool wd = true}) => '[$lesson${wd ? ' documentation' : ''}](/doc/$lesson.md)';

  final l2hdr = '''
Lesson02 is ${lessonDocUrl('lesson01', wd: false)} enhanced with:

- asynchronous navigation when screens require some asynchronous actions (when creating, deactivating, or merging)
- the splash screen appears before the HomeScreen is displayed
''';
  final l3hdr = '''
Lesson03 is ${lessonDocUrl('lesson02', wd: false)} extended by:

- login application logic (where some pages are not available without a logged in user)
- more TypedPath roots (AppSegments and LoginSegments)
- navigation state also depends on another provider (userIsLoggedProvider)
''';
  final l4hdr = '''
Lesson04 is ${lessonDocUrl('lesson03', wd: false)} prepared using the router concept.
''';
  final l5hdr = '''
Lesson05 is the same as ${lessonDocUrl('lesson03', wd: false)} but without screens and widgets.
It has not any GUI, only a test.
''';

  String exHeader(String body) => forDoc
      ? '\n$body\n'
      : '''
\n\n// *************************************
${comment(body, twoSlash: true)}
// *************************************\n
''';

  String lessonGen() => filter(forDoc ? 0 : all, null, b('''
// ignore: unused_import
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

${id == 5 ? '' : 'import \'screens.dart\';'}

part 'lesson$lessonId.freezed.dart';
part 'lesson$lessonId.g.dart';
''')) + filter(forDoc ? 0 : all, null, comment('''
''', twoSlash: true)) + filter(l1, null, exHeader('''
${lName('Lesson01')}${codeIgn('\n\n(whole example see at ${sourceUrl('lesson01')})\n')}
''')) + filter(l2, null, exHeader('''
${lName('Lesson02')}
$l2hdr
${codeIgn('See ${sourceUrl('lesson02')}')}
''')) + filter(l3, null, exHeader('''
${lName('Lesson03')}
$l3hdr
${codeIgn('See ${sourceUrl('lesson03')}')}
''')) + filter(l4, null, exHeader('''
${lName('Lesson04')}
$l4hdr
${codeIgn('See ${sourceUrl('lesson04')}')}
''')) + filter(l5, null, exHeader('''
${lName('Lesson05')}
$l5hdr
See the source code of the test here: [lesson05_test.dart](/examples/doc/test/lesson05_test.dart).
''')) + filter(l6, null, exHeader('''
Lesson06
''')) + filter(l7, null, exHeader('''
Lesson07
''')) + filter(l7, null, exHeader('''
-------------------------------------------
''')) + filter2(all, l35 + l4, l1, t('''
1. define classes for typed path segments (aka TypedSegment)
'''), st('''
From the following AppSegments class declaration, the [freezed package](https://github.com/rrousselGit/freezed) 
generates three typed segment classes: *HomeSegment, BooksSegment and BookSegment*.
'''), b(''' 
@freezed
class AppSegments with _\$AppSegments, TypedSegment {
  AppSegments._();
  factory AppSegments.home() = HomeSegment;
  factory AppSegments.books() = BooksSegment;
  factory AppSegments.book({required int id}) = BookSegment;

  factory AppSegments.fromJson(Map<String, dynamic> json) => _\$AppSegmentsFromJson(json);
}
''')) + filter2(l35 + l4, null, l1, t('''
1. define classes for typed path segments (aka TypedSegment)
'''), st('''
From the following AppSegments and LoginSegments class declaration, the [freezed package](https://github.com/rrousselGit/freezed) 
generates four typed segment classes: *HomeSegment, BooksSegment, BookSegment and LoginHomeSegment*.
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
''')) + filter2(l2 + l35, null, l2, t('''
1.1. async screen actions  
'''), st('''
Each screen may require an asynchronous action during its creation, merging, or deactivating.
The asynchronous result is then provided to the screen widget.
'''), b('''
AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
  // 
  /// helper for simulating asynchronous action. Its result is then provided to the screen widget.
  Future<String> simulateAsyncResult(String asyncResult, int msec) async {
    await Future.delayed(Duration(milliseconds: msec));
    return asyncResult;
  }

  if (segment is! AppSegments) return null;

  return segment.maybeMap(
    book: (_) => AsyncScreenActions<BookSegment>(
      // for every Book screen: creating takes some time
      creating: (newSegment) => simulateAsyncResult('Book.creating: async result after 700 msec', 700),
      // for every Book screen with odd id: changing to another Book screen takes some time
      merging: (_, newSegment) => newSegment.id.isOdd ? simulateAsyncResult('Book.merging: async result after 500 msec', 500) : null,
      // for every Book screen with even id: deactivating takes some time
      deactivating: (oldSegment) => oldSegment.id.isEven ? Future.delayed(Duration(milliseconds: 500)) : null,
    ),
    home: (_) => AsyncScreenActions<HomeSegment>(
      creating: (_) async => simulateAsyncResult('Home.creating: async result after 1000 msec', 1000),
    ),
    orElse: () => null,
  );
}
''')) + filter2(l4, null, l1, t('''
1.1. App route definition
'''), st('''
'''), b('''
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
''')) + filter2(l35 + l4, 0, l3, t('''
1.2. userIsLoggedProvider
'''), st('''
the navigation state also depends on the following [userIsLoggedProvider]
'''), b('''
final userIsLoggedProvider = StateProvider<bool>((_) => false);
''')) + filter2(all, 0, all - l5, t('''
2. Type App-specific navigator (aka AppNavigator)
'''), st(''), b('')) + filter2(all, 0, l1, '', st('''
AppNavigator is a singleton class that does the following:
- configures various navigation parameters 
- contains actions related to navigation. The actions are then used in the screen widgets.
'''), '\n\n') + filter2(l1, null, l1, t('''
2.1. Navigation parameters
''', h4: true), '', b('''
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          // home (initial) navigation path
          initPath: [HomeSegment()],
          // how to decode JSON to AppSegments
          json2Segment: (jsonMap, _) => AppSegments.fromJson(jsonMap),
          // map TypedSegment's to Screens
          screenBuilder: appSegmentsScreenBuilder,
        );
''')) + filter2(l2, 0, l2, t('Navigation parameters'), '', b('''
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          json2Segment: (jsonMap, _) => AppSegments.fromJson(jsonMap),
          screenBuilder: appSegmentsScreenBuilder,
          // ***** new parameters for this example ******
          // asynchronous screen actions
          segment2AsyncScreenActions: segment2AsyncScreenActions,
          // splash screen that appears before the home page is created
          splashBuilder: SplashScreen.new,
        );
''')) + filter2(l3, 0, l3, t('Navigation parameters'), '', b('''
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          segment2AsyncScreenActions: segment2AsyncScreenActions,
          splashBuilder: SplashScreen.new,
          // ****** new and modified parameters for this example ******
          // the following two parameters respect two different types of segment roots: [AppSegments] and [LoginSegments]
          json2Segment: (jsonMap, unionKey) => 
              unionKey == LoginSegments.jsonNameSpace ? LoginSegments.fromJson(jsonMap) : AppSegments.fromJson(jsonMap),
          screenBuilder: (segment) => segment is LoginSegments ? loginSegmentsScreenBuilder(segment) : appSegmentsScreenBuilder(segment),
          // the navigation state also depends on the userIsLoggedProvider
          dependsOn: [userIsLoggedProvider],
        );

  /// mark screens which needs login: every 'id.isOdd' book needs it
  bool needsLogin(TypedSegment segment) => segment is BookSegment && segment.id.isOdd;
''')) + filter2(l5, 0, l5, t('Navigation parameters'), '', b('''
class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          segment2AsyncScreenActions: segment2AsyncScreenActions,
          // remove splashBuilder
          // splashBuilder: SplashScreen.new,
          // ****** new and modified parameters for this example ******
          json2Segment: (jsonMap, unionKey) => 
              unionKey == LoginSegments.jsonNameSpace ? LoginSegments.fromJson(jsonMap) : AppSegments.fromJson(jsonMap),
          // fake screenBuilder
          screenBuilder: (segment) => SizedBox(),
          dependsOn: [userIsLoggedProvider],
        );

  /// mark screens which needs login: every 'id.isOdd' book needs it
  bool needsLogin(TypedSegment segment) => segment is BookSegment && segment.id.isOdd;
''')) + filter2(l4, 0, l4, t('Navigation parameters'), '', b('''
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
''')) + filter2(l35 + l4, 0, l3, t('''
2.1. Login app logic
''', h4: true), '', b('''
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
''')) + filter2(l35 + l4, 0, l3, t('''
2.1. Login specific navigation actions
''', h4: true), '', b('''
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
''')) + filter2(all, null, l1, t('''
2.2. Common navigation actions
''', h4: true), '', b('''
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
''')) + docIgn('''
}

const booksLen = 5;
''') + filter2(all, l5, l1, t('''
3. Root widget
'''), st('''
Note: *To make it less verbose, we use the functional_widget package to generate widgets.
See generated "lesson??.g.dart"" file for details.*
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
''')) + filter2(all, l5, l1, t('''
4. App entry point
'''), st('''
app entry point with ProviderScope's override
'''), b('''
void runMain() => runApp(
    ProviderScope(
      overrides: [
        riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new /*See Constructor tear-offs in Dart ^2.15*/),
      ],
      child: const BooksExampleApp(),
    ),
  );
''')) + codeIgn(filter2(l5, null, l5, t('Ukázka testu'), '', b('''
//
    //**********
    // log in tests
    //**********

    await navigTest(() => navigator.toHome(), 'home');

    // navigate to book 3, book 3 needs login => redirected to login page
    await navigTest(() => navigator.toBook(id: 3), 'login-home;loggedUrl=home%2Fbooks%2Fbook%3Bid%3D3;canceledUrl=home');

    // confirm login => redirect to book 3
    await navigTest(() => navigator.loginPageOK(), 'home/books/book;id=3');

    // to previous book 2
    await navigTest(() => navigator.bookNextPrevButton(isPrev: true), 'home/books/book;id=2');

    // to previous book 1
    await navigTest(() => navigator.bookNextPrevButton(isPrev: true), 'home/books/book;id=1');

    // logout, but book needs login => redirected to login page
    await navigTest(() => navigator.globalLogoutButton(), 'login-home;loggedUrl=home%2Fbooks%2Fbook%3Bid%3D1;canceledUrl=');

    // cancel login => redirect to home
    await navigTest(() => navigator.loginPageCancel(), 'home');
''')));

//*********************************
//*********************************
//
//  SCREENS
//
//*********************************
//*********************************

  String screenGen() => docIgn(b('''
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'lesson$lessonId.dart';

part 'screens.g.dart';
''')) + filter2(all, null, l1, t('''
5. Map TypedSegment's to Screens
'''), st('${codeIgn('''
You can view all application screens and widgets here: ${sourceUrl('lesson01', isScreen: true)}
''')}'), b('''
final ScreenBuilder appSegmentsScreenBuilder = (segment) => (segment as AppSegments).map(
  // See Constructor tear-offs in Dart ^2.15, "HomeScreen.new" is equivalent to "(segment) => HomeScreen(segment)"
      home: HomeScreen.new,
      books: BooksScreen.new,
      book: BookScreen.new,
    );
''')) + docIgn(b('''
// ************************************
// Using "functional_widget" package to be less verbose.
// ************************************

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(onPressed: onPressed, child: Text(title));

@swidget
Widget splashScreen() =>
    SizedBox.expand(child: Container(color: Colors.white, child: Center(child: Icon(Icons.circle_outlined, size: 150, color: Colors.deepPurple))));

@hwidget
Widget countBuilds() {
  final count = useState(0);
  count.value++;
  return Text('Builded \${count.value} times.');
}
''')) + filter(all, 0, docIgn(b('''
@swidget
Widget homeScreen(HomeSegment segment) => PageHelper(
      title: 'Home Screen',
      asyncActionResult: segment.asyncActionResult,
      buildChildren: (navigator) => [
        LinkHelper(title: 'Books Page', onPressed: navigator.toBooks),
      ],
    );

'''))) + filter(all, l35 + l4, docIgn(b('''
@swidget
Widget booksScreen(BooksSegment segment) => PageHelper(
      title: 'Books Screen',
      asyncActionResult: segment.asyncActionResult,
      buildChildren: (navigator) =>
          [for (var id = 0; id < booksLen; id++) LinkHelper(title: 'Book Screen, id=\$id', onPressed: () => navigator.toBook(id: id))],
    );
'''))) + filter(l35 + l4, 0, docIgn(b('''
@cwidget
Widget booksScreen(WidgetRef ref, BooksSegment segment) => PageHelper(
      title: 'Books Screen',
      asyncActionResult: segment.asyncActionResult,
      buildChildren: (navigator) => [
        for (var id = 0; id < booksLen; id++)
          LinkHelper(
              title: 'Book Screen, id=$id\${!ref.watch(userIsLoggedProvider) && id.isOdd ? ' (log in first)' : ''}',
              onPressed: () => navigator.toBook(id: id))
      ],
    );
'''))) + filter(all, 0, docIgn(b('''
@swidget
Widget bookScreen(BookSegment segment) => PageHelper(
      title: 'Book Screen, id=\${segment.id}',
      asyncActionResult: segment.asyncActionResult,
      buildChildren: (navigator) => [
        LinkHelper(title: 'Next >>', onPressed: navigator.bookNextPrevButton),
        LinkHelper(title: '<< Prev', onPressed: () => navigator.bookNextPrevButton(isPrev: true)),
      ],
    );
'''))) + filter(l35 + l4, 0, docIgn(b('''
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
'''))) + filter(all, l35 + l4, docIgn(b('''
@cwidget
Widget pageHelper(WidgetRef ref, {required String title, required List<Widget> buildChildren(AppNavigator navigator), dynamic asyncActionResult}) {
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
          if (asyncActionResult!=null) res.addAll([Text(asyncActionResult.toString()), SizedBox(height: 20)]);
          res.add(CountBuilds());
          return res;
        })(),
      ),
    ),
  );
}
'''))) + filter(l35 + l4, 0, docIgn(b('''
@cwidget
Widget pageHelper(
  WidgetRef ref, {
  required String title,
  required List<Widget> buildChildren(AppNavigator navigator),
  bool? isLoginPage,
  dynamic asyncActionResult,
}) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: (() {
          final res = <Widget>[SizedBox(height: 20)];
          for (final w in buildChildren(navigator)) res.addAll([w, SizedBox(height: 20)]);
          res.add(CountBuilds());
          if (asyncActionResult!=null) res.addAll([Text(asyncActionResult.toString()), SizedBox(height: 20)]);
          SizedBox(height: 40);
          return res;
        })(),
      ),
    ),
  );
}
'''))) + filter(l1, 0, codeIgn('''
## Other lessons:

### Lesson02
$l2hdr
See ${lessonDocUrl('lesson02')}

### Lesson03
$l3hdr
See ${lessonDocUrl('lesson03')}

### Lesson04
$l4hdr
See ${lessonDocUrl('lesson04')}

### Lesson05
$l5hdr
See ${lessonDocUrl('lesson05')}
'''));

  return isLesson ? lessonGen() : screenGen();
}
