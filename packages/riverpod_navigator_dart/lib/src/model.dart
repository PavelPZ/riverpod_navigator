import 'dart:convert';

import 'package:riverpod/riverpod.dart';

typedef TypedPath = List<TypedSegment>;
typedef JsonMap = Map<String, dynamic>;

abstract class TypedSegment {
  TypedSegment copy();
  JsonMap toJson();

  /// key for MaterialApp(key: ValueKey([TypedSegment.key]))
  String get key => _key ?? (_key = jsonEncode(this));
  String? _key;
}

class TypedPathNotifier extends StateController<TypedPath> {
  TypedPathNotifier({TypedPath? initPath}) : super(initPath ?? []);
}
