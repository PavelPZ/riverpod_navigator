import 'package:riverpod_navigator/riverpod_navigator.dart';

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
