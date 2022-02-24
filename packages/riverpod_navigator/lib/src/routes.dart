part of 'index.dart';

class RRoute<T extends TypedSegment> extends RRoute4Dart<T> {
  RRoute(
    FromUrlPars<T> fromUrlPars,
    this.screenBuilder, {
    this.screen2Page,
    Opening<T>? opening,
    Replacing<T>? replacing,
    Closing<T>? closing,
    String? segmentTypeName,
  }) : super(fromUrlPars, opening: opening, replacing: replacing, closing: closing, segmentTypeName: segmentTypeName);

  ScreenBuilder<T> screenBuilder;
  Screen2Page<T>? screen2Page;
  Widget buildScreen(TypedSegment segment) => screenBuilder(segment as T);
}
