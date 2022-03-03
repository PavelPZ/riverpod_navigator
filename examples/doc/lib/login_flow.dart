import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() => runApp(
      ProviderScope(
        overrides: providerOverrides([HomeSegment()], AppNavigator.new, dependsOn: [isLoggedProvider]),
        child: const App(),
      ),
    );

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Riverpod Navigator Example',
        routerDelegate: ref.navigator.routerDelegate,
        routeInformationParser: ref.navigator.routeInformationParser,
        debugShowCheckedModeBanner: false,
      );
}

class HomeSegment extends TypedSegment {
  const HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars pars) => HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  factory BookSegment.fromUrlPars(UrlPars pars) => BookSegment(id: pars.getInt('id'));
  final int id;

  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);
}

class LoginSegment extends TypedSegment {
  const LoginSegment({this.loggedUrl, this.canceledUrl});
  factory LoginSegment.fromUrlPars(UrlPars pars) =>
      LoginSegment(loggedUrl: pars.getStringNull('loggedUrl'), canceledUrl: pars.getStringNull('canceledUrl'));
  final String? loggedUrl;
  final String? canceledUrl;

  @override
  void toUrlPars(UrlPars pars) => pars.setString('loggedUrl', loggedUrl)..setString('canceledUrl', canceledUrl);
}

/// !!! there is another provider on which the navigation status depends:
final isLoggedProvider = StateProvider<bool>((_) => false);

typedef NeedsLogin<T extends TypedSegment> = bool Function(T segment);

/// !!! only book screens with odd 'id' require a login
bool needsLogin(TypedSegment segment) => segment is BookSegment && segment.id.isOdd;

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
            RRoute<HomeSegment>('home', HomeSegment.fromUrlPars, HomeScreen.new),
            RRoute<BookSegment>('page', BookSegment.fromUrlPars, BookScreen.new),
            RRoute<LoginSegment>('login', LoginSegment.fromUrlPars, LoginScreen.new),
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
      final loggedUrl = pathParser.toUrl(ongoingPath);
      var canceledUrl = navigationStack.isEmpty || navigationStack.last is LoginSegment ? '' : pathParser.toUrl(navigationStack);
      if (loggedUrl == canceledUrl) {
        canceledUrl = ''; // chance to exit login loop
      }

      // redirect to login screen
      return [LoginSegment(loggedUrl: loggedUrl, canceledUrl: canceledUrl)];
    } else {
      // user is logged and LogginScreen is going to display => redirect to HomeScreen
      if (userIsLogged && (ongoingPath.isEmpty || ongoingPath.last is LoginSegment)) return [HomeSegment()];
    }
    // no redirection is needed but rebuild can appear (e.g. during logout)
    return [...ongoingPath];
  }

  // ******* actions used on the screens

  Future gotoNextBook() => replaceLast<BookSegment>((actualBook) => BookSegment(id: actualBook.id == 5 ? 1 : actualBook.id + 1));

  Future onLogout() {
    // actualize login state
    ref.read(isLoggedProvider.notifier).state = false;
    // wait for the navigation to complete
    return navigationCompleted;
  }

  Future onLogin() {
    // current navigation stack as string
    final navigStackAsString = pathParser.toUrl(getNavigationStack());
    // redirect to login screen
    return navigate([LoginSegment(loggedUrl: navigStackAsString, canceledUrl: navigStackAsString)]);
  }

  Future loginScreenCancel() => _loginScreenActions(true);
  Future loginScreenOK() => _loginScreenActions(false);

  Future _loginScreenActions(bool cancel) {
    final navigationStack = getNavigationStack();

    // get return path
    final loginHomeSegment = navigationStack.last as LoginSegment;
    var returnPath = pathParser.fromUrl(cancel ? loginHomeSegment.canceledUrl : loginHomeSegment.loggedUrl);
    if (returnPath.isEmpty) returnPath = [HomeSegment()];

    // start navigating to a return path
    ref.read(ongoingPathProvider.notifier).state = returnPath;

    // actualize login state
    if (!cancel) ref.read(isLoggedProvider.notifier).state = true;

    // wait for the navigation to complete
    return navigationCompleted;
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PageHelper(
        title: 'Home',
        segment: segment,
        buildChildren: (navigator) {
          final bool isLogged = ref.watch(isLoggedProvider);
          return [
            for (var i = 1; i <= bookCount; i++)
              ElevatedButton(
                onPressed: () => navigator.navigate([HomeSegment(), BookSegment(id: i)]),
                child: Text('Book $i${!isLogged && i.isOdd ? '(log in first)' : ''}'),
              ) // normal page
          ];
        },
      );
}

const bookCount = 5;

class BookScreen extends ConsumerWidget {
  const BookScreen(this.book, {Key? key}) : super(key: key);

  final BookSegment book;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PageHelper(
        segment: book,
        title: 'Book ${book.id}',
        buildChildren: (navigator) => [
          ElevatedButton(
            onPressed: navigator.gotoNextBook,
            child: const Text('Go to next book'),
          ),
        ],
      );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen(this.segment, {Key? key}) : super(key: key);

  final LoginSegment segment;

  @override
  Widget build(BuildContext context) => PageHelper(
        segment: segment,
        title: 'Login Page',
        isLoginPage: true,
        buildChildren: (navigator) => [
          ElevatedButton(onPressed: navigator.loginScreenOK, child: Text('Login')),
        ],
      );
}

class PageHelper extends ConsumerWidget {
  const PageHelper({Key? key, required this.title, required this.segment, required this.buildChildren, this.isLoginPage})
      : super(key: key);

  final String title;

  final TypedSegment segment;

  final List<Widget> Function(AppNavigator) buildChildren;

  final bool? isLoginPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              final isLogged = ref.watch(isLoggedProvider);
              return ElevatedButton(
                onPressed: isLogged ? navigator.onLogout : navigator.onLogin,
                child: Text(isLogged ? 'Logout' : 'Login'),
              );
            })
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: (() {
            final res = <Widget>[SizedBox(height: 20)];
            for (final w in buildChildren(navigator)) {
              res.addAll([w, SizedBox(height: 20)]);
            }
            res.addAll([Text('Dump actual typed-path: "${navigator.debugSegmentSubpath(segment)}"')]);
            return res;
          })(),
        ),
      ),
    );
  }
}
