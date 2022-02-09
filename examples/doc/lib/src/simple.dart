import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

part 'simple.freezed.dart';
part 'simple.g.dart';

void main() => runApp(
      ProviderScope(
        overrides: [
          riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new),
        ],
        child: const App(),
      ),
    );

@freezed
class SimpleSegment with _$SimpleSegment, TypedSegment {
  SimpleSegment._();
  factory SimpleSegment.home() = HomeSegment;
  factory SimpleSegment.page({required String title}) = PageSegment;

  factory SimpleSegment.fromJson(Map<String, dynamic> json) => _$SimpleSegmentFromJson(json);
}

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          // display the the home screen when you start the application
          initPath: [HomeSegment()],
          // for JSON serialization of "typed-segment"
          fromJson: SimpleSegment.fromJson,
          // build a screen from segment
          screenBuilder: (segment) => (segment as SimpleSegment).map(
            home: HomeScreen.new,
            page: PageScreen.new,
          ),
        );
}

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.read(riverpodNavigatorProvider);
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
                // following navigation create navigation stack "HomeScreen(HomeSegment()) => PageScreen(PageSegment(title: 'Page title'))".
                onPressed: () => ref.read(riverpodNavigatorProvider).navigate([HomeSegment(), PageSegment(title: 'Page title')]),
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
                onPressed: () => ref.read(riverpodNavigatorProvider).navigate([HomeSegment()]),
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      );
}
