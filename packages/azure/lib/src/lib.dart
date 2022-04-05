import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

//const CLIENT_SEND_ERROR = 600;
//const NO_INTERNET = 602;
//const NO_INTERNET_MOCK = 603;

int toIntLow(int dbId, int id) => (dbId << 27) + id;
Tuple2<int, int> fromIntLow(int i) => Tuple2<int, int>((i >> 27) & 0xf, i & 0x7ffffff);

// https://docs.microsoft.com/en-us/rest/api/storageservices/table-service-error-codes
// class AzureErrors {
//   AzureErrors._();
//   // eTag conflict
//   static final preconditionFailed = HttpException(412, 'Precondition Failed');
//   // insert existing
//   static final conflict = HttpException(409, 'Conflict');
//   // partition + row query: not found
//   static final notFound = HttpException(404, 'Not Found');
//   static final bussy = HttpException(500, '500 or 503');
//   // wrong deviceId during batch merge
//   //static final deviceIdError = HttpException(DEVICE_ID_DURING_MERGE, 'Device Id during batch merge');
//   // client send  error
//   static HttpException clientSendError = HttpException(CLIENT_SEND_ERROR, 'CLIENT_SEND_ERROR');
//   //static HttpException mockError = HttpException(NO_INTERNET_MOCK, 'NO_INTERNET_MOCK');
//   //static HttpException noInternetError = HttpException(NO_INTERNET, null);

//   // Creators
//   static HttpException createClientSendError(String reason) => HttpException(CLIENT_SEND_ERROR, reason);
//   static HttpException createResponseError(StreamedResponse resp) {
//     if (resp == null || resp.statusCode < 400) return null;
//     switch (resp.statusCode) {
//       case 409:
//         return AzureErrors.conflict;
//       case 404:
//         return AzureErrors.notFound;
//       case 412:
//         return AzureErrors.preconditionFailed;
//       case 500:
//       case 503:
//       case 504:
//         return AzureErrors.bussy;
//       default:
//         return HttpException(resp.statusCode, resp.reasonPhrase);
//     }
//   }
// }

// https://docs.microsoft.com/en-us/rest/api/storageservices/designing-a-scalable-partitioning-strategy-for-azure-table-storage
// https://docs.microsoft.com/en-us/azure/architecture/best-practices/retry-service-specific
abstract class IRetries {
  int nextMSec();
  Future delay() => Future.delayed(Duration(milliseconds: nextMSec()));
}

class RetriesSimple extends IRetries {
  int baseMsec = 4000;
  @override
  int nextMSec() {
    if (baseMsec > 30000) throw Exception();
    return baseMsec *= 2;
  }
}

class Retries extends IRetries {
  Retries({this.baseMsec = 15000, this.rangeRatio = 2, this.forConcurency = false, this.maxNumOfRetries = 10}) {
    if (!forConcurency) {
      _delays = List<int>.from(Iterable.generate(maxNumOfRetries, (i) => baseMsec * (1 << i)));
      _delaysRange = List<int>.from(_delays!.map((d) => d ~/ rangeRatio));
    }
  }
  Retries.forConcurency() : this(baseMsec: 3000, rangeRatio: 3, forConcurency: true, maxNumOfRetries: 20);
  //Future delay() => Future.delayed(Duration(milliseconds: _nextMSec()));

  int baseMsec;
  int maxNumOfRetries;
  bool forConcurency;
  double rangeRatio = 3;
  // 2, 4, 8, 16, 32, ...
  List<int>? _delays;
  // (2, 4, 8, 16, 32, ...)/_rangeRatio
  List<int>? _delaysRange;
  static final _random = Random();
  var _retries = -1;
  int get retries => _retries;
  @override
  int nextMSec() {
    int res;
    if (_retries >= maxNumOfRetries - 1) throw Exception('Max num of retries exceeded');
    _retries++;
    if (forConcurency) {
      res = (baseMsec / rangeRatio + _random.nextInt(baseMsec)).toInt();
    } else {
      res = _delays![_retries];
      final halfRange = _delaysRange![_retries];
      res = res - halfRange + _random.nextInt(2 * halfRange);
    }
    //assert(dp('send wait: $res'));
    return res;
  }
}

