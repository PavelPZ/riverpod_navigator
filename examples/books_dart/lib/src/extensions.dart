import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

import 'model/model.dart';
import 'route.dart';

// ignore: unused_element
bool getNeedsLogin4Dart(TypedSegment segment) {
  if (segment is AppSegments)
    return segment.maybeMap(
      book: (seg) => seg.id.isOdd,
      orElse: () => false,
    );
  else
    return false;
}

// ignore: unused_element
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

//const needsLogin = _needsLogin;
// for routes
bool Function(TypedSegment segment) needsLoginProc4Dart = getNeedsLogin4Dart;

/// mock some of async screen actions
AsyncScreenActions? segment2AsyncScreenActions(TypedSegment segment) {
  if (segment is AppSegments)
    return segment.maybeMap(
      book: (_) => AsyncScreenActions<BookSegment>(
        // every Book screen with odd id needs 500 msecs delay before displaying (e.g. for loading Book data)
        creating: (newSegment) => newSegment.id.isOdd ? Future.delayed(Duration(milliseconds: 500)) : null,
        merging: (oldSegment, _) => oldSegment.id.isOdd ? Future.delayed(Duration(milliseconds: 200)) : null,
      ),
      home: (_) => AsyncScreenActions<HomeSegment>(
        creating: (_) => Future.delayed(Duration(seconds: 1)),
      ),
      orElse: () => null,
    );
  else
    return null;
}

AsyncScreenActions? segment2AsyncScreenActions4Routes(TypedSegment segment) => segment2Route4Dart(segment).toAsyncScreenActions();
