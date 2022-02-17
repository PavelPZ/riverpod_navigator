import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';

part 'simple.freezed.dart';
part 'simple.g.dart';

void main() => runApp(
      ProviderScope(
        overrides: RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );

@Freezed(maybeWhen: false, maybeMap: false)
class Segments with _$Segments, TypedSegment {
  Segments._();
  factory Segments.home() = HomeSegment;
  factory Segments.page({required String title}) = PageSegment;

  factory Segments.fromJson(Map<String, dynamic> json) => _$SegmentsFromJson(json);
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<HomeSegment>(HomeScreen.new), // build a screen from segment
              RRoute<PageSegment>(PageScreen.new),
            ])
          ],
        );
}

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.navigator;
    return MaterialApp.router(
      title: 'Riverpod Navigator Example',
      routerDelegate: navigator.routerDelegate,
      routeInformationParser: navigator.routeInformationParser,
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
                // following navigation create navigation stack "HomeScreen(HomeSegment()) => PageScreen(PageSegment(title: 'Page title'))".
                onPressed: () => ref.navigator.navigate([HomeSegment(), PageSegment(title: 'Page')]),
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
                // following navigation create navigation stack "HomeScreen(HomeSegment())".
                onPressed: () => ref.navigator.navigate([HomeSegment()]),
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      );
}
