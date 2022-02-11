part of 'index.dart';

final Screen2Page screen2PageDefault = (segment, screenBuilder) => _Screen2PageDefault(segment, screenBuilder);
final Screen2Page screen2PageRebuild = (segment, screenBuilder) => _Screen2PageRebuild(segment, screenBuilder);
final Screen2Page screen2PageSimple = (segment, screenBuilder) => MaterialPage(child: screenBuilder(segment));

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
  _Screen2PageDefault(this._typedSegment, this._screenBuilder) : super(key: ValueKey(_typedSegment.toString()));

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
