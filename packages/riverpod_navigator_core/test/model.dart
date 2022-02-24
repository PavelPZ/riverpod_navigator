import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';

class HomeSegment extends TypedSegment {
  const HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars map) => HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  factory BookSegment.fromUrlPars(UrlPars map) =>
      BookSegment(id: map.getInt('id'));

  final int id;

  @override
  void toUrlPars(UrlPars map) => map.setInt('id', id);
}

class LoginSegment extends TypedSegment {
  const LoginSegment();
  // ignore: avoid_unused_constructor_parameters
  factory LoginSegment.fromUrlPars(UrlPars map) => LoginSegment();
}

final routes = <RRoute4Dart>[
  RRoute4Dart<HomeSegment>(HomeSegment.fromUrlPars),
  RRoute4Dart<BookSegment>(BookSegment.fromUrlPars),
  RRoute4Dart<LoginSegment>(LoginSegment.fromUrlPars),
];
