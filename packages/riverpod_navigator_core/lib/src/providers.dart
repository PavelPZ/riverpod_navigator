part of 'riverpod_navigator_core.dart';

/// provider for app specific RNavigatorCore
///
/// initializes in [ProviderScope] or [ProviderContainer] .overrides
final navigatorProvider =
    Provider<RNavigatorCore>((_) => throw UnimplementedError());

/// intended TypedPath provider
///
/// initializes in [ProviderScope] or [ProviderContainer] overrides
final intendedPathProvider =
    StateProvider<TypedPath>((_) => throw UnimplementedError());

/// navigationStackProvider
final navigationStackProvider = StateProvider<TypedPath>((_) => []);

/// isNavigatingProvider: navigation is running iff ref.read(isNavigatingProvider) > 0
final isNavigatingProvider = StateProvider<int>((_) => 0);

/// initialize providers
List<Override> providerOverrides(
  TypedPath initPath,
  RNavigatorCore navigator(Ref ref), {
  RestorePath? restorePath,
  List<AlwaysAliveProviderListenable> dependsOn = const [],
}) =>
    [
      ...dependsOn.map((e) => e as Override),
      intendedPathProvider.overrideWithValue(
        StateController<TypedPath>(
          restorePath == null ? initPath : restorePath.getInitialPath(initPath),
        ),
      ),
      navigationStackProvider,
      isNavigatingProvider,
      navigatorProvider.overrideWithProvider(
        Provider((ref) => navigator(ref)
          .._restorePath = restorePath
          ..initPath = initPath
          .._setdependsOn(dependsOn)),
      ),
    ];
