import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'navigator.dart';
import 'pathParser.dart';

// flutter pub run build_runner watch
part 'widgets.g.dart';

/// Flutter app root
@hcwidget
Widget appRoot(WidgetRef ref) => MaterialApp.router(
      title: 'Riverpod, freezed and Navigator 2.0 example',
      routerDelegate: ref.watch(riverpodNavigatorProvider).routerDelegate,
      routeInformationParser: RouteInformationParserImpl(),
      debugShowCheckedModeBanner: false,
    );

@hcwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper(
      title: 'Home Screen',
      buildChildren: (navigator) => [
        LinkHelper(title: 'Books Page', onPressed: navigator.toBooks),
      ],
    );

@hcwidget
Widget booksScreen(WidgetRef ref, BooksSegment segment) => PageHelper(
      title: 'Books Screen',
      buildChildren: (navigator) {
        final isLogged = ref.read(navigationStateProvider).userIsLogged;
        return [
          for (var id = 0; id < booksLen; id++) ...[
            LinkHelper(title: 'Book screen, id=$id${!isLogged && id.isOdd ? ' (log in first)' : ''}', onPressed: () => navigator.toBook(id: id))
          ],
        ];
      },
    );

@hcwidget
Widget bookScreen(WidgetRef ref, BookSegment segment) => PageHelper(
      title: 'Book screen, id=${segment.id}',
      buildChildren: (navigator) => [
        LinkHelper(title: 'Next >>', onPressed: navigator.bookNextPrevButton),
        LinkHelper(title: '<< Prev', onPressed: () => navigator.bookNextPrevButton(isPrev: true)),
      ],
    );

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(
      onPressed: onPressed,
      child: Text(title),
    );

@cwidget
Widget pageHelper(WidgetRef ref, {required String title, required List<Widget> buildChildren(RiverpodNavigator navigator)}) {
  final navigator = ref.read(riverpodNavigatorProvider);
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
        Consumer(builder: (_, ref, __) {
          final isLogged = ref.watch(navigationStateProvider.notifier.select((value) => value.state.userIsLogged));
          return ElevatedButton(
            onPressed: navigator.toogleLogin,
            child: Text(isLogged ? 'Logout' : 'Login'),
          );
        }),
      ],
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildChildren(navigator).map((e) => [SizedBox(height: 20), e]).expand((e) => e).toList(),
      ),
    ),
  );
}
