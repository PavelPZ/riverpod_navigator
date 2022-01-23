import 'package:books_dart/books_dart.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_navigator/riverpod_navigator.dart';

import 'pages.dart';

Route4Segment appRouteWithSegment(TypedSegment segment) {
  if (segment is AppSegments)
    return segment.map(
      home: (seg) => Route4Segment(_homeRoute, seg),
      books: (seg) => Route4Segment(_booksRoute, seg),
      book: (seg) => Route4Segment(_bookRoute, seg),
    );
  else if (segment is LoginSegments)
    return segment.map(
      (_) => throw UnimplementedError(),
      home: (seg) => Route4Segment(_loginRoute, seg),
    );
  else
    throw UnimplementedError();
}

class HomeRoute extends HomeRoute4Model implements NavigRoute<HomeSegment> {
  @override
  Widget buildPage(HomeSegment segment) => HomePage(segment);
}

class BooksRoute extends BooksRoute4Model implements NavigRoute<BooksSegment> {
  @override
  Widget buildPage(BooksSegment segment) => BooksPage(segment);
}

class BookRoute extends BookRoute4Model implements NavigRoute<BookSegment> {
  @override
  Widget buildPage(BookSegment segment) => BookPage(segment);
}

class LoginRoute extends Login4Model implements NavigRoute<LoginHomeSegment> {
  @override
  Widget buildPage(LoginHomeSegment segment) => LoginPage(segment);
}

final HomeRoute _homeRoute = HomeRoute();
final BooksRoute _booksRoute = BooksRoute();
final BookRoute _bookRoute = BookRoute();
final LoginRoute _loginRoute = LoginRoute();
