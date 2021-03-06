part of 'index.dart';

class RRoute<T extends TypedSegment> extends RRouteCore<T> {
  RRoute(
    String urlName,
    FromUrlPars<T> decode,
    this.screenBuilder, {
    this.screen2Page,
    String Function(T segment)? screenTitle,
    Opening<T>? opening,
    Replacing<T>? replacing,
    Closing<T>? closing,
  }) : super(
          urlName,
          decode,
          opening: opening,
          replacing: replacing,
          closing: closing,
          screenTitle: screenTitle,
        );

  ScreenBuilder<T> screenBuilder;
  Screen2Page<T>? screen2Page;
  Widget buildScreen(TypedSegment segment) => screenBuilder(segment as T);
}
