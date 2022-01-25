import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_idea/riverpod_navigator_idea_dart.dart';
import 'package:test/test.dart';

void main() {
  configure4Dart();
  test('navigation test', () async {
    final container = ProviderContainer();
    final navigator = container.read(exampleRiverpodNavigatorProvider);

    navigator.toBook(id: 3);
    await container.pump();
    expect(navigator.debugTypedPath2String(), '{"runtimeType":"home"} / {"runtimeType":"books"} / {"id":3,"runtimeType":"book"}');

    navigator.toBooks();
    await container.pump();
    expect(navigator.debugTypedPath2String(), '{"runtimeType":"home"} / {"runtimeType":"books"}');

    navigator.toHome();
    await container.pump();
    expect(navigator.debugTypedPath2String(), '{"runtimeType":"home"}');

    await navigator.pop();
    await container.pump();
    expect(navigator.debugTypedPath2String(), '{"runtimeType":"home"}');

    navigator.toBook(id: 2);
    await container.pump();
    expect(navigator.debugTypedPath2String(), '{"runtimeType":"home"} / {"runtimeType":"books"} / {"id":2,"runtimeType":"book"}');

    await navigator.pop();
    await container.pump();
    expect(navigator.debugTypedPath2String(), '{"runtimeType":"home"} / {"runtimeType":"books"}');

    await navigator.push(BookSegment(id: 1));
    await container.pump();
    expect(navigator.debugTypedPath2String(), '{"runtimeType":"home"} / {"runtimeType":"books"} / {"id":1,"runtimeType":"book"}');
    return;
  });
}
