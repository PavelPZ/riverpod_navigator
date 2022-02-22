import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'navigator.dart';
import 'pathParser.dart';

// flutter pub run build_runner watch
part 'widgets.g.dart';

/// Note: *To make it less verbose, we use the functional_widget package to generate widgets.
/// See generated "widgets.g.dart"" file for details.*

/// Flutter app root
@hcwidget
Widget appRoot(WidgetRef ref) => MaterialApp.router(
      title: 'Riverpod, freezed and Navigator 2.0 example',
      routerDelegate: ref.watch(navigatorProvider).routerDelegate,
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
        final isLogged = ref.read(userIsLoggedProvider);
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
        LinkHelper(title: 'Next >>', onPressed: navigator.toBookNextPrev),
        LinkHelper(title: '<< Prev', onPressed: () => navigator.toBookNextPrev(isPrev: true)),
      ],
    );

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(
      onPressed: onPressed,
      child: Text(title),
    );

@cwidget
Widget pageHelper(WidgetRef ref, {required String title, required List<Widget> buildChildren(AppNavigator navigator)}) {
  final navigator = ref.read(navigatorProvider);
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
        Consumer(builder: (_, ref, __) {
          final isLogged = ref.watch(userIsLoggedProvider);
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

class A {
  A(this.x);
  final Object? x;
}

class B extends A {
  B(B x) : super(x);
  @override
  B? get x => super.x as B;
}
