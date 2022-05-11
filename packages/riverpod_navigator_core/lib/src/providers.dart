part of 'riverpod_navigator_core.dart';

/// provider for app specific RNavigatorCore
///
/// initializes in [ProviderScope] or [ProviderContainer] .overrides
final navigatorProvider =
    Provider<RNavigatorCore>((_) => throw UnimplementedError());

/// intended TypedPath provider
///
/// initializes in [ProviderScope] or [ProviderContainer] overrides
// final intendedPathProvider = StateProvider<TypedPath>((_) => throw UnimplementedError());
final intendedPathProvider = StateProvider<TypedPath>((_) => []);

/// navigationStackProvider
final navigationStackProvider = StateProvider<TypedPath>((_) => []);

/// isNavigatingProvider: navigation is running iff ref.read(isNavigatingProvider) > 0
final isNavigatingProvider = StateProvider<int>((_) => 0);

/// initialize providers
List<Override> riverpodNavigatorOverrides(
  TypedPath initPath,
  RNavigatorCore createNavigator(Ref ref), {
  RestorePath? restorePath,
  String? initPathAsString,
  List<AlwaysAliveProviderListenable> dependsOn = const [],
}) =>
    [
      ...dependsOn.map((e) => e as Override),
      intendedPathProvider,
      navigationStackProvider,
      isNavigatingProvider,
      navigatorProvider.overrideWithProvider(Provider((ref) {
        final res = createNavigator(ref);
        res._restorePath = restorePath;
        res._setdependsOn(dependsOn);
        Future.microtask(() => res.navigate(initPathAsString == null
            ? initPath
            : string2Path(initPathAsString)!));
        return res;
      })),
    ];
