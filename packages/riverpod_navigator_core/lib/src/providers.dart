part of 'index.dart';

/// provider for app specific RNavigatorCore
///
/// initializes in [ProviderScope] or [ProviderContainer] overrides
final riverpodNavigatorProvider = Provider<RNavigatorCore>((_) => throw UnimplementedError());

/// ongoing TypedPath provider
///
/// initializes in [ProviderScope] or [ProviderContainer] overrides
final ongoingPathProvider = StateProvider<TypedPath>((_) => throw UnimplementedError());

/// navigationStackProvider
final navigationStackProvider = StateProvider<TypedPath>((_) => []);
