import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_idea/riverpod_navigator_idea-dart.dart';
import 'package:test/test.dart';

void main() {
  test('navigation test', () async {
    final container = ProviderContainer();
    final navigator = container.read(exampleRiverpodNavigatorProvider);

    navigator.toBook(id: 3);
    await container.pump();
    print(navigator.actualTypedPathAsString);

    navigator.toBooks();
    await container.pump();
    print(navigator.actualTypedPathAsString);

    navigator.toHome();
    await container.pump();
    print(navigator.actualTypedPathAsString);

    navigator.pop();
    await container.pump();
    print(navigator.actualTypedPathAsString);

    navigator.toBook(id: 2);
    await container.pump();
    print(navigator.actualTypedPathAsString);

    navigator.pop();
    await container.pump();
    print(navigator.actualTypedPathAsString);

    navigator.push(BookSegment(id: 1));
    await container.pump();
    print(navigator.actualTypedPathAsString);

    return;
  });
}
