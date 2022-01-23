import 'package:books_dart/books_dart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  final container = ProviderContainer(
    parent: parent,
    overrides: overrides,
    observers: observers,
  );
  addTearDown(container.dispose);
  return container;
}

typedef AsyncChange = void Function(bool inStart, [Object? error]);
AsyncChange onAsyncChangeFunc(List<String> result, AppNavigator navigator) {
  final start = DateTime.now();
  return (inStart, [error]) {
    if (inStart) return;
    final call = DateTime.now();
    final elapsed = call.difference(start);
    result.add('${elapsed.inMilliseconds}: ${navigator.pathParser.typedPath2Path(navigator.actualTypedPath)}');
  };
}
