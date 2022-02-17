part of 'index.dart';

class RRoute<T extends TypedSegment> extends RRoute4Dart<T> {
  RRoute(
    this.screenBuilder, {
    this.screen2Page,
    Opening<T>? creating,
    Replacing<T>? merging,
    Closing<T>? deactivating,
  }) : super(opening: creating, replacing: merging, closing: deactivating);
  ScreenBuilder<T> screenBuilder;
  Screen2Page<T>? screen2Page;
  Widget buildScreen(TypedSegment segment) => screenBuilder(segment as T);
}
