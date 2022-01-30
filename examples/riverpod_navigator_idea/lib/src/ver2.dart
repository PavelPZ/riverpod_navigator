// ignore_for_file: unused_local_variable

import 'package:riverpod/riverpod.dart';

class TypedSegment {
  TypedSegment(this.id);
  final int id;
}

typedef TypedPath = List<TypedSegment>;

class TypedPathNotifier extends StateNotifier<TypedPath> {
  TypedPathNotifier() : super([]);
}

final beforeProvider = StateProvider<TypedPath>((_) => []);
final afterProvider = StateProvider<TypedPath>((ref) => appLogic(ref));

TypedPath appLogic(Ref ref) {
  final old = ref.watch(beforeProvider);
  final neew = [old.isEmpty ? TypedSegment(0) : TypedSegment(old[0].id + 1)];
  ref.read(beforeProvider.notifier).state = neew;
  return neew;
}

class AppLogic {
  AppLogic(this.ref);
  final Ref ref;
  TypedPath run(Ref ref) {
    // final oldPath = ref.read(appLogicProvider);
    final newPath = ref.watch(typedPathNotifierProvider);
    final isLogged = ref.watch(isLoggedProvider);
    return [...newPath];
  }
}

final typedPathNotifierProvider = StateProvider<TypedPath>((_) => []);

final isLoggedProvider = StateProvider<bool>((_) => false);

final appLogicLowProvider = Provider<AppLogic>((ref) => AppLogic(ref));

final appLogicProvider = Provider<TypedPath>((ref) {
  // final oldValue = ref.read(appLogicProvider);
  return ref.read(appLogicLowProvider).run(ref);
});

final futureProvider = FutureProvider<bool> /*.family.autoDispose*/ ((_) => Future.value(true));

Future main() async {
  final container = ProviderContainer();
  container.read(beforeProvider.notifier).state = [TypedSegment(0)];
  final st = container.read(afterProvider);
  await container.pump();
  return;
}

Future main2() async {
  final container = ProviderContainer();

  container.listen<TypedPath>(appLogicProvider, (previous, next) {
    return;
  });

  final path = [TypedSegment(0), TypedSegment(1)];

  container.read(typedPathNotifierProvider.notifier).state = path;
  await container.pump();

  container.read(isLoggedProvider.notifier).state = true;
  await container.pump();

  container.read(typedPathNotifierProvider.notifier).state = path;
  await container.pump();

  container.read(futureProvider).when(data: (val) {}, error: (e, s) {}, loading: () {});

  return;
}
