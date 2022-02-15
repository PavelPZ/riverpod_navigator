part of 'index.dart';

/// riverpodNavigatorCreatorProvider is initialized by:
///
/// ```
/// ProviderScope(
///   overrides: [
///     riverpodNavigatorCreatorProvider.overrideWithValue(...),
///   ],...
/// ```
// final riverpodNavigatorCreatorProvider = Provider<RiverpodNavigatorCreator>((_) => throw UnimplementedError());

/// provider for app specific RNavigator
final riverpodNavigatorProvider = Provider<RNavigator>((_) => throw UnimplementedError());

/// ongoing TypedPath provider
///
/// [ongoingTypedPath] may differ from [RiverpodNavigatorLow.navigationStack] during navigation calculation
final ongoingPathProvider = StateProvider<TypedPath>((_) => []);
