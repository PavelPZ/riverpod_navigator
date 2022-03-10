import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//*********************************************
//*********************************************
//
//  How to easily connect riverpod provider (navigationStackProvider)
//  with Flutter Navigator 2.0 RouterDelegate.
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
// PROVIDERS
//*********************************************

final routerDelegateProvider =
    Provider<RRouterDelegate>((ref) => RRouterDelegate(ref, [HomeSegment()]));

final navigationStackProvider =
    StateProvider<TypedPath>((_) => [HomeSegment()]);

//*********************************************
// MODEL
// typed-path and typed-path segments
//*********************************************

typedef JsonMap = Map<String, dynamic>;

/// Ancestor for typed segments.
///
/// Instead of ```navigate('home/book;id=3')``` we can use
/// ```navigate([HomeSegment(), BookSegment(id: 3)]);```
abstract class TypedSegment {
  factory TypedSegment.fromJson(JsonMap json) =>
      json['runtimeType'] == 'BookSegment'
          ? BookSegment(id: json['id'])
          : HomeSegment();

  JsonMap toJson() => <String, dynamic>{'runtimeType': runtimeType.toString()};
  @override
  String toString() => jsonEncode(toJson());
}

/// Typed variant of whole url path (which consists of [TypedSegment]s)
typedef TypedPath = List<TypedSegment>;

//**** app specific segments

class HomeSegment with TypedSegment {}

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
        routerDelegate: ref.read(routerDelegateProvider),
        routeInformationParser: RouteInformationParserImpl(),
        debugShowCheckedModeBanner: false,
      );
}

//*********************************************
// RouterDelegate
//*********************************************

class RRouterDelegate extends RouterDelegate<TypedPath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath> {
  RRouterDelegate(this.ref, this.homePath) {
    final unlisten =
        ref.listen(navigationStackProvider, (_, __) => notifyListeners());
    ref.onDispose(unlisten);
  }

  final Ref ref;
  final TypedPath homePath;

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
      throw UnimplementedError();
    }

    return Navigator(
        key: navigatorKey,
        pages: navigationStack
            .map((segment) => MaterialPage(
                  key: ValueKey(segment.toString()),
                  child: screenBuilder(segment),
                ))
            .toList(),
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          final notifier = ref.read(navigationStackProvider.notifier);
          if (notifier.state.length <= 1) return false;
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
    navigate(configuration);
    return SynchronousFuture(null);
  }

  void navigate(TypedPath newPath) =>
      ref.read(navigationStackProvider.notifier).state = newPath;
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const Text('Riverpod App Home'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 1; i < 4; i++) ...[
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => ref.read(routerDelegateProvider).navigate([
                    HomeSegment(),
                    BookSegment(id: i),
                    if (i > 1) BookSegment(id: 10 + i),
                    if (i > 2) BookSegment(id: 100 + i),
                  ]),
                  child: Text(
                      'Go to Book: [$i${i > 1 ? ', 1$i' : ''}${i > 2 ? ', 10$i' : ''}]'),
                ),
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
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () =>
                    ref.read(routerDelegateProvider).navigate([HomeSegment()]),
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      );
}

// https://gist.github.com/PavelPZ/970ba56347a19d86ccafeb551b013fd3
// https://dartpad.dev/?id=970ba56347a19d86ccafeb551b013fd3
