import 'package:books_dart/books_dart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'pages.dart';
import 'route.dart';

List<Override> configureApp({required bool withRoutes}) {
  final config = Config(
    screenBuilder: withRoutes == true ? screenBuilder4Routes : screenBuilder,
    navigatorWidgetBuilder: null,
    screen2Page: null,
    initPath: [HomeSegment()],
  );
  final config4Dart = Config4Dart(
    pathParser: SimplePathParser(),
    json2Segment: json2Segment,
    segment2AsyncScreenActions: withRoutes == true ? segment2AsyncScreenActions4Routes : segment2AsyncScreenActions,
  );
  return [
    config4DartProvider.overrideWithValue(config4Dart),
    configProvider.overrideWithValue(config),
    appConfig4DartProvider.overrideWithValue(
      AppConfig4Dart(needsLogin4Dart: withRoutes == true ? getNeedsLogin4Routes4Dart : getNeedsLogin4Dart),
    )
  ];
}

final appNavigatorProvider = Provider<AppNavigator>((ref) {
  final cfg4Dart = ref.watch(config4DartProvider);
  return AppNavigator(ref, cfg4Dart);
});

final appRouterDelegateProvider = Provider<RiverpodRouterDelegate>((ref) {
  final cfg = ref.watch(configProvider);
  final navigator = ref.watch(appNavigatorProvider);
  return RiverpodRouterDelegate(ref, cfg, navigator);
});
