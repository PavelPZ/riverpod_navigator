import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

part 'login_flow.g.dart';
part 'login_flow.freezed.dart';

void main() => runApp(
      ProviderScope(
        overrides: RNavigatorCore.providerOverrides(
            [HomeSegment()], AppNavigator.new,
            dependsOn: [isLoggedProvider]),
        child: const App(),
      ),
    );

@cwidget
Widget app(WidgetRef ref) => MaterialApp.router(
      title: 'Riverpod Navigator Example',
      routerDelegate: ref.navigator.routerDelegate,
      routeInformationParser: ref.navigator.routeInformationParser,
      debugShowCheckedModeBanner: false,
    );

@freezed
class Segments with _$Segments, TypedSegment {
  Segments._();
  factory Segments.home() = HomeSegment;
  factory Segments.book({required int id}) = BookSegment;
  factory Segments.login({String? loggedUrl, String? canceledUrl}) =
      LoginSegment;

  factory Segments.fromJson(Map<String, dynamic> json) =>
      _$SegmentsFromJson(json);
}

/// !!! there is another provider on which the navigation status depends:
final isLoggedProvider = StateProvider<bool>((_) => false);

typedef NeedsLogin<T extends TypedSegment> = bool Function(T segment);

/// !!! only book screens with odd 'id' require a login
bool needsLogin(TypedSegment segment) =>
    segment is BookSegment && segment.id.isOdd;

/// helper extension for screens
extension WidgetRefApp on WidgetRef {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}

/// helper extension for test
extension ProviderContainerApp on ProviderContainer {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<HomeSegment>(HomeScreen.new),
              RRoute<BookSegment>(BookScreen.new),
              RRoute<LoginSegment>(LoginScreen.new),
            ])
          ],
        );

  /// Quards and redirects for login flow
  @override
  TypedPath appNavigationLogic(TypedPath ongoingPath) {
    final userIsLogged = ref.read(isLoggedProvider);
    final navigationStack = getNavigationStack();

    // if user is not logged-in and some of the screen in navigations stack needs login => redirect to LoginScreen
    if (!userIsLogged && ongoingPath.any((segment) => needsLogin(segment))) {
      // prepare URLs for confirmation or cancel cases on the login screen
      final loggedUrl = pathParser.typedPath2Path(ongoingPath);
      var canceledUrl =
          navigationStack.isEmpty || navigationStack.last is LoginSegment
              ? ''
              : pathParser.typedPath2Path(navigationStack);
      if (loggedUrl == canceledUrl)
        canceledUrl = ''; // chance to exit login loop

      // redirect to login screen
      return [LoginSegment(loggedUrl: loggedUrl, canceledUrl: canceledUrl)];
    } else {
      // user is logged and LogginScreen is going to display => redirect to HomeScreen
      if (userIsLogged &&
          (ongoingPath.isEmpty || ongoingPath.last is LoginSegment))
        return [HomeSegment()];
    }
    // no redirection is needed
    return ongoingPath;
  }

  // ******* actions used on the screens

  Future gotoNextBook() => replaceLast<BookSegment>((actualBook) =>
      BookSegment(id: actualBook.id == 5 ? 1 : actualBook.id + 1));

  Future onLogout() {
    // actualize login state
    ref.read(isLoggedProvider.notifier).state = false;
    // wait for the navigation to complete
    return navigationCompleted;
  }

  Future onLogin() {
    // current navigation stack as string
    final navigStackAsString = pathParser.typedPath2Path(getNavigationStack());
    // redirect to login screen
    return navigate([
      LoginSegment(
          loggedUrl: navigStackAsString, canceledUrl: navigStackAsString)
    ]);
  }

  Future loginScreenCancel() => _loginScreenActions(true);
  Future loginScreenOK() => _loginScreenActions(false);

  Future _loginScreenActions(bool cancel) {
    final navigationStack = getNavigationStack();

    // get return path
    final loginHomeSegment = navigationStack.last as LoginSegment;
    var returnPath = pathParser.path2TypedPath(
        cancel ? loginHomeSegment.canceledUrl : loginHomeSegment.loggedUrl);
    if (returnPath.isEmpty) returnPath = [HomeSegment()];

    // start navigating to a return path
    ref.read(ongoingPathProvider.notifier).state = returnPath;

    // actualize login state
    if (!cancel) ref.read(isLoggedProvider.notifier).state = true;

    // wait for the navigation to complete
    return navigationCompleted;
  }
}

@cwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper(
      title: 'Home',
      segment: segment,
      buildChildren: (navigator) {
        final bool isLogged = ref.watch(isLoggedProvider);
        return [
          for (var i = 1; i <= bookCount; i++)
            ElevatedButton(
              onPressed: () =>
                  navigator.navigate([HomeSegment(), BookSegment(id: i)]),
              child: Text(
                  'Book $i${!isLogged && i.isOdd ? '(log in first)' : ''}'),
            ) // normal page
        ];
      },
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
        ElevatedButton(
            onPressed: navigator.loginScreenOK, child: Text('Login')),
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
  final navigator = ref.navigator;
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: isLoginPage == true
          ? IconButton(
              onPressed: navigator.loginScreenCancel,
              icon: Icon(Icons.cancel),
            )
          : null,
      actions: [
        if (isLoginPage != true)
          Consumer(builder: (_, ref, __) {
            final isLoggedNotifier = ref.watch(isLoggedProvider.notifier);
            return ElevatedButton(
              onPressed: () => isLoggedNotifier.update((s) => !s),
              child: Text(isLoggedNotifier.state ? 'Logout' : 'Login'),
            );
          })
      ],
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: (() {
          final res = <Widget>[SizedBox(height: 20)];
          for (final w in buildChildren(navigator))
            res.addAll([w, SizedBox(height: 20)]);
          res.addAll([
            Text(
                'Dump actual typed-path: "${navigator.debugSegmentSubpath(segment)}"')
          ]);
          return res;
        })(),
      ),
    ),
  );
}
