import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

part 'async.g.dart';

void main() => runApp(
      ProviderScope(
        overrides: RNavigatorCore.providerOverrides([HomeSegment()], AppNavigator.new),
        child: const App(),
      ),
    );

class HomeSegment extends TypedSegment {
  static HomeSegment fromSegmentMap(SegmentMap map) => HomeSegment();
}

class PageSegment extends TypedSegment {
  PageSegment({required this.id});
  final int id;

  @override
  void toSegmentMap(SegmentMap map) => map.setInt('id', id);
  static PageSegment fromSegmentMap(SegmentMap map) => PageSegment(id: map.getInt('id'));
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
extension WidgetRefEx on WidgetRef {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}

/// helper extension for testing
///
/// ```dart
/// void main() {
///   test('navigation test', () async {
///     final container = ProviderContainer();
///     await container.navigator.toPage('Page');
///     await container.pump();
///     expect(container.navigator.navigationStack2Url, 'home/page;title=Page');
/// ...
/// ```
extension ProviderContainerEx on ProviderContainer {
  AppNavigator get navigator => read(navigatorProvider) as AppNavigator;
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoute<HomeSegment>(
              HomeSegment.fromSegmentMap,
              HomeScreen.new,
              opening: (newSegment) => simulateAsyncResult('Home.creating', 2000),
            ),
            RRoute<PageSegment>(
              PageSegment.fromSegmentMap,
              PageScreen.new,
              opening: (newSegment) => simulateAsyncResult('Page.creating', 400),
              replacing: (oldSegment, newSegment) => simulateAsyncResult('Page.merging', 200),
              closing: null,
            ),
          ],
          splashBuilder: () => SplashScreen(),
        );

  // It is good practice to place the code for all events specific to navigation in AppNavigator.
  // These can then be used not only for writing screen widgets, but also for testing.

  /// navigate to page
  Future toPage({required int id}) => navigate([HomeSegment(), PageSegment(id: id)]);

  /// navigate to next page
  Future toNextPage() => replaceLast<PageSegment>((old) => PageSegment(id: old.id + 1));

  /// navigate to home
  Future toHome() => navigate([HomeSegment()]);
}

@cwidget
Widget app(WidgetRef ref) => MaterialApp.router(
      title: 'Riverpod Navigator Example',
      routerDelegate: ref.navigator.routerDelegate,
      routeInformationParser: ref.navigator.routeInformationParser,
      debugShowCheckedModeBanner: false,
    );

// simulates an action such as loading external data or saving to external storage
Future<String> simulateAsyncResult(String asyncResult, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return '$asyncResult: async result after $msec msec';
}

@cwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper<AppNavigator>(
      segment: segment,
      title: 'Home',
      buildChildren: (navigator) => [
        ElevatedButton(
          onPressed: () => navigator.navigate([HomeSegment(), PageSegment(id: 1)]),
          child: const Text('Go to page'),
        ),
      ],
    );

@cwidget
Widget pageScreen(WidgetRef ref, PageSegment segment) => PageHelper<AppNavigator>(
      segment: segment,
      title: 'Page ${segment.id}',
      buildChildren: (navigator) => [
        ElevatedButton(
          onPressed: () => navigator.navigate([HomeSegment()]),
          child: const Text('Go to home'),
        ),
      ],
    );

@cwidget
Widget pageHelper<N extends RNavigator>(
  WidgetRef ref, {
  required TypedSegment segment,
  required String title,
  required List<Widget> buildChildren(N navigator),
}) {
  final navigator = ref.navigator as N;
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: (() {
          final res = <Widget>[SizedBox(height: 20)];
          for (final w in buildChildren(navigator)) {
            res.addAll([w, SizedBox(height: 20)]);
          }
          res.addAll([SizedBox(height: 20), Text('Dump actual typed-path: "${navigator.debugSegmentSubpath(segment)}"')]);
          // TODO(pz): xx
          // if (segment.asyncActionResult != null) res.addAll([SizedBox(height: 20), Text('Async result: "${segment.asyncActionResult}"')]);
          return res;
        })(),
      ),
    ),
  );
}

@swidget
Widget splashScreen() =>
    SizedBox.expand(child: Container(color: Colors.white, child: Center(child: Icon(Icons.hourglass_full, size: 150, color: Colors.deepPurple))));
