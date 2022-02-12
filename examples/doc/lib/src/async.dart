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
          [HomeSegment()],
          [
            RRoutes<SegmentGrp>(SegmentGrp.fromJson, [
              RRoute<HomeSegment>(
                HomeScreen.new,
                creating: (newSegment) => simulateAsyncResult('Home.creating', 2000),
              ),
              RRoute<PageSegment>(
                PageScreen.new,
                creating: (newSegment) => simulateAsyncResult('Page.creating', 400),
                merging: (oldSegment, newSegment) => simulateAsyncResult('Page.merging', 200),
                deactivating: null,
              ),
            ])
          ],
        );
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
