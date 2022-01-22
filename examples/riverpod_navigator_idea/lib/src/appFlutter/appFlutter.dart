import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../appDart/appDart.dart';
import '../packageDart.dart';
import '../packageFlutter.dart';

// flutter pub run build_runner watch
part 'appFlutter.g.dart';

/// which widget will be builded for which url segment
Widget pageBuilder(TypedSegment segment) => (segment as ExampleSegments).map(
      home: (homeSegment) => HomePage(homeSegment),
      books: (booksSegment) => BooksPage(booksSegment),
      book: (bookSegment) => BookPage(bookSegment),
    );

/// Flutter app root
@hcwidget
Widget exampleApp(WidgetRef ref) {
  final navigator = ref.read(exampleRiverpodNavigatorProvider);
  final delegate = RiverpodRouterDelegate(navigator, pageBuilder: pageBuilder, initPath: [HomeSegment()]);
  return MaterialApp.router(
    title: 'Books App',
    routerDelegate: delegate,
    routeInformationParser: RouteInformationParserImpl((jsonMap) => ExampleSegments.fromJson(jsonMap)),
  );
}

@hcwidget
Widget homePage(WidgetRef ref, HomeSegment segment) => PageHelper(
      title: 'Home Page',
      children: (_) => [
        linkHelper(title: 'Books Page', onPressed: ref.read(exampleRiverpodNavigatorProvider).toBooks),
      ],
    );

@hcwidget
Widget booksPage(WidgetRef ref, BooksSegment segment) => PageHelper(
      title: 'Books Page',
      children: (_) => [
        for (var id = 0; id < booksLen; id++)
          linkHelper(title: 'Book, id=$id', onPressed: () => ref.read(exampleRiverpodNavigatorProvider).toBook(id: id))
      ],
    );

@hcwidget
Widget bookPage(WidgetRef ref, BookSegment segment) => PageHelper(
      title: 'Book Page, id=${segment.id}',
      children: (_) => [
        linkHelper(title: 'Next >>', onPressed: ref.read(exampleRiverpodNavigatorProvider).bookNextPrevButton),
        linkHelper(title: '<< Prev', onPressed: () => ref.read(exampleRiverpodNavigatorProvider).bookNextPrevButton(isPrev: true)),
      ],
    );

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(
      onPressed: onPressed,
      child: Text(title),
    );

@hcwidget
Widget pageHelper(WidgetRef ref, {required String title, required List<Widget> children(ExampleRiverpodNavigator navigator), bool? isLoginPage}) {
  final navigator = ref.read(exampleRiverpodNavigatorProvider);
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children(navigator).map((e) => [e, SizedBox(height: 20)]).expand((e) => e).toList(),
      ),
    ),
  );
}
