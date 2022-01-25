import '../model.dart';

abstract class Route4Dart<T extends TypedSegment> {
  Future<void>? creating(T newPath) => null;
  Future<void>? merging(T oldPath, T newPath) => null;
  Future<void>? deactivating(T oldPath) => null;

  AsyncScreenActions toAsyncScreenActions() => AsyncScreenActions(
        creating: (n) => creating(n as T),
        merging: (o, n) => merging(o as T, n as T),
        deactivating: (o) => deactivating(o as T),
      );
}
