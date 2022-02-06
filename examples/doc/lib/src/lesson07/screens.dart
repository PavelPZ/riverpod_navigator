import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'lesson07.dart';

part 'screens.g.dart';

final ScreenBuilder appSegmentsScreenBuilder = (segment) => (segment as AppSegments).map(
      home: HomeScreen.new,
      books: BooksScreen.new,
      book: BookScreen.new,
    );

// ************************************
// Using "functional_widget" package to be less verbose.
// ************************************

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(onPressed: onPressed, child: Text(title));

@swidget
Widget splashScreen() =>
    SizedBox.expand(child: Container(color: Colors.white, child: Center(child: Icon(Icons.circle_outlined, size: 150, color: Colors.deepPurple))));

@hwidget
Widget countBuilds() {
  final count = useState(0);
  count.value++;
  return Text('Builded ${count.value} times.');
}

@swidget
Widget homeScreen(HomeSegment segment) => PageHelper(
      title: 'Home Screen',
      asyncActionResult: segment.asyncActionResult,
      buildChildren: (navigator) => [
        LinkHelper(title: 'Books Page', onPressed: navigator.toBooks),
      ],
    );

@swidget
Widget booksScreen(BooksSegment segment) => PageHelper(
      title: 'Books Screen',
      asyncActionResult: segment.asyncActionResult,
      buildChildren: (navigator) =>
          [for (var id = 0; id < booksLen; id++) LinkHelper(title: 'Book Screen, id=$id', onPressed: () => navigator.toBook(id: id))],
    );

@swidget
Widget bookScreen(BookSegment segment) => PageHelper(
      title: 'Book Screen, id=${segment.id}',
      asyncActionResult: segment.asyncActionResult,
      buildChildren: (navigator) => [
        LinkHelper(title: 'Next >>', onPressed: navigator.bookNextPrevButton),
        LinkHelper(title: '<< Prev', onPressed: () => navigator.bookNextPrevButton(isPrev: true)),
      ],
    );

@cwidget
Widget pageHelper(WidgetRef ref, {required String title, required List<Widget> buildChildren(AppNavigator navigator), dynamic asyncActionResult}) {
  final navigator = ref.read(riverpodNavigatorProvider) as AppNavigator;
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
    ),
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: (() {
          final res = <Widget>[SizedBox(height: 20)];
          for (final w in buildChildren(navigator)) res.addAll([w, SizedBox(height: 20)]);
          if (asyncActionResult!=null) res.addAll([Text(asyncActionResult.toString()), SizedBox(height: 20)]);
          res.add(CountBuilds());
          return res;
        })(),
      ),
    ),
  );
}

