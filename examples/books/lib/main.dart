import 'package:books/books.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

void main() {
  // init engine
  Config(
    screenBuilder: screenBuilder,
    navigatorWidgetBuilder: null,
    screen2Page: null,
    initPath: [HomeSegment()],
    // 4Dart:
    pathParser: SimplePathParser(),
    json2Segment: json2Segment,
    segment2AsyncScreenActions: segment2AsyncScreenActions,
    // when using route
    // segment2AsyncScreenActions: segment2AsyncScreenActions4Routes,
  );
  // init app
  // when using route
  // needsLoginProc4Dart = getNeedsLogin4Routes4Dart;

  runApp(ProviderScope(child: const BooksExampleApp()));
}
