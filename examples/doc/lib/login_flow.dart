import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() => runApp(
      ProviderScope(
        /// Navigation stack depends on isLoggedProvider too.
        /// Add dependsOn with [isLoggedProvider]
        overrides: providerOverrides([HomeSegment()], AppNavigator.new,
            dependsOn: [isLoggedProvider]),
        child: const App(),
      ),
    );

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.read(navigatorProvider) as AppNavigator;
    return MaterialApp.router(
      title: 'Riverpod Navigator Example',
      routerDelegate: navigator.routerDelegate,
      routeInformationParser: navigator.routeInformationParser,
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeSegment extends TypedSegment {
  const HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars pars) => HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  factory BookSegment.fromUrlPars(UrlPars pars) =>
      BookSegment(id: pars.getInt('id'));
  final int id;

  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);
}

class LoginSegment extends TypedSegment {
  const LoginSegment({this.loggedUrl, this.canceledUrl});
  factory LoginSegment.fromUrlPars(UrlPars pars) => LoginSegment(
        loggedUrl: pars.getStringNull('loggedUrl'),
        canceledUrl: pars.getStringNull('canceledUrl'),
      );
  final String? loggedUrl;
  final String? canceledUrl;

  @override
  void toUrlPars(UrlPars pars) => pars
      .setString('loggedUrl', loggedUrl)
      .setString('canceledUrl', canceledUrl);
}

/// !!! there is another provider on which the navigation status depends:
final isLoggedProvider = StateProvider<bool>((_) => false);

/// !!! only book screens with odd 'id' require a login
bool needsLogin(TypedSegment segment) =>
    segment is BookSegment && segment.id.isOdd;

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoute<HomeSegment>(
              'home',
              HomeSegment.fromUrlPars,
              HomeScreen.new,
            ),
            RRoute<BookSegment>(
              'book',
              BookSegment.fromUrlPars,
              BookScreen.new,
            ),
            RRoute<LoginSegment>(
              'login',
              LoginSegment.fromUrlPars,
              LoginScreen.new,
            ),
          ],
        );

  /// Quards and redirects for login flow
  @override
  TypedPath appNavigationLogic(TypedPath intendedPath) {
    final userIsLogged = ref.read(isLoggedProvider);
    final navigationStack = ref.read(navigationStackProvider);

    // if user is not logged-in and some of the screen in intendedPath needs login => redirect to LoginScreen
    if (!userIsLogged && intendedPath.any((segment) => needsLogin(segment))) {
      // prepare URLs for confirmation or cancel cases on the login screen
      final loggedUrl = pathParser.toUrl(intendedPath);
      var canceledUrl =
          navigationStack.isEmpty || navigationStack.last is LoginSegment
              ? ''
              : pathParser.toUrl(navigationStack);
      if (loggedUrl == canceledUrl) {
        canceledUrl = ''; // chance to exit login loop
      }

      // redirect to login screen
      return [LoginSegment(loggedUrl: loggedUrl, canceledUrl: canceledUrl)];
    } else {
      // user is logged and LogginScreen is going to display => redirect to HomeScreen
      if (userIsLogged &&
          (intendedPath.isEmpty || intendedPath.last is LoginSegment)) {
        return [HomeSegment()];
      }
    }
    // no redirection is needed, return intendedPath
    return intendedPath;
  }

  // ******* actions used on the screens

  /// navigate to book
  Future toBook({required int id}) =>
      navigate([HomeSegment(), BookSegment(id: id)]);

  /// navigate to next book
  Future toNextBook() =>
      replaceLast<BookSegment>((old) => BookSegment(id: old.id + 1));

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);

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
    var returnPath = pathParser.fromUrl(
        cancel ? loginHomeSegment.canceledUrl : loginHomeSegment.loggedUrl);
    if (returnPath.isEmpty) returnPath = [HomeSegment()];

    // start navigating to a return path
    ref.read(intendedPathProvider.notifier).state = returnPath;

    // actualize login state
    if (!cancel) ref.read(isLoggedProvider.notifier).state = true;

    // wait for the navigation to complete
    return navigationCompleted;
  }
}

/// common screen ancestor for [HomeScreen] and [BookScreen]
abstract class AppScreen<S extends TypedSegment>
    extends RScreen<AppNavigator, S> {
  const AppScreen(S segment, this.screenTitle) : super(segment);

  final String screenTitle;

  @override
  Widget buildScreen(ref, navigator, appBarLeading) => Scaffold(
        appBar: AppBar(
          title: Text(screenTitle),
          leading: appBarLeading,
          actions: [
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
            children: [
              for (final w in buildWidgets(ref, navigator)) ...[
                SizedBox(height: 20),
                w
              ],
            ],
          ),
        ),
      );

  List<Widget> buildWidgets(WidgetRef ref, AppNavigator navigator);
}

class HomeScreen extends AppScreen<HomeSegment> {
  const HomeScreen(HomeSegment segment) : super(segment, 'Home');

  @override
  List<Widget> buildWidgets(ref, navigator) {
    final bool isLogged = ref.watch(isLoggedProvider);
    return [
      for (var i = 1; i <= bookCount; i++)
        ElevatedButton(
          onPressed: () => navigator.toBook(id: i),
          child: Text('Book $i${!isLogged && i.isOdd ? '(log in first)' : ''}'),
        ) // normal page
    ];
  }
}

class BookScreen extends AppScreen<BookSegment> {
  BookScreen(BookSegment segment) : super(segment, 'Book ${segment.id}');

  @override
  List<Widget> buildWidgets(ref, navigator) => [
        ElevatedButton(
          onPressed: navigator.toNextBook,
          child: const Text('Go to next book'),
        ),
        ElevatedButton(
          onPressed: navigator.toHome,
          child: const Text('Go to Home'),
        ),
      ];
}

const bookCount = 5;

class LoginScreen extends RScreen<AppNavigator, LoginSegment> {
  const LoginScreen(LoginSegment segment) : super(segment);

  @override
  Widget buildScreen(ref, navigator, appBarLeading) => Scaffold(
        appBar: AppBar(
          title: Text('Login'),
          leading: IconButton(
            onPressed: navigator.loginScreenCancel,
            icon: Icon(Icons.cancel),
          ),
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: navigator.loginScreenOK, child: Text('Login')),
        ),
      );
}
