import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../appDart/appDart.dart';
import '../packageDart.dart';
import '../packageFlutter.dart';

// flutter pub run build_runner watch
part 'appFlutter.g.dart';

/// Flutter app root
///
/// The weakest part of the example code is relation between [RiverpodNavigator] <=> [TypedPathNotifier]<=> [RiverpodRouterDelegate] <=> [ExampleApp]
// TODO(PZ): check first four lines of exampleApp code
@hcwidget
Widget exampleApp(WidgetRef ref) {
  final navigator = ref.read(exampleRiverpodNavigatorProvider);
  // RouterDelegate reguired by [MaterialApp.router]
  final delegate = RiverpodRouterDelegate(navigator, pageBuilder: _pageBuilder, initPath: [HomeSegment()]);
  // changing TypedPath => calling RiverpodRouterDelegate.notifyListeners => Flutter Navigation 2.0 rebuilds navigation stack
  ref.listen(typedPathNotifierProvider, (_, __) => delegate.notifyListeners());
  return MaterialApp.router(
    title: 'Books App',
    routerDelegate: delegate,
    routeInformationParser: RouteInformationParserImpl((jsonMap) => ExampleSegments.fromJson(jsonMap)),
  );
}

/// Which widget will be builded for which typed segment
Widget _pageBuilder(TypedSegment segment) => (segment as ExampleSegments).map(
      home: (homeSegment) => HomePage(homeSegment),
      books: (booksSegment) => BooksPage(booksSegment),
      book: (bookSegment) => BookPage(bookSegment),
    );

@hcwidget
Widget homePage(WidgetRef ref, HomeSegment segment) => PageHelper(
      title: 'Home Page',
      buildChildren: (_) => [
        LinkHelper(title: 'Books Page', onPressed: ref.read(exampleRiverpodNavigatorProvider).toBooks),
      ],
    );

@hcwidget
Widget booksPage(WidgetRef ref, BooksSegment segment) => PageHelper(
      title: 'Books Page',
      buildChildren: (_) => [
        for (var id = 0; id < booksLen; id++)
          LinkHelper(title: 'Book, id=$id', onPressed: () => ref.read(exampleRiverpodNavigatorProvider).toBook(id: id))
      ],
    );

@hcwidget
Widget bookPage(WidgetRef ref, BookSegment segment) => PageHelper(
      title: 'Book Page, id=${segment.id}',
      buildChildren: (_) => [
        LinkHelper(title: 'Next >>', onPressed: ref.read(exampleRiverpodNavigatorProvider).bookNextPrevButton),
        LinkHelper(title: '<< Prev', onPressed: () => ref.read(exampleRiverpodNavigatorProvider).bookNextPrevButton(isPrev: true)),
      ],
    );

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(
      onPressed: onPressed,
      child: Text(title),
    );

@hcwidget
Widget pageHelper(WidgetRef ref, {required String title, required List<Widget> buildChildren(ExampleRiverpodNavigator navigator)}) {
  final navigator = ref.read(exampleRiverpodNavigatorProvider);
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildChildren(navigator).map((e) => [SizedBox(height: 20), e]).expand((e) => e).toList(),
      ),
    ),
  );
}
