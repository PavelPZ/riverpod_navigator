import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'common.dart' show App;

part 'login_flow.g.dart';
part 'login_flow.freezed.dart';

void main() => runApp(
      ProviderScope(
        overrides: [
          riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new),
        ],
        child: const App(),
      ),
    );

@freezed
class SegmentGrp with _$SegmentGrp, TypedSegment {
  SegmentGrp._();
  factory SegmentGrp.home() = HomeSegment;
  factory SegmentGrp.book({required int id}) = BookSegment;
  factory SegmentGrp.login({String? loggedUrl, String? canceledUrl}) = LoginSegment;

  factory SegmentGrp.fromJson(Map<String, dynamic> json) => _$SegmentGrpFromJson(json);
}

/// !!! there is another provider on which the navigation status depends:
final userIsLoggedProvider = StateProvider<bool>((_) => false);

/// !!! only book screens with odd 'id' require a login
bool needsLogin(TypedSegment segment) => segment is BookSegment && segment.id.isOdd;

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [HomeSegment()],
          [
            RRoutes<SegmentGrp>(SegmentGrp.fromJson, [
              RRoute<HomeSegment>(HomeScreen.new),
              RRoute<BookSegment>(BookScreen.new),
              RRoute<LoginSegment>(LoginScreen.new),
            ])
          ],
          dependsOn: [userIsLoggedProvider],
        );

  /// Quards and redirects for login flow
  @override
  TypedPath appNavigationLogic(TypedPath ongoingPath) {
    final userIsLogged = ref.read(userIsLoggedProvider);

    // if user is not logged-in and some of the screen in navigations stack needs login => redirect to LoginScreen
    if (!userIsLogged && ongoingPath.any((segment) => needsLogin(segment))) {
      // prepare loggedUrl and canceledUrl for login screen
      final loggedUrl = pathParser.typedPath2Path(ongoingPath);
      var canceledUrl = currentTypedPath.isEmpty || currentTypedPath.last is LoginSegment ? '' : pathParser.typedPath2Path(currentTypedPath);
      if (loggedUrl == canceledUrl) canceledUrl = ''; // chance to exit login loop
      // redirect to login screen
      return [LoginSegment(loggedUrl: loggedUrl, canceledUrl: canceledUrl)];
    } else {
      // user is logged and LogginScreen is going to display => redirect to HomeScreen
      if (userIsLogged && ongoingPath.isEmpty || ongoingPath.last is LoginSegment) return [HomeSegment()];
    }
    // no redirection is needed
    return ongoingPath;
  }

  // ******* actions used on the screens

  Future gotoNextBook() {
    final actualBook = currentTypedPath.last as BookSegment;
    return replaceLast(BookSegment(id: actualBook.id == 5 ? 1 : actualBook.id + 1));
  }

  Future globalLogoutButton() {
    // actualize login state
    ref.read(userIsLoggedProvider.notifier).state = false;
    // wait for the navigation to complete
    return navigationCompleted;
  }

  Future globalLoginButton() {
    // current screen text-path
    final actualStringPath = pathParser.typedPath2Path(currentTypedPath);
    // redirect to login screen
    return navigate([LoginSegment(loggedUrl: actualStringPath, canceledUrl: actualStringPath)]);
  }

  Future cancelOnloginPage() => _loginPageButtons(true);
  Future okOnloginPage() => _loginPageButtons(false);

  Future _loginPageButtons(bool cancel) {
    final loginHomeSegment = currentTypedPath.last as LoginSegment;

    var newPath = pathParser.path2TypedPath(cancel ? loginHomeSegment.canceledUrl : loginHomeSegment.loggedUrl);
    if (newPath.isEmpty) newPath = [HomeSegment()];

    // start navigating to a new path
    ref.read(ongoingPathProvider.notifier).state = newPath;

    // actualize login state
    if (!cancel) ref.read(userIsLoggedProvider.notifier).state = true;

    // wait for the navigation to complete
    return navigationCompleted;
  }
}

@cwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper(
      title: 'Home',
      segment: segment,
      buildChildren: (navigator) => [
        for (var i = 1; i <= bookCount; i++)
          ElevatedButton(
            onPressed: () => navigator.navigate([HomeSegment(), BookSegment(id: i)]),
            child: Text('Book $i'),
          ) // normal page
      ],
    );

const bookCount = 5;

@cwidget
Widget bookScreen(WidgetRef ref, BookSegment book) => PageHelper(
      segment: book,
      title: 'Book ${book.id}',
      buildChildren: (navigator) => [
        ElevatedButton(
          onPressed: navigator.gotoNextBook,
          child: const Text('Go to next book'),
        ),
      ],
    );

@swidget
Widget loginScreen(LoginSegment segment) => PageHelper(
      segment: segment,
      title: 'Login Page',
      isLoginPage: true,
      buildChildren: (navigator) => [
        ElevatedButton(onPressed: navigator.okOnloginPage, child: Text('Login')),
      ],
    );

@cwidget
Widget pageHelper(
  WidgetRef ref, {
  required String title,
  required TypedSegment segment,
  required List<Widget> buildChildren(AppNavigator navigator),
  bool? isLoginPage,
}) {
  final navigator = ref.read(riverpodNavigatorProvider) as AppNavigator;
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: isLoginPage == true
          ? IconButton(
              onPressed: navigator.cancelOnloginPage,
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
          res.addAll([Text('Dump actual typed-path: "${navigator.debugSegmentSubpath(segment)}"')]);
          return res;
        })(),
      ),
    ),
  );
}