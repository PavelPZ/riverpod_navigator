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
  TypedPath path,
  RNavigatorCore createNavigator(Ref ref), {
  @Deprecated('use initPath')
  String? initPathStr,
  Uri? initPath,
  RestorePath? restorePath,
  List<AlwaysAliveProviderListenable> dependsOn = const [],
}) =>
    [
      ...dependsOn.map((e) => e as Override),
      intendedPathProvider,
      navigationStackProvider,
      isNavigatingProvider,
      navigatorProvider.overrideWith((ref) {
        final res = createNavigator(ref);
        res._restorePath = restorePath;
        res._setDependsOn(dependsOn);
        Future.microtask(() {
          // ignore: deprecated_member_use_from_same_package
          var p = initPathStr != null ? string2Path(initPathStr)! : initPath != null ? uri2Path(initPath) : path;
          p = res._restorePath != null
              ? res._restorePath!.getInitialPath(p)
              : p;
          res.navigate(p);
        });
        //initPathStr != null ? string2Path(initPathStr)! : initPath));
        return res;
      }),
    ];
