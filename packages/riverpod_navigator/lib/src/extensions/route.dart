import 'package:flutter/material.dart';
import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

abstract class NavigRoute<T extends TypedSegment> extends Route4Dart<T> {
  Widget buildPage(T segment);
}
