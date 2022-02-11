part of 'index.dart';

/// riverpodNavigatorCreatorProvider is initialized by:
///
/// ```
/// ProviderScope(
///   overrides: [
///     riverpodNavigatorCreatorProvider.overrideWithValue(...),
///   ],...
/// ```
final riverpodNavigatorCreatorProvider = Provider<RiverpodNavigatorCreator>((_) => throw UnimplementedError());

/// provider for app specific RiverpodNavigator
final riverpodNavigatorProvider = Provider<RiverpodNavigator>((ref) => ref.read(riverpodNavigatorCreatorProvider)(ref));

/// ongoing TypedPath provider
///
/// [ongoingTypedPath] may differ from [RiverpodNavigatorLow.currentPath] during navigation calculation
final ongoingPathProvider = StateProvider<TypedPath>((_) => []);
