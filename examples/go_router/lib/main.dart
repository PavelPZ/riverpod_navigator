import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

part 'main.freezed.dart';
part 'main.g.dart';

void main() => runApp(
      ProviderScope(
        overrides: RNavigatorCore.providerOverrides([Page1Segment()], AppNavigator.new),
        child: const App(),
      ),
    );

@freezed
class Segments with _$Segments, TypedSegment {
  Segments._();
  factory Segments.page1() = Page1Segment;
  factory Segments.page2() = Page2Segment;

  factory Segments.fromJson(Map<String, dynamic> json) => _$SegmentsFromJson(json);
}

/// helper extension for screens
extension WidgetRefApp on WidgetRef {
  AppNavigator get navigator => read(riverpodNavigatorProvider) as AppNavigator;
}

/// helper extension for test
extension RefApp on Ref {
  AppNavigator get navigator => read(riverpodNavigatorProvider) as AppNavigator;
}

class AppNavigator extends RNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          [
            RRoutes<Segments>(Segments.fromJson, [
              RRoute<Page1Segment>(Page1Screen.new),
              RRoute<Page2Segment>(Page2Screen.new),
            ])
          ],
        );

  static const title = 'GoRouter Example: main';
}

@cwidget
Widget app(WidgetRef ref) {
  final navigator = ref.navigator;
  return MaterialApp.router(
    title: AppNavigator.title,
    routerDelegate: navigator.routerDelegate,
    routeInformationParser: RouteInformationParserImpl(navigator.pathParser),
    debugShowCheckedModeBanner: false,
  );
}

@cwidget
Widget page1Screen(WidgetRef ref, Page1Segment segment) => Scaffold(
      appBar: AppBar(title: const Text(AppNavigator.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => ref.navigator.navigate([Page2Segment()]),
              child: const Text('Go to page 2'),
            ),
          ],
        ),
      ),
    );

@cwidget
Widget page2Screen(WidgetRef ref, Page2Segment segment) => Scaffold(
      appBar: AppBar(title: const Text(AppNavigator.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => ref.navigator.navigate([Page1Segment()]),
              child: const Text('Go to home page'),
            ),
          ],
        ),
      ),
    );
