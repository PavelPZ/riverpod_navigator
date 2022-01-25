import 'package:flutter/widgets.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

import '../routerDelegate.dart';
import 'extensions.dart';

export 'screenWrappers.dart';

typedef Screen2Page = Page Function(TypedSegment segment, ScreenBuilder screenBuilder);

class Config extends Config4Dart {
  Config({
    required this.screenBuilder,
    Screen2Page? screen2Page,
    required this.initPath,
    this.navigatorWidgetBuilder,
    // extensions for Dart:
    required Json2Segment json2Segment,
    PathParser? pathParser,
    Segment2AsyncScreenActions? segment2AsyncScreenActions,
  })  : screen2Page = screen2Page ?? screen2PageDefault,
        super(
          json2Segment: json2Segment,
          pathParser: pathParser,
          segment2AsyncScreenActions: segment2AsyncScreenActions,
        );
  final Screen2Page screen2Page;
  final ScreenBuilder screenBuilder;
  final TypedPath initPath;
  final NavigatorWidgetBuilder? navigatorWidgetBuilder;
}

Config get config => config4Dart as Config;
