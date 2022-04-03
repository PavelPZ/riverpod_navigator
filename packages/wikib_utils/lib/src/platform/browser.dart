import 'dart:async';
import 'dart:html';

import 'package:path/path.dart' as p;

import 'common.dart';

String getUserDirectoryName([String? part1, String? part2, String? part3]) => p.join(part1!, part2, part3);

String getPlatform() => Platforms.browser;

class Connection {
  Connection._() {
    window.onOnline.listen((event) => _controller.add(true));
    window.onOffline.listen((event) => _controller.add(false));
  }
  // PUBLIC
  static bool? get isOnline => _instance._onLine;
  static StreamSubscription<bool> listen(void isOnline(bool data)) => _instance._controller.stream.listen(isOnline);
  static void mockSetOnline(bool isOnline) => _instance._controller.add(isOnline);

  // PRIVATE
  final _controller = StreamController<bool>();
  bool? get _onLine => window.navigator.onLine;
  static final _instance = Connection._();
}

Future<bool> connected() => throw UnimplementedError();