class Encoder {
  Encoder._(this._d2Char, this._d4Char, this._validChars)
      : _d2 = _d2Char.codeUnitAt(0),
        _d4 = _d4Char.codeUnitAt(0) {
    _validCharDir = Map<int, bool>.fromIterable(_validChars.runes.where((ch) => ch != _d2 && ch != _d4), key: (ch) => ch, value: (ch) => true);
  }

  // static const lastKey = '~';
  static final keys = Encoder._('~', ';', '!\$&()*+,-.0123456789:;=@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]_abcdefghijklmnopqrstuvwxyz~');
  static final tables = Encoder._('A', 'B', '0123456789abcdefghijklmnopqrstuvwxyz');

  final String _d2Char;
  final String _d4Char;
  final String _validChars;
  final int _d2;
  final int _d4;
  late Map<int, bool> _validCharDir;

  String? encode(String? val) {
    if (val == null) return null;
    final sb = StringBuffer();
    for (var i = 0; i < val.length; i++) {
      final ch = val.codeUnitAt(i);
      if (_validCharDir.containsKey(ch)) {
        sb.write(String.fromCharCode(ch));
        continue;
      }
      assert(ch <= 0xffff);
      // ~ef OR ;efef
      sb.write('${ch <= 0xff ? _d2Char : _d4Char}${ch.toRadixString(16).padLeft(ch <= 0xff ? 2 : 4, '0')}');
    }
    return sb.toString();
  }

  String decode(String val) {
    final sb = StringBuffer();
    var idx = 0;
    while (idx < val.length) {
      final ch = val[idx];
      if (ch == _d2Char) {
        sb.write(String.fromCharCode(int.parse(val.substring(idx + 1, idx + 3), radix: 16)));
        idx += 3;
      } else if (ch == _d4Char) {
        sb.write(String.fromCharCode(int.parse(val.substring(idx + 1, idx + 5), radix: 16)));
        idx += 5;
      } else {
        sb.write(ch);
        idx += 1;
      }
    }
    return sb.toString();
  }

  // *********** PRIVATE
}

http.Request copyRequest(http.Request request) => http.Request(request.method, request.url)
  ..encoding = request.encoding
  ..bodyBytes = request.bodyBytes
  ..persistentConnection = request.persistentConnection
  ..followRedirects = request.followRedirects
  ..maxRedirects = request.maxRedirects
  ..headers.addAll(request.headers);

class ResponsePart {
  late int statusCode;
  late String reasonPhrase;
  final headers = <String, String>{};
  final body = StringBuffer();

  // https://docs.microsoft.com/en-us/rest/api/storageservices/performing-entity-group-transactions
  static Iterable<ResponsePart> parseResponse(String response) sync* {
    const crlf = '\r\n';
    const multipart = 'Content-Type: multipart/mixed; boundary=';
    final idx = response.indexOf(multipart);
    if (idx < 0) return;
    response = response.substring(idx + multipart.length);
    final lines = response.split(crlf);
    final changeSetStart = '--' + lines[0];
    final changeSetEnd = changeSetStart + '--';
    var state = 0;
    late ResponsePart part;
    for (final line in lines) {
      switch (state) {
        case 0: // before first changeSetStart
          if (line != changeSetStart) continue;
          state = 1;
          break;
        case 1: // after changeSetStart, before first epmty line
          if (line != '') continue;
          part = ResponsePart();
          yield part;
          state = 2;
          break;
        case 2: // on HTTP/1.1
          final parts = line.split(' ');
          assert(parts.length >= 3);
          assert(parts[0] == 'HTTP/1.1');
          part.statusCode = int.parse(parts[1]);
          part.reasonPhrase = parts.sublist(2).join(' ');
          state = 3;
          break;
        case 3: // headers
          if (line != '') {
            final parts = line.split(': ');
            assert(parts.length == 2);
            part.headers[parts[0]] = parts[1];
            continue;
          }
          state = 4;
          break;
        case 4: // body
          if (line == changeSetEnd) break;
          if (line != changeSetStart) {
            part.body.writeln(line);
            continue;
          }
          state = 1;
          break;
      }
    }
  }
}