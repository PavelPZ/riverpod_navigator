import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'lesson031.dart';

// flutter pub run build_runner watch
part 'screens.g.dart';

@cwidget
Widget homeScreen(WidgetRef ref, HomeSegment segment) => PageHelper(
      title: 'Home Page',
      segment: segment,
      buildChildren: () => [
        LinkHelper(title: 'Books Page', onPressed: ref.readNavigator().toBooks),
      ],
    );

@cwidget
Widget booksScreen(WidgetRef ref, BooksSegment segment) => PageHelper(
      title: 'Books Page',
      segment: segment,
      buildChildren: () =>
          [for (var id = 0; id < booksLen; id++) LinkHelper(title: 'Book, id=$id', onPressed: () => ref.readNavigator().toBook(id: id))],
    );

@cwidget
Widget bookScreen(WidgetRef ref, BookSegment segment) => PageHelper(
      title: 'Book Page, id=${segment.id}',
      segment: segment,
      buildChildren: () => [
        LinkHelper(title: 'Next >>', onPressed: ref.readNavigator().bookNextPrevButton),
        LinkHelper(title: '<< Prev', onPressed: () => ref.readNavigator().bookNextPrevButton(isPrev: true)),
      ],
    );

@cwidget
Widget splashScreen(WidgetRef ref, SplashSegment segment) =>
    SizedBox.expand(child: Container(color: Colors.white, child: Center(child: Icon(Icons.circle_outlined, size: 150, color: Colors.deepPurple))));

@swidget
Widget linkHelper({required String title, VoidCallback? onPressed}) => ElevatedButton(onPressed: onPressed, child: Text(title));

@swidget
Widget asyncResult({required dynamic title}) => title == null || title is! String || title.isEmpty ? SizedBox() : Text(title);

@swidget
Widget pageHelper({required String title, required TypedSegment segment, required List<Widget> buildChildren()}) => Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: (() {
            final res = <Widget>[SizedBox(height: 20)];
            for (final w in buildChildren()) res.addAll([w, SizedBox(height: 20)]);
            if (segment.asyncActionResult != null && segment.asyncActionResult is String && segment.asyncActionResult.isNotEmpty)
              res.add(Text(segment.asyncActionResult));
            return res;
          })(),
        ),
      ),
    );
