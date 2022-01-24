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
