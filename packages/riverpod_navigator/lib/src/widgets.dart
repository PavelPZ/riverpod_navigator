part of 'index.dart';

final Screen2Page screen2PageDefault =
    (segment, screenBuilder) => _Screen2PageDefault(segment, screenBuilder);
final Screen2Page screen2PageRebuild =
    (segment, screenBuilder) => _Screen2PageRebuild(segment, screenBuilder);
final Screen2Page screen2PageSimple = (segment, screenBuilder) =>
    MaterialPage(key: ObjectKey(segment), child: screenBuilder(segment));

class _Screen2PageRebuild extends Page {
  _Screen2PageRebuild(this._typedSegment, this._screenBuilder)
      : super(key: ObjectKey(_typedSegment));

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

class _Screen2PageDefault extends Page {
  _Screen2PageDefault(this._typedSegment, this._screenBuilder)
      : super(key: ObjectKey(_typedSegment));

  final TypedSegment _typedSegment;
  final ScreenBuilder _screenBuilder;

  @override
  Route createRoute(BuildContext context) {
    // https://github.com/flutter/flutter/issues/11655#issuecomment-469221502
    final child = _screenBuilder(_typedSegment);
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) => child,
    );
  }
}

class BackButtonHandler extends ConsumerWidget {
  const BackButtonHandler({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BackButtonDispatcher? rootBackDispatcher =
        Router.of(context).backButtonDispatcher;
    if (rootBackDispatcher == null) return child;
    return BackButtonListener(
      onBackButtonPressed: () async =>
          ref.read(navigationStackProvider).length > 1,
      child: child,
    );
  }
}

mixin BackButtonListenerMixin<N extends RNavigator> on ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.read(navigatorProvider) as N;

    final appBarLeading = Router.of(context).backButtonDispatcher != null &&
            navigator.getNavigationStack().length > 1
        ? buildIcon(navigator.onPopRoute)
        : null;

    return buildScreen(context, ref, navigator, appBarLeading);

    // // fix for nested navigator where rootBackDispatcher is null
    // final BackButtonDispatcher? rootBackDispatcher = Router.of(context).backButtonDispatcher;
    // if (rootBackDispatcher == null) {
    //   return buildScreen(context, ref, navigator, null);
    // }

    // final canPop = navigator.getNavigationStack().length > 1;
    // final appBarLeading = canPop ? buildIcon(navigator.onPopRoute) : null;
    // return BackButtonListener(
    //   onBackButtonPressed: () async => canPop,
    //   child: buildScreen(context, ref, navigator, appBarLeading),
    // );
  }

  IconButton buildIcon(void onPressed()) =>
      IconButton(icon: Icon(Icons.arrow_back), onPressed: onPressed);

  Widget buildScreen(BuildContext context, WidgetRef ref, N navigator,
      IconButton? appBarLeading);
}

abstract class RScreen<N extends RNavigator, S extends TypedSegment>
    extends ConsumerWidget with BackButtonListenerMixin<N> {
  const RScreen(this.segment) : super();
  final S segment;
}

abstract class RScreenHook<N extends RNavigator, S extends TypedSegment>
    extends HookConsumerWidget with BackButtonListenerMixin<N> {
  const RScreenHook(this.segment) : super();
  final S segment;
}

abstract class RScreenWithScaffold<N extends RNavigator, S extends TypedSegment>
    extends RScreen<N, S> {
  const RScreenWithScaffold(S segment) : super(segment);

  @override
  Widget buildScreen(BuildContext context, ref, navigator, appBarLeading) =>
      Scaffold(
        appBar: AppBar(
          title: Text(navigator.screenTitle(segment)),
          leading: appBarLeading,
        ),
        body: buildBody(ref, navigator),
      );

  Widget buildBody(WidgetRef ref, N navigator);
}

/// when async navigation is computed:
/// 1. AbsorbPointer for screen
/// 2. when computation is longer than 250msec, display CircularProgressIndicator
class NavigatorWrapper extends ConsumerWidget {
  const NavigatorWrapper(this.navigator, this.navigatorWidget);

  final Navigator navigatorWidget;
  final RNavigator navigator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNavigating = ref.watch(isNavigatingProvider) > 0;

    return Stack(children: [
      SizedBox.expand(
          child:
              AbsorbPointer(child: navigatorWidget, absorbing: isNavigating)),
      if (isNavigating)
        FutureBuilder(
          future: Future.delayed(Duration(milliseconds: 250)),
          builder: (_, snapshot) => SizedBox.expand(
            child: snapshot.connectionState == ConnectionState.waiting
                ? SizedBox()
                : Center(child: navigator.progressIndicatorBuilder()),
          ),
        ),
    ]);
  }
}

/// splash screen is visible before home screen is displayed
class SplashScreen extends StatelessWidget {
  const SplashScreen(this.navigator);
  final RNavigator navigator;
  @override
  Widget build(context) => SizedBox.expand(
        child: Container(
          color: Colors.white,
          child: Center(child: navigator.progressIndicatorBuilder()),
        ),
      );
}

/// RLinkButton navigation button
abstract class RLinkButton extends StatelessWidget {
  const RLinkButton(this.navigatePath);
  final NavigatePath navigatePath;
  @override
  Widget build(BuildContext context) =>
      buildButton(navigatePath.onPressed, navigatePath.title);

  Widget buildButton(VoidCallback onPressed, String screenTitle);
}
