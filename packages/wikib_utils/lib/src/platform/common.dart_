import 'package:http/http.dart';

import '../utils.dart';

abstract class Platforms {
  static const unknown = 'UNKNOWN';
  static const ios = 'IOS';
  static const android = 'ANDROID';
  static const fuschia = 'FUSCHIA';
  static const windows = 'WINDOWS';
  static const linux = 'LINUX';
  static const macos = 'MACOS';
  static const browser = 'BROWSER';
}

// Future<bool> connectedConnectivity() async {
//   if (connectivity == null) {
//     connectivity = Connectivity();
//     connectivity!.onConnectivityChanged.listen((c) => connectivityResult = c);
//   }
//   connectivityResult = await connectivity!.checkConnectivity();
//   return connectivityResult != ConnectivityResult.none;
// }

// ConnectivityResult connectivityResult = ConnectivityResult.none;
// Connectivity? connectivity;

Future<bool> connectedByOne4() async {
  if (mockConnection != null) return mockConnection!;
  final client = Client();
  try {
    try {
      final resp =
          await client.send(Request('GET', Uri.parse('https://one.one.one.one/favicon.ico?${DateTime.now().millisecondsSinceEpoch.toString()}')));
      assert(resp.statusCode >= 400 || resp.statusCode < 300); // avoid 3xx codes
      return resp.statusCode < 400;
    } catch (e) {
      return false;
    }
  } finally {
    client.close();
  }
}
