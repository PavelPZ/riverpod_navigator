import 'package:books_dart/books_dart.dart';
import 'package:riverpod/riverpod.dart';

import 'route.dart';

final appNavigatorProvider = Provider<AppNavigator>((ref) => AppNavigator(ref, appRouteWithSegment));
