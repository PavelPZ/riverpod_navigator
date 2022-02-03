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
      title: 'Books App',
      routerDelegate: ref.watch(riverpodNavigatorProvider).routerDelegate,
      routeInformationParser: RouteInformationParserImpl(),
      debugShowCheckedModeBanner: false,
    );

@hcwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper(
      title: 'Home Page',
      buildChildren: (navigator) => [
        LinkHelper(title: 'Books Page', onPressed: navigator.toBooks),
      ],
    );

@hcwidget
Widget booksScreen(WidgetRef ref, BooksSegment segment) => PageHelper(
      title: 'Books Page',
      buildChildren: (navigator) =>
          [for (var id = 0; id < booksLen; id++) LinkHelper(title: 'Book, id=$id', onPressed: () => navigator.toBook(id: id))],
    );

@hcwidget
Widget bookScreen(WidgetRef ref, BookSegment segment) => PageHelper(
      title: 'Book Page, id=${segment.id}',
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
          final isLogged = ref.watch(isLoggedProvider);
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
        children: buildChildren(navigator).map((e) => [e, SizedBox(height: 20)]).expand((e) => e).toList(),
      ),
    ),
  );
}
