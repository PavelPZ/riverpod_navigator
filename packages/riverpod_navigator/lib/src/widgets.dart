part of 'index.dart';

final Screen2Page screen2PageDefault = (segment, screenBuilder) => _Screen2PageDefault(segment, screenBuilder);
final Screen2Page screen2PageRebuild = (segment, screenBuilder) => _Screen2PageRebuild(segment, screenBuilder);
final Screen2Page screen2PageSimple = (segment, screenBuilder) => MaterialPage(key: ObjectKey(segment), child: screenBuilder(segment));

class _Screen2PageRebuild extends Page {
  _Screen2PageRebuild(this._typedSegment, this._screenBuilder) : super(key: ObjectKey(_typedSegment));

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
  _Screen2PageDefault(this._typedSegment, this._screenBuilder) : super(key: ObjectKey(_typedSegment));

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

mixin BackButtonListenerMixin<N extends RNavigator> on Widget {
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.read(navigatorProvider) as N;

    final BackButtonDispatcher? rootBackDispatcher = Router.of(context).backButtonDispatcher;
    if (rootBackDispatcher == null) return buildScreen(ref, navigator, null);

    final canPop = navigator.getNavigationStack().length > 1;
    final appBarLeading = !canPop
        ? null
        : IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => navigator.onPopRoute(),
          );
    return BackButtonListener(
      onBackButtonPressed: () async => canPop,
      child: buildScreen(ref, navigator, appBarLeading),
    );
    // // https://stackoverflow.com/a/45918186
    // return WillPopScope(
    //   onWillPop: () async => !canPop,
    //   child: buildScreen(ref, navigator, appBarLeading),
    // );
  }

  Widget buildScreen(WidgetRef ref, N navigator, IconButton? appBarLeading);
}

abstract class RScreen<N extends RNavigator, S extends TypedSegment> extends ConsumerWidget with BackButtonListenerMixin<N> {
  const RScreen(this.segment) : super();
  final S segment;
}

abstract class RScreenHook<N extends RNavigator, S extends TypedSegment> extends HookConsumerWidget with BackButtonListenerMixin<N> {
  const RScreenHook(this.segment) : super();
  final S segment;
}

abstract class RScreenWithScaffold<N extends RNavigator, S extends TypedSegment> extends RScreen<N, S> {
  const RScreenWithScaffold(S segment) : super(segment);

  @override
  Widget buildScreen(ref, navigator, appBarLeading) => Scaffold(
        appBar: AppBar(
          title: Text(navigator.screenTitle(segment)),
          leading: appBarLeading,
        ),
        body: buildBody(ref, navigator),
      );

  Widget buildBody(WidgetRef ref, N navigator);
}
