part of 'index.dart';

/// config4DartProvider value is initialized by:
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
/// [ongoingTypedPath] may differ from [RiverpodNavigatorLow.currentTypedPath] during navigation calculation
final ongoingPathProvider = StateProvider<TypedPath>((_) => []);
