part of 'index.dart';

final Screen2Page screen2PageDefault = (segment, screenBuilder) => _Screen2PageDefault(segment, screenBuilder);
final Screen2Page screen2PageRebuild = (segment, screenBuilder) => _Screen2PageRebuild(segment, screenBuilder);
final Screen2Page screen2PageSimple =
    (segment, screenBuilder) => MaterialPage(key: ValueKey(segment.toString()), child: screenBuilder(segment));

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

class ScreenRoot<N extends RNavigator> extends ConsumerWidget {
  const ScreenRoot({Key? key, required this.buildScreen}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.read(navigatorProvider) as N;
    final canPop = navigator.getNavigationStack().length > 1;
    final appBarLeading = !canPop
        ? null
        : IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => navigator.onPopRoute(),
          );
    // https://stackoverflow.com/a/45918186
    return WillPopScope(
      onWillPop: () async => !canPop,
      child: buildScreen(navigator, appBarLeading),
    );
  }

  final Widget Function(N navigator, IconButton? appBarLeading) buildScreen;
}
