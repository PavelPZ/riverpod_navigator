import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

import 'model/model.dart';

AsyncScreenActions? segment2AsyncScreenActions4Routes(TypedSegment segment) => segment2Route4Dart(segment).toAsyncScreenActions();

bool getNeedsLogin4Routes4Dart(TypedSegment segment) {
  if (segment is AppSegments) {
    final route = segment2Route4Dart(segment);
    if (route is! RouteNeedsLogin) return false;
    final needsLoginRoute = route as RouteNeedsLogin;
    return segment.maybeMap(
      book: (seg) => needsLoginRoute.needsLogin(seg),
      orElse: () => false,
    );
  }
  return false;
}

Route4Dart segment2Route4Dart(TypedSegment segment) {
  if (segment is AppSegments)
    return segment.map(
      home: (_) => _debugModelHomeRoute,
      books: (_) => _debugModelBooksRoute,
      book: (_) => _debugModelBookRoute,
    );
  else if (segment is LoginSegments)
    return segment.map(
      (_) => throw UnimplementedError(),
      home: (_) => _debugModelLoginRoute,
    );
  else
    throw UnimplementedError();
}

/// mixin for routes which need login (calling needsLogin() returns true => unauthorized acces for the page is not allowed)
mixin RouteNeedsLogin<T extends TypedSegment> {
  bool needsLogin(T segment) => false;
}

class HomeRoute4Dart extends Route4Dart<HomeSegment> {
  HomeRoute4Dart() : super();

  /// simulates ssigle seconds delay for creating home page
  @override
  Future<void>? creating(HomeSegment newSegment) => Future.delayed(Duration(seconds: 1));
}

class BooksRoute4Dart extends Route4Dart<BooksSegment> {}

class BookRoute4Dart extends Route4Dart<BookSegment> with RouteNeedsLogin<BookSegment> {
  /// simulates half seconds delay for creating book page with odd id
  @override
  Future<void>? creating(BookSegment newSegment) => newSegment.id.isOdd ? Future.delayed(Duration(milliseconds: 500)) : null;

  /// simulates 200 msec delay when replacing book page (page with odd id only)
  @override
  Future<void>? merging(BookSegment oldSegment, BookSegment newSegment) => oldSegment.id.isOdd ? Future.delayed(Duration(milliseconds: 200)) : null;

  /// simulates "unauthorized acces not allowed" for book page with odd id
  @override
  bool needsLogin(BookSegment segment) => segment.id.isOdd;
}

class Login4Dart extends Route4Dart<LoginHomeSegment> {}

final HomeRoute4Dart _debugModelHomeRoute = HomeRoute4Dart();
final BooksRoute4Dart _debugModelBooksRoute = BooksRoute4Dart();
final BookRoute4Dart _debugModelBookRoute = BookRoute4Dart();
final Login4Dart _debugModelLoginRoute = Login4Dart();
