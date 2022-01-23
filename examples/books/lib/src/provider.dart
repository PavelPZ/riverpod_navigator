import 'package:books_dart/books_dart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'route.dart';

final appNavigatorProvider = Provider<AppNavigator>((ref) => AppNavigator(ref, appRouteWithSegment, SimplePathParser(json2Segment)));
