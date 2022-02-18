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

@freezed
class Segments with _$Segments, TypedSegment {
  Segments._();

  /// here Segments.home means that the string 'home' appears in the web URL '/home'
  factory Segments.home() = HomeSegment;

  /// here, the Segments.page means that 'home' string appeares in web url '/page;title=Page'
  factory Segments.page({required String title}) = PageSegment;

  factory Segments.fromJson(Map<String, dynamic> json) => _$SegmentsFromJson(json);
}

/// helper extension for screens
///
/// ```dart
/// class HomeScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
/// ...
///     ElevatedButton(onPressed: () => ref.navigator.toPage('Page title')
/// ```
extension WidgetRefApp on WidgetRef {
  AppNavigator get navigator => read(riverpodNavigatorProvider) as AppNavigator;
}

/// helper extension for testing
///
/// ```dart
/// void main() {
///   test('navigation test', () async {
///     final container = ProviderContainer();
///     await container.navigator.toPage('Page');
///     await container.pump();
///     expect(container.navigator.debugNavigationStack2String, 'home/page;title=Page');
/// ...
/// ```
extension ProviderContainerApp on ProviderContainer {
  AppNavigator get navigator => read(riverpodNavigatorProvider) as AppNavigator;
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            // json deserialize HomeSegment or PageSegment
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<HomeSegment>(HomeScreen.new), // build a HomeScreen for HomeSegment
              RRoute<PageSegment>(PageScreen.new), // build a PageScreen for PageSegment
            ])
          ],
        );

  /// navigate to page
  Future toPage(String title) => navigate([HomeSegment(), PageSegment(title: title)]);

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);
}

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Riverpod Navigator Example',
        routerDelegate: ref.navigator.routerDelegate,
        routeInformationParser: ref.navigator.routeInformationParser,
      );
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
                onPressed: () => ref.navigator.toPage('Page'),
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
                onPressed: () => ref.navigator.toHome(),
                child: const Text('Go to home'),
              ),
            ],
          ),
        ),
      );
}
