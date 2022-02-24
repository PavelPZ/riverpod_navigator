import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';

class HomeSegment extends TypedSegment {
  static HomeSegment fromSegmentMap(SegmentMap map) => HomeSegment();
}

@immutable
class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  final int id;
  @override
  void toSegmentMap(SegmentMap map) => map.setInt('id', id);
  static BookSegment fromSegmentMap(SegmentMap map) => BookSegment(id: map.getInt('id'));
}

class LoginSegment extends TypedSegment {
  static LoginSegment fromSegmentMap(SegmentMap map) => LoginSegment();
}

final routes = <RRoute4Dart>[
  RRoute4Dart<HomeSegment>(HomeSegment.fromSegmentMap),
  RRoute4Dart<BookSegment>(BookSegment.fromSegmentMap),
  RRoute4Dart<LoginSegment>(LoginSegment.fromSegmentMap),
];

final loginProvider = StateProvider<bool>((_) => false);

class TestNavigator extends RNavigatorCore {
  TestNavigator(Ref ref, {this.delayMsec, this.isError = false}) : super(ref, []);

  final int? delayMsec;
  final bool isError;

  @override
  FutureOr<TypedPath> appNavigationLogicCore(TypedPath oldNavigationStack, TypedPath ongoingPath) {
    if (delayMsec == null) {
      if (isError) throw 'SYNC ERROR';
      return ongoingPath;
    } else {
      return Future.delayed(Duration(milliseconds: delayMsec!)).then<TypedPath>((value) {
        if (isError) throw 'ASYNC ERROR';
        return ongoingPath;
      });
    }
  }
}

Future main() async {
  final container = ProviderContainer(
      overrides: RNavigatorCore.providerOverrides(
    [HomeSegment()],
    TestNavigator.new,
  ));
  final navigator = container.read(navigatorProvider);

  await container.pump();
  await navigator.navigationCompleted;
  final p1 = navigator.navigationStack2Url;
  assert(p1 == '{"runtimeType":"HomeSegment"}');

  container.read(ongoingPathProvider.notifier).state = [HomeSegment(), BookSegment(id: 1)];
  await container.pump();
  await navigator.navigationCompleted;
  final p2 = navigator.navigationStack2Url;
  assert(p2 == '{"runtimeType":"HomeSegment"}/{"runtimeType":"BookSegment","id":1}');
  return;
}
