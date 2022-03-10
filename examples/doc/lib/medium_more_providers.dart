import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//*********************************************
//*********************************************
//
//  How to make login app flow easily
//

//*********************************************
//*********************************************

//*********************************************
// APP entry point
//*********************************************
void main() => runApp(
      const ProviderScope(child: App()),
    );

//*********************************************
// AppNavigator
//*********************************************

class AppNavigator extends RRouterDelegate {
  AppNavigator(Ref ref, TypedPath homePath) : super(ref, homePath);

  @override
  TypedPath appNavigationLogic(
      TypedPath actNavigStack, TypedPath intendedPath) {
    final userIsLogged = ref.read(isLoggedProvider);

    // if user is not logged-in and some of the screen in navigations stack needs login => redirect to LoginScreen
    if (!userIsLogged && intendedPath.any((segment) => needsLogin(segment))) {
      return [LoginSegment()];
    }

    // user is logged and LogginScreen is going to display => redirect to HomeScreen
    if (userIsLogged &&
        (intendedPath.isEmpty || intendedPath.last is LoginSegment)) {
      return [HomeSegment()];
    }

    // no redirection is needed
    return intendedPath;
  }
}

/// !!! only book screens with odd 'id' require a login
bool needsLogin(TypedSegment segment) =>
    segment is BookSegment && segment.id.isOdd;

//*********************************************
// PROVIDERS
//*********************************************

final appNavigatorProvider =
    Provider<AppNavigator>((ref) => AppNavigator(ref, [HomeSegment()]));

final intendedPathProvider = StateProvider<TypedPath>((_) => [HomeSegment()]);
final isLoggedProvider = StateProvider<bool>((_) => false);

final navigationStackProvider =
    StateProvider<TypedPath>((_) => [HomeSegment()]);

//*********************************************
// MODEL
// typed-path and typed-path segments
//*********************************************

typedef JsonMap = Map<String, dynamic>;

/// Common TypedSegment's ancestor
abstract class TypedSegment {
  factory TypedSegment.fromJson(JsonMap json) => json['runtimeType'] == 'book'
      ? BookSegment(id: json['id'])
      : json['runtimeType'] == 'login'
          ? LoginSegment()
          : HomeSegment();

  JsonMap toJson() => <String, dynamic>{
        'runtimeType': this is BookSegment
            ? 'book'
            : this is LoginSegment
                ? 'login'
                : 'home'
      };
  @override
  String toString() => jsonEncode(toJson());
}

/// Typed variant of whole url path (which consists of [TypedSegment]s)
typedef TypedPath = List<TypedSegment>;

//**** app specific segments

class HomeSegment with TypedSegment {}

class LoginSegment with TypedSegment {}

class BookSegment with TypedSegment {
  BookSegment({required this.id});
  final int id;
  @override
  JsonMap toJson() => super.toJson()..['id'] = id;
}

//*********************************************
// App root
//*********************************************
class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Riverpod Navigator Example',
        routerDelegate: ref.read(appNavigatorProvider),
        routeInformationParser: RouteInformationParserImpl(),
        debugShowCheckedModeBanner: false,
      );
}

//*********************************************
// Defer2NextTick
//*********************************************

/// helper class that solves problem, when two providers (on which navigation depend)
/// changed during single dart event loop.
/// In this case, without the [Defer2NextTick.providerChanged], navigation stack will changed twice.
class Defer2NextTick {
  Defer2NextTick();

  late RRouterDelegate navigator;
  var _ignoreNextProviderChange = false;
  var _isRunning = false;

  void providerChanged() {
    if (_ignoreNextProviderChange) return;
    if (_isRunning) return;
    _isRunning = true;
    scheduleMicrotask(() {
      try {
        final navigationStackNotifier =
            navigator.ref.read(navigationStackProvider.notifier);
        final intendedPathNotifier =
            navigator.ref.read(intendedPathProvider.notifier);

        // appNavigationLogic with possible redirects
        final newNavigStack = navigator.appNavigationLogic(
          navigationStackNotifier.state,
          intendedPathNotifier.state,
        );
        // synchronize navigation stack and intendedPath
        _ignoreNextProviderChange = true;
        try {
          intendedPathNotifier.state =
              navigationStackNotifier.state = newNavigStack;
        } finally {
          _ignoreNextProviderChange = false;
        }
      } finally {
        _isRunning = false;
      }
    });
  }
}

//*********************************************
// Defer2NextTick
//*********************************************

/// helper class that solves two problems:
///
/// 1. two providers (on which navigation depends) change in one tick
/// eg. if after a successful login:
///   - change the login state to true
///   - change the intendedPath state to a screen requiring a login
///
/// in this case, without the Defer2NextTick class, [navigationStackProvider] is changed twice
///
abstract class RRouterDelegate extends RouterDelegate<TypedPath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath> {
  RRouterDelegate(this.ref, this.homePath) {
    defer2NextTick.navigator = this;

    // listen for "input status" => call defer2NextTick.providerChanged => call applicationLogic
    final unlistens = [intendedPathProvider, isLoggedProvider]
        .map((e) => ref.listen(e, (_, __) => defer2NextTick.providerChanged()))
        .toList();

    // listen navigationStackProvider => call notifyListeners which then rebuilds the navigation stack
    unlistens
        .add(ref.listen(navigationStackProvider, (_, __) => notifyListeners()));

    // ignore: avoid_function_literals_in_foreach_calls
    ref.onDispose(() => unlistens.forEach((u) => u()));
  }

