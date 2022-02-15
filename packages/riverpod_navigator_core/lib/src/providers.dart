part of 'index.dart';

/// provider for app specific RiverpodNavigator
final riverpodNavigatorProvider = Provider<RNavigatorCore>((_) => throw UnimplementedError());

/// ongoing TypedPath provider
///
/// [ongoingTypedPath] may differ from [navigationStackProvider] during navigation calculation
final ongoingPathProvider = StateProvider<TypedPath>((_) => throw UnimplementedError());

/// navigationStackProvider
///
/// [navigationStackProvider] may differ from [ongoingTypedPath] during navigation calculation
final navigationStackProvider = StateProvider<TypedPath>((_) => []);
