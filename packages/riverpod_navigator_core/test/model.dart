import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';

class HomeSegment extends TypedSegment {
  const HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.fromUrlPars(UrlPars pars) => HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  factory BookSegment.fromUrlPars(UrlPars pars) =>
      BookSegment(id: pars.getInt('id'));

  final int id;

  @override
  void toUrlPars(UrlPars pars) => pars.setInt('id', id);
}

class LoginSegment extends TypedSegment {
  const LoginSegment();
  // ignore: avoid_unused_constructor_parameters
  factory LoginSegment.fromUrlPars(UrlPars pars) => LoginSegment();
}

final routes = <RRoute4Dart>[
  RRoute4Dart<HomeSegment>('home', HomeSegment.fromUrlPars),
  RRoute4Dart<BookSegment>('book', BookSegment.fromUrlPars),
  RRoute4Dart<LoginSegment>('login', LoginSegment.fromUrlPars),
];
