import 'package:books/books.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() {
  Extensions(
    screenBuilder: screenBuilder,
    navigatorWidgetBuilder: null,
    screen2Page: null,
    initPath: [HomeSegment()],
    // 4Dart:
    pathParser: SimplePathParser(),
    json2Segment: json2Segment,
  );

  runApp(ProviderScope(child: const BooksExampleApp()));
}
