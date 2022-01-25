import 'package:books_dart/books_dart.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'pages.dart';

NavigRoute segment2Route(TypedSegment segment) {
  if (segment is AppSegments)
    return segment.map(
      home: (_) => _homeRoute,
      books: (_) => _booksRoute,
      book: (_) => _bookRoute,
    );
  else if (segment is LoginSegments)
    return segment.map(
      (_) => throw UnimplementedError(),
      home: (_) => _loginRoute,
    );
  else
    throw UnimplementedError();
}

class HomeRoute extends HomeRoute4Model implements NavigRoute<HomeSegment> {
  @override
  Widget buildPage(HomeSegment segment) => HomeScreen(segment);
}

class BooksRoute extends BooksRoute4Model implements NavigRoute<BooksSegment> {
  @override
  Widget buildPage(BooksSegment segment) => BooksScreen(segment);
}

class BookRoute extends BookRoute4Model implements NavigRoute<BookSegment> {
  @override
  Widget buildPage(BookSegment segment) => BookScreen(segment);
}

class LoginRoute extends Login4Model implements NavigRoute<LoginHomeSegment> {
  @override
  Widget buildPage(LoginHomeSegment segment) => LoginScreen(segment);
}

final HomeRoute _homeRoute = HomeRoute();
final BooksRoute _booksRoute = BooksRoute();
final BookRoute _bookRoute = BookRoute();
final LoginRoute _loginRoute = LoginRoute();
