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
          fromJson: SegmentGrp.fromJson,
          screenBuilder: (segment) => (segment as SegmentGrp).map(
            home: HomeScreen.new,
            page: PageScreen.new,
          ),
          // returns a Future with the result of an asynchronous operation for a given segment's screen
          segment2AsyncScreenActions: (segment) => (segment as SegmentGrp).maybeMap(
            home: (_) => AsyncScreenActions(creating: (newSegment) => simulateAsyncResult('Home.creating', 2000)),
            page: (_) => AsyncScreenActions(
              creating: (newSegment) => simulateAsyncResult('Page.creating', 400),
              merging: (oldSegment, newSegment) => simulateAsyncResult('Page.merging', 200),
              // async operation during screen deactivating, null means no action.
              deactivating: (oldSegment) => null,
            ),
            orElse: () => null,
          ),
          // splash screen that appears before the first page is created
          splashBuilder: SplashScreen.new,
        );
}

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
          onPressed: () => navigator.navigate([HomeSegment(), PageSegment(title: 'Page1')]),
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
        ElevatedButton(
          onPressed: () => navigator.navigate([HomeSegment(), PageSegment(title: segment.title == 'Page1' ? 'Page2' : 'Page1')]),
          child: const Text('Go to next page'),
        ),
      ],
    );
