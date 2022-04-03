import 'package:riverpod_navigator_core/riverpod_navigator_core.dart';

class HomeSegment extends TypedSegment {
  const HomeSegment();
  // ignore: avoid_unused_constructor_parameters
  factory HomeSegment.decode(UrlPars pars) => HomeSegment();
}

class BookSegment extends TypedSegment {
  const BookSegment({required this.id});
  factory BookSegment.decode(UrlPars pars) =>
      BookSegment(id: pars.getInt('id'));

  final int id;

  @override
  void encode(UrlPars pars) => pars.setInt('id', id);
}

class LoginSegment extends TypedSegment {
  const LoginSegment();
  // ignore: avoid_unused_constructor_parameters
  factory LoginSegment.decode(UrlPars pars) => LoginSegment();
}

final routes = <RRouteCore>[
  RRouteCore<HomeSegment>('home', HomeSegment.decode),
  RRouteCore<BookSegment>('book', BookSegment.decode),
  RRouteCore<LoginSegment>('login', LoginSegment.decode),
];

class TestSegment extends TypedSegment {
  const TestSegment({required this.i, this.s, required this.b, this.d});

  factory TestSegment.decode(UrlPars pars) => TestSegment(
        i: pars.getInt('i'),
        s: pars.getStringNull('s'),
        b: pars.getBool('b'),
        d: pars.getDoubleNull('d'),
      );

  @override
  void encode(UrlPars pars) =>
      pars.setInt('i', i).setString('s', s).setBool('b', b).setDouble('d', d);

  final int i;
  final String? s;
  final bool b;
  final double? d;
}
