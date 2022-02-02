import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'riverpod_navigator_dart.dart';

typedef NavigatorWidgetBuilder = Widget Function(BuildContext, Navigator);
typedef ScreenBuilder = Widget Function(TypedSegment segment);
typedef SplashBuilder = Widget Function();

final riverpodRouterDelegate = Provider<RiverpodRouterDelegate>((_) => throw UnimplementedError());

class RiverpodRouterDelegate extends RouterDelegate<TypedPath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<TypedPath>, IRouterDelegate {
  RiverpodRouterDelegate(Ref ref)
      : _config = ref.read(configProvider),
        _navigator = ref.watch(riverpodNavigatorProvider);

  final RiverpodNavigator _navigator;
  final Config _config;

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // final actPath = _navigator.getActualTypedPath();
    final actPath = currentConfiguration;
    if (actPath.isEmpty) return _config.splashBuilder?.call() ?? SizedBox();
    final navigatorWidget = Navigator(
        key: navigatorKey,
        // segment => screen
        pages: actPath.map((segment) => _config.screen2Page(segment, _config.screenBuilder)).toList(),
        onPopPage: (route, result) {
          //if (!route.didPop(result)) return false;
          // remove last segment from path
          _navigator.onPopRoute();
          return false;
        });
    return _config.navigatorWidgetBuilder == null ? navigatorWidget : _config.navigatorWidgetBuilder!(context, navigatorWidget);
  }

  @override
  Future<void> setNewRoutePath(TypedPath configuration) => _navigator.navigate(configuration);

  @override
  Future<void> setInitialRoutePath(TypedPath configuration) => _navigator.navigate(_config.config4Dart.initPath);
}

class RouteInformationParserImpl implements RouteInformationParser<TypedPath> {
  RouteInformationParserImpl(WidgetRef ref) : _config = ref.read(config4DartProvider);

  final Config4Dart _config;

  @override
  Future<TypedPath> parseRouteInformation(RouteInformation routeInformation) =>
      Future.value(_config.pathParser.path2TypedPath(routeInformation.location));

  @override
  RouteInformation restoreRouteInformation(TypedPath configuration) => RouteInformation(location: _config.pathParser.typedPath2Path(configuration));
}

typedef Screen2Page = Page Function(TypedSegment segment, ScreenBuilder screenBuilder);

class Config {
  Config({
    required this.screenBuilder,
    Screen2Page? screen2Page,
    this.navigatorWidgetBuilder,
    required this.config4Dart,
    this.splashBuilder,
  }) : screen2Page = screen2Page ?? screen2PageDefault {
    config4Dart.routerDelegateCreator = (ref) => RiverpodRouterDelegate(ref);
  }
  final Screen2Page screen2Page;
  final ScreenBuilder screenBuilder;
  final NavigatorWidgetBuilder? navigatorWidgetBuilder;
  final SplashBuilder? splashBuilder;

  /// dart-only part of config
  final Config4Dart config4Dart;
}

final configProvider = Provider<Config>((_) => throw UnimplementedError());

final Screen2Page screen2PageDefault = (segment, screenBuilder) => _Screen2PageDefault(segment, screenBuilder);

class _Screen2PageDefault extends Page {
  _Screen2PageDefault(this._typedSegment, this._screenBuilder) : super(key: ValueKey(_typedSegment.asJson));

  final TypedSegment _typedSegment;
  final ScreenBuilder _screenBuilder;

  @override
  Route createRoute(BuildContext context) {
    // this line solved https://github.com/PavelPZ/riverpod_navigator/issues/2
    // https://github.com/flutter/flutter/issues/11655#issuecomment-469221502
    final child = _screenBuilder(_typedSegment);
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => child,
    );
  }
}
