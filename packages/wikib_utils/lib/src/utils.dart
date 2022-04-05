import 'package:http/http.dart';

bool? mockConnection;

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
