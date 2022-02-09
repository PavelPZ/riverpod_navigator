import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'common.dart';

part 'simple_deep.g.dart';

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
        );
}

@cwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper<AppNavigator>(
      segment: segment,
      title: 'Home',
      buildChildren: (navigator) => [
        ElevatedButton(
          onPressed: () => navigator.navigate([
            HomeSegment(),
            PageSegment(title: 'Page1'),
            PageSegment(title: 'Page2'),
            PageSegment(title: 'Page3'),
          ]),
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
