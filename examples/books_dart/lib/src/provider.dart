import 'package:riverpod/riverpod.dart';

import 'navigator.dart';
import 'route.dart';

final userIsLoggedProvider = StateProvider<bool>((_) => false);

final appNavigatorProvider4Model = Provider<AppNavigator>((ref) => AppNavigator(ref, appRouteWithSegment4Model));
