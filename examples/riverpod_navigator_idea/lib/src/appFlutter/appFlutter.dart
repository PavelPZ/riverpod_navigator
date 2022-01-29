import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator_idea/src/riverpod_navigator.dart';

import '../appDart/appDart.dart';

// flutter pub run build_runner watch
part 'appFlutter.g.dart';

/// Provider with Flutter 2.0 RouterDelegate
final appRouterDelegateProvider =
    Provider<RiverpodRouterDelegate>((ref) => RiverpodRouterDelegate(ref, ref.watch(configProvider), ref.watch(exampleRiverpodNavigatorProvider)));

Config configCreator(Config4Dart config4Dart) =>
    // configure engine
    Config(
      /// Which widget will be builded for which typed segment
      ///
      /// used in [RiverpodRouterDelegate] to build pages from [TypedSegment]'s
      screenBuilder: (segment) => (segment as ExampleSegments).map(
        home: (homeSegment) => HomeScreen(homeSegment),
        books: (booksSegment) => BooksScreen(booksSegment),
        book: (bookSegment) => BookScreen(bookSegment),
      ),
      config4Dart: config4Dart,
    );

/// Flutter app root
@hcwidget
Widget exampleApp(WidgetRef ref) => MaterialApp.router(
      title: 'Books App',
      routerDelegate: ref.watch(appRouterDelegateProvider),
      routeInformationParser: RouteInformationParserImpl(ref.watch(config4DartProvider)),
      debugShowCheckedModeBanner: false,
    );

@hcwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper(
      title: 'Home Page',
      buildChildren: (_) => [
        LinkHelper(title: 'Books Page', onPressed: ref.read(exampleRiverpodNavigatorProvider).toBooks),
      ],
    );

@hcwidget
Widget booksScreen(WidgetRef ref, BooksSegment segment) => PageHelper(
      title: 'Books Page',
      buildChildren: (_) => [
        for (var id = 0; id < booksLen; id++)
          LinkHelper(title: 'Book, id=$id', onPressed: () => ref.read(exampleRiverpodNavigatorProvider).toBook(id: id))
      ],
    );

@hcwidget
Widget bookScreen(WidgetRef ref, BookSegment segment) => PageHelper(
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
        children: (() {
          final res = <Widget>[SizedBox(height: 20)];
          for (final w in buildChildren(navigator)) res.addAll([w, SizedBox(height: 20)]);
          res.add(CountBuilds());
          return res;
        })(),
      ),
    ),
  );
}

@hcwidget
Widget countBuilds() {
  final count = useState(0);
  count.value++;
  return Text('Builded ${count.value} times.');
}
