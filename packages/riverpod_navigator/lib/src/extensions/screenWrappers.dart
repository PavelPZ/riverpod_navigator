import 'package:flutter/material.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

import '../riverpod_navigator.dart';

final Screen2Page screen2PageRebuild = (segment, screenBuilder) => _Screen2PageRebuild(segment, screenBuilder);
final Screen2Page screen2PageSimple = (segment, screenBuilder) => MaterialPage(child: screenBuilder(segment));

class _Screen2PageRebuild extends Page {
  _Screen2PageRebuild(this._typedSegment, this._screenBuilder) : super(key: ValueKey(_typedSegment.toString()));

  final TypedSegment _typedSegment;
  final ScreenBuilder _screenBuilder;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => _screenBuilder(_typedSegment),
    );
  }
}
