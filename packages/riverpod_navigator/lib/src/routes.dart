part of 'index.dart';

class RRoute<T extends TypedSegment> extends RRoute4Dart<T> {
  RRoute(
    FromSegmentMap<T>? fromSegmentMap,
    this.screenBuilder, {
    this.screen2Page,
    Opening<T>? opening,
    Replacing<T>? replacing,
    Closing<T>? closing,
    String? type,
  }) : super(fromSegmentMap, opening: opening, replacing: replacing, closing: closing, type: type);

  RRoute.noWeb(
    this.screenBuilder, {
    this.screen2Page,
    Opening<T>? opening,
    Replacing<T>? replacing,
    Closing<T>? closing,
  }) : super.noWeb(opening: opening, replacing: replacing, closing: closing);
  ScreenBuilder<T> screenBuilder;
  Screen2Page<T>? screen2Page;
  Widget buildScreen(TypedSegment segment) => screenBuilder(segment as T);
}
