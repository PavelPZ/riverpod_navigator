part of 'index.dart';

class RiverpodNavigatorFlutter {
  RiverpodNavigatorFlutter({
    this.screenBuilder,
    this.screen2Page,
    this.navigatorWidgetBuilder,
    this.splashBuilder,
    RRouter? router,
  })  : assert((screenBuilder == null) != (router == null), 'screenBuilder or router required, but not both'),
        assert(router == null || screen2Page == null, 'screen2Page is ignored when a router is provided') {
    if (router != null) {
      screenBuilder = router.screenBuilder();
      screen2Page = router.screen2Page();
    } else
      screen2Page ??= screen2PageDefault;
  }
  Screen2Page? screen2Page;
  ScreenBuilder? screenBuilder;
  final NavigatorWidgetBuilder? navigatorWidgetBuilder;
  final SplashBuilder? splashBuilder;
}
