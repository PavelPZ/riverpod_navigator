import '../model.dart';

abstract class Route4Model<T extends TypedSegment> {
  Future<void>? creating(T newPath) => null;
  Future<void>? merging(T oldPath, T newPath) => null;
  Future<void>? deactivating(T oldPath) => null;

  AsyncScreenActions toAsyncScreenActions() => AsyncScreenActions(
        creating: (n) => creating(n as T),
        merging: (o, n) => merging(o as T, n as T),
        deactivating: (o) => deactivating(o as T),
      );
}

// typedef GetRoute4Segment = Route4Segment Function(TypedSegment segment);

// class Route4Segment {
//   const Route4Segment(this.route, this.segment);
//   final Route4Model route;
//   final TypedSegment segment;
// }
