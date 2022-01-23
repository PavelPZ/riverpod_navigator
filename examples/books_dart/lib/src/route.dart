import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

import 'model.dart';

TypedSegment json2Segment(JsonMap jsonMap, String unionKey) {
  switch (unionKey) {
    case PathParser.defaultJsonUnionKey:
      return AppSegments.fromJson(jsonMap);
    case LoginSegments.jsonNameSpace:
      return LoginSegments.fromJson(jsonMap);
    default:
      throw UnimplementedError();
  }
}

Route4Segment appRouteWithSegment4Model(TypedSegment segment) {
  if (segment is AppSegments)
    return segment.map(
      home: (seg) => Route4Segment(_debugModelHomeRoute, seg),
      books: (seg) => Route4Segment(_debugModelBooksRoute, seg),
      book: (seg) => Route4Segment(_debugModelBookRoute, seg),
    );
  else if (segment is LoginSegments)
    return segment.map(
      (_) => throw UnimplementedError(),
      home: (seg) => Route4Segment(_debugModelLoginRoute, seg),
    );
  else
    throw UnimplementedError();
}

/// mixin for routes which need login (calling needsLogin() returns true => unauthorized acces for the page is not allowed)
mixin RouteNeedsLogin<T extends TypedSegment> {
  bool needsLogin(T segment) => false;
}

class HomeRoute4Model extends Route4Model<HomeSegment> {
  HomeRoute4Model() : super();

  /// simulates ssigle seconds delay for creating home page
  @override
  Future<void>? creating(HomeSegment newSegment) => Future.delayed(Duration(seconds: 1));
}

class BooksRoute4Model extends Route4Model<BooksSegment> {}

class BookRoute4Model extends Route4Model<BookSegment> with RouteNeedsLogin<BookSegment> {
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

class Login4Model extends Route4Model<LoginHomeSegment> {}

final HomeRoute4Model _debugModelHomeRoute = HomeRoute4Model();
final BooksRoute4Model _debugModelBooksRoute = BooksRoute4Model();
final BookRoute4Model _debugModelBookRoute = BookRoute4Model();
final Login4Model _debugModelLoginRoute = Login4Model();

// final br2 = BookRoute();
// final xx = br2.needsLogin(BookSegment(id: 1));
