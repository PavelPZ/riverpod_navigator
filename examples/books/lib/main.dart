import 'package:books/books.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() {
  Config(
    screenBuilder: screenBuilder,
    navigatorWidgetBuilder: null,
    screen2Page: null,
    initPath: [HomeSegment()],
    // 4Dart:
    pathParser: SimplePathParser(),
    json2Segment: json2Segment,
    segment2AsyncScreenActions: segment2AsyncScreenActions,
  );

  runApp(ProviderScope(child: const BooksExampleApp()));
}
