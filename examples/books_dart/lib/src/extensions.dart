import 'package:riverpod_navigator_dart/riverpod_navigator_dart.dart';

import 'model/model.dart';

bool needsLogin(TypedSegment segment) {
  if (segment is AppSegments)
    return segment.maybeMap(
      book: (seg) => seg.id.isOdd,
      orElse: () => false,
    );
  else
    return false;
}

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