  final Ref ref;
  final TypedPath homePath;
  final defer2NextTick = Defer2NextTick();

  TypedPath appNavigationLogic(TypedPath actNavigStack, TypedPath intendedPath);

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  TypedPath get currentConfiguration => ref.read(navigationStackProvider);

  @override
  Widget build(BuildContext context) {
    final navigationStack = currentConfiguration;
    if (navigationStack.isEmpty) return const SizedBox();

    Widget screenBuilder(TypedSegment segment) {
      if (segment is HomeSegment) return HomeScreen(segment);
      if (segment is BookSegment) return BookScreen(segment);
      if (segment is LoginSegment) return LoginScreen(segment);
      throw UnimplementedError();
    }

    return Navigator(
        key: navigatorKey,
        pages: ref
            .read(navigationStackProvider)
            .map((segment) => MaterialPage(
                key: ValueKey(segment.toString()),
                child: screenBuilder(segment)))
            .toList(),
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          final notifier = ref.read(navigationStackProvider.notifier);
          if (notifier.state.length <= 1) return false;
          // remove last segment from navigationStack
          notifier.state = [
            for (var i = 0; i < notifier.state.length - 1; i++)
              notifier.state[i]
          ];
          return true;
        });
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) {
    if (configuration.isEmpty) configuration = homePath;
    ref.read(navigationStackProvider.notifier).state = configuration;
    return SynchronousFuture(null);
  }

  void navigate(TypedPath newPath) =>
      ref.read(intendedPathProvider.notifier).state = newPath;

  void replaceLast<T extends TypedSegment>(T Function(T old) replace) {
    final navigationStack = ref.read(navigationStackProvider);
    return navigate([
      for (var i = 0; i < navigationStack.length - 1; i++) navigationStack[i],
      replace(navigationStack.last as T)
    ]);
  }
}

//*********************************************
// Path Parser
//*********************************************

class RouteInformationParserImpl implements RouteInformationParser<TypedPath> {
  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) =>
      Future.value(path2TypedPath(routeInformation.location));

  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) =>
      RouteInformation(location: typedPath2Path(configuration));

  static String typedPath2Path(TypedPath typedPath) => typedPath
      .map((s) => Uri.encodeComponent(jsonEncode(s.toJson())))
      .join('/');

  static String debugTypedPath2Path(TypedPath typedPath) =>
      typedPath.map((s) => jsonEncode(s.toJson())).join('/');

  static TypedPath path2TypedPath(String? path) {
    if (path == null || path.isEmpty) return [];
    return [
      for (final s in path.split('/'))
        if (s.isNotEmpty) TypedSegment.fromJson(jsonDecode(Uri.decodeFull(s)))
    ];
  }
}

//*********************************************
// Widgets
//*********************************************

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Consumer(builder: (_, ref, __) {
        final isLogged = ref.watch(isLoggedProvider);
        return ElevatedButton(
          onPressed: () {
            final isLoggedNotifier = ref.read(isLoggedProvider.notifier);
            if (isLoggedNotifier.state) {
              isLoggedNotifier.state = false;
            } else {
              ref.read(appNavigatorProvider).navigate([LoginSegment()]);
            }
          },
          child: Text(isLogged ? 'Logout' : 'Login'),
        );
      });
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text('Riverpod App Home'),
          actions: [LoginButton()],
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 1; i < 4; i++) ...[
                const SizedBox(height: 30),
                Consumer(builder: (_, ref, __) {
                  final isLogged = ref.watch(isLoggedProvider);
                  return ElevatedButton(
                    onPressed: () => ref.read(appNavigatorProvider).navigate([
                      HomeSegment(),
                      BookSegment(id: i),
                    ]),
                    child: Text(
                        'Go to Book $i ${i.isOdd && !isLogged ? ' (needs login)' : ''}'),
                  );
                }),
              ]
            ],
          ),
        ),
      );
}

class BookScreen extends ConsumerWidget {
  const BookScreen(this.segment, {Key? key}) : super(key: key);

  final BookSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text('Book ${segment.id}'),
          actions: [LoginButton()],
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => ref
                    .read(appNavigatorProvider)
                    .replaceLast<BookSegment>(
                        (old) => BookSegment(id: old.id + 1)),
                child: const Text('Go to next book'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () =>
                    ref.read(appNavigatorProvider).navigate([HomeSegment()]),
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      );
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen(this.segment, {Key? key}) : super(key: key);

  final LoginSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text('Login Screen'),
          leading: IconButton(
            onPressed: () =>
                ref.read(appNavigatorProvider).navigate([HomeSegment()]),
            icon: const Icon(Icons.cancel),
          ),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  ref.read(intendedPathProvider.notifier).state = [
                    HomeSegment()
                  ];
                  ref.read(isLoggedProvider.notifier).state = true;
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
}

// https://gist.github.com/PavelPZ/a1df9d6b18e5e76b08d919b29fba6239
// https://dartpad.dev/?id=a1df9d6b18e5e76b08d919b29fba6239
