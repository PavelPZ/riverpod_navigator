part of 'riverpod_navigator_core.dart';

/// provider for app specific RNavigatorCore
///
/// initializes in [ProviderScope] or [ProviderContainer] overrides
final navigatorProvider =
    Provider<RNavigatorCore>((_) => throw UnimplementedError());

/// ongoing TypedPath provider
///
/// initializes in [ProviderScope] or [ProviderContainer] overrides
final ongoingPathProvider =
    StateProvider<TypedPath>((_) => throw UnimplementedError());

/// navigationStackProvider
final navigationStackProvider = StateProvider<TypedPath>((_) => []);
