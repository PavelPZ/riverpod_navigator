import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';

class HomeSegment extends TypedSegment {
  const HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars pars) => HomeSegment();
}

@immutable
class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  factory BookSegment.fromUrlPars(UrlPars pars) => BookSegment(id: pars.getInt('id'));
  final int id;
  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);
}

class LoginSegment extends TypedSegment {
  const LoginSegment();
  // ignore: avoid_unused_constructor_parameters
  factory LoginSegment.fromUrlPars(UrlPars pars) => LoginSegment();
}

final routes = <RRouteCore>[
  RRouteCore<HomeSegment>('home', HomeSegment.fromUrlPars),
  RRouteCore<BookSegment>('book', BookSegment.fromUrlPars),
  RRouteCore<LoginSegment>('login', LoginSegment.fromUrlPars),
];

final loginProvider = StateProvider<bool>((_) => false);

class TestNavigator extends RNavigatorCore {
  TestNavigator(Ref ref, {this.delayMsec, this.isError = false}) : super(ref, []);

  final int? delayMsec;
  final bool isError;

  @override
  FutureOr<TypedPath> appNavigationLogicCore(TypedPath oldNavigationStack, TypedPath intendedPath) {
    if (delayMsec == null) {
      if (isError) throw 'SYNC ERROR';
      return intendedPath;
    } else {
      return Future.delayed(Duration(milliseconds: delayMsec!)).then<TypedPath>((value) {
        if (isError) throw 'ASYNC ERROR';
        return intendedPath;
      });
    }
  }
}

Future main() async {
  final container = ProviderContainer(
      overrides: providerOverrides(
    [HomeSegment()],
    TestNavigator.new,
  ));
  final navigator = container.read(navigatorProvider);

  await container.pump();
  await navigator.navigationCompleted;
  final p1 = navigator.navigationStack2Url;
  assert(p1 == '{"runtimeType":"HomeSegment"}');

  container.read(intendedPathProvider.notifier).state = [HomeSegment(), BookSegment(id: 1)];
  await container.pump();
  await navigator.navigationCompleted;
  final p2 = navigator.navigationStack2Url;
  assert(p2 == '{"runtimeType":"HomeSegment"}/{"runtimeType":"BookSegment","id":1}');
  return;
}
