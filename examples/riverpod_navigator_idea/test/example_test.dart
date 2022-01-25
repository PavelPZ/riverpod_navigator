import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_idea/riverpod_navigator_idea_dart.dart';
import 'package:test/test.dart';

void main() {
  test('navigation test', () async {
    final container = ProviderContainer();
    final navigator = container.read(exampleRiverpodNavigatorProvider);

    navigator.toBook(id: 3);
    await container.pump();
    expect(navigator.actualTypedPathAsString, '{"runtimeType":"home"} / {"runtimeType":"books"} / {"id":3,"runtimeType":"book"}');

    navigator.toBooks();
    await container.pump();
    expect(navigator.actualTypedPathAsString, '{"runtimeType":"home"} / {"runtimeType":"books"}');

    navigator.toHome();
    await container.pump();
    expect(navigator.actualTypedPathAsString, '{"runtimeType":"home"}');

    navigator.pop();
    await container.pump();
    expect(navigator.actualTypedPathAsString, '{"runtimeType":"home"}');

    navigator.toBook(id: 2);
    await container.pump();
    expect(navigator.actualTypedPathAsString, '{"runtimeType":"home"} / {"runtimeType":"books"} / {"id":2,"runtimeType":"book"}');

    navigator.pop();
    await container.pump();
    expect(navigator.actualTypedPathAsString, '{"runtimeType":"home"} / {"runtimeType":"books"}');

    navigator.push(BookSegment(id: 1));
    await container.pump();
    expect(navigator.actualTypedPathAsString, '{"runtimeType":"home"} / {"runtimeType":"books"} / {"id":1,"runtimeType":"book"}');
    return;
  });
}
