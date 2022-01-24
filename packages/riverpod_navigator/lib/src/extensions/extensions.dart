import 'package:flutter/widgets.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'screenWrappers.dart';

typedef Screen2Page = Page Function(TypedSegment segment, ScreenBuilder screenBuilder);

class Extensions extends Extensions4Dart {
  Extensions({
    required this.screenBuilder,
    Screen2Page? screen2Page,
    required this.initPath,
    this.navigatorWidgetBuilder,
    // for Dart extensions:
    required Json2Segment json2Segment,
    PathParser? pathParser,
  })  : screen2Page = screen2Page ?? screen2PageDefault,
        super(
          json2Segment: json2Segment,
          pathParser: pathParser,
        );
  final Screen2Page screen2Page;
  final ScreenBuilder screenBuilder;
  final TypedPath initPath;
  final NavigatorWidgetBuilder? navigatorWidgetBuilder;

  static Extensions get value => Extensions4Dart.value as Extensions;
}
