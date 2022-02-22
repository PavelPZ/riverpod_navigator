import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

part 'simple.freezed.dart';
part 'simple.g.dart';

void main() => runApp(
      ProviderScope(
        // home=path and navigator constructor are required
        overrides:
            RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );

@freezed
class Segments with _$Segments, TypedSegment {
  Segments._();

  /// here Segments.home means that the string 'home' appears in the web URL '/home'
  factory Segments.home() = HomeSegment;

  /// here, the Segments.page means that 'home' string appeares in web url '/page;title=Page'
  factory Segments.page({required String title}) = PageSegment;

  factory Segments.fromJson(Map<String, dynamic> json) =>
      _$SegmentsFromJson(json);
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            // json deserialize HomeSegment or PageSegment
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<HomeSegment>(
                  HomeScreen.new), // build a HomeScreen for HomeSegment
              RRoute<PageSegment>(
                  PageScreen.new), // build a PageScreen for PageSegment
            ])
          ],
        );
}

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

class HomeScreen extends ConsumerWidget {
  const HomeScreen(this.segment, {Key? key}) : super(key: key);

  final HomeSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => ref
                    .read(navigatorProvider)
                    .navigate([HomeSegment(), PageSegment(title: 'Page')]),
                child: const Text('Go to page'),
              ),
            ],
          ),
        ),
      );
}

class PageScreen extends ConsumerWidget {
  const PageScreen(this.segment, {Key? key}) : super(key: key);

  final PageSegment segment;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(title: Text(segment.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                    ref.read(navigatorProvider).navigate([HomeSegment()]),
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      );
}
