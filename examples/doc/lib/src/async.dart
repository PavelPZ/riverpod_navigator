import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'common.dart';

part 'async.g.dart';

void main() => runApp(
      ProviderScope(
        overrides: [
          riverpodNavigatorCreatorProvider.overrideWithValue(AppNavigator.new),
        ],
        child: const App(),
      ),
    );

class AppNavigator extends RiverpodNavigator {
  AppNavigator(Ref ref)
      : super(
          ref,
          initPath: [HomeSegment()],
          fromJson: SimpleSegment.fromJson,
          screenBuilder: (segment) => (segment as SimpleSegment).map(
            home: HomeScreen.new,
            page: PageScreen.new,
          ),
          segment2AsyncScreenActions: (segment) => (segment as SimpleSegment).maybeMap(
            home: (_) => AsyncScreenActions(creating: (_) => simulateAsyncResult('Home.creating: async result after 2000 msec', 2000)),
            page: (_) => AsyncScreenActions(creating: (_) => simulateAsyncResult('Page.creating: async result after 400 msec', 400)),
            orElse: () => null,
          ),
          splashBuilder: SplashScreen.new,
        );
}

Future<String> simulateAsyncResult(String asyncResult, int msec) async {
  await Future.delayed(Duration(milliseconds: msec));
  return asyncResult;
}

@cwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper<AppNavigator>(
      segment: segment,
      title: 'Home',
      buildChildren: (navigator) => [
        ElevatedButton(
          onPressed: () => navigator.navigate([HomeSegment(), PageSegment(title: 'Page')]),
          child: const Text('Go to page'),
        ),
      ],
    );

@cwidget
Widget pageScreen(WidgetRef ref, PageSegment segment) => PageHelper<AppNavigator>(
      segment: segment,
      title: segment.title,
      buildChildren: (navigator) => [
        ElevatedButton(
          onPressed: () => navigator.navigate([HomeSegment()]),
          child: const Text('Go to home'),
        ),
      ],
    );
