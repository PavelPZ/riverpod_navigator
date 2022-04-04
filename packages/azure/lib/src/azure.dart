import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:tuple/tuple.dart';
import 'package:wikib_utils/wikb_utils.dart';

import 'lib.dart';
import 'model.dart';

part 'azure_tables.dart';
part 'azure_table.dart';
part 'sender.dart';

class Azure extends Sender {
  Azure._(Account? accountKey, String table) {
    final isEmulator = accountKey == null;
    _accountKey = accountKey ?? _emulatorAccount;
    _key = base64.decode(_accountKey.key);

    final host = isEmulator ? 'http://127.0.0.1:10002' : 'https://${_accountKey.account}.table.core.windows.net';
    batchInnerUri = host + (isEmulator ? '/${_accountKey.account}/$table' : '/$table');

    for (var idx = 0; idx < 2; idx++) {
      final signatureTable = idx == 1 ? '\$batch' : table;
      final slashAcountTable = '/${_accountKey.account}/$signatureTable';
      _signaturePart[idx] = (isEmulator ? '/${_accountKey.account}' : '') + slashAcountTable; // second part of signature
      _uri[idx] = host + (isEmulator ? slashAcountTable : '/$signatureTable');
    }
  }

  //************* PRIVATE  */
  static const _emulatorAccount =
      Account('devstoreaccount1', 'Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==');
  static const _debugCloudAccount =
      Account('wikibularydata', 'm8so0vlCxtzpPMIu3IeQox+mtlqw4m/a0OALvXkvdgH1/zi5ZJHfmicIfwFAZXbOsZxlb2eDdlLREWKdjh4UWg==');
  static Account azureAccount([bool? isEmulator]) => isEmulator == true ? _emulatorAccount : _debugCloudAccount;

  late Account _accountKey;
  late Uint8List _key;
  // 1..for entity batch, 0..others
  final _signaturePart = ['', ''];
  final _uri = ['', ''];
  String? batchInnerUri;
  //static var mockError = false;

  // https://stackoverflow.com/questions/26066640/windows-azure-rest-api-sharedkeylite-authentication-storage-emulator
  // https://docs.microsoft.com/cs-cz/rest/api/storageservices/authorize-with-shared-key
  void _sign(Map<String, String> headers, {String? uriAppend, int? idx}) {
    // RFC1123 format
    final String dateStr = HttpDate.format(DateTime.now());
    final String signature = '$dateStr\n${_signaturePart[idx ?? 0]}${uriAppend ?? ''}';
    final toHash = utf8.encode(signature);
    final hmacSha256 = Hmac(sha256, _key); // HMAC-SHA256
    final token = base64.encode(hmacSha256.convert(toHash).bytes);
    // Authorization header
    final String strAuthorization = 'SharedKeyLite ${_accountKey.account}:$token';

    headers['Authorization'] = strAuthorization;
    headers['x-ms-date'] = dateStr;
    // headers['x-ms-version'] = '2018-03-28';
    headers['x-ms-version'] = '2021-04-10';
  }

  // entity Insert x Update x Delete, ...
  Future _writeKeyRequest(RowData data, String method, {/*String eTag,*/ SendPar? sendPar}) async {
    final res = await _writeRequest(data.toJsonBytes(), method, eTag: data.eTag, sendPar: sendPar, uriAppend: data.keyUrlPart());
    data.eTag = res;
  }

  Future<String?> _writeRequest(List<int>? bytes, String method,
      {String? eTag, SendPar? sendPar, String? uriAppend, void finishRequest(AzureRequest req)?}) async {
    sendPar ??= SendPar();
    final String uri = _uri[0] + (uriAppend ?? '');
    // Web request
    final request = AzureRequest(method, Uri.parse(uri));
    _sign(request.headers, uriAppend: uriAppend);
    request.headers['Accept'] = 'application/json;odata=nometadata';
    request.headers['Content-type'] = 'application/json';
    if (eTag != null) request.headers['If-Match'] = eTag;
    if (bytes != null) request.bodyBytes = bytes;
    if (finishRequest != null) finishRequest(request);

    sendPar.finalizeResponse ??= (resp) {
      final continueResult = resp.standardResponseProcesed();
      if (continueResult != null) return Future.value(continueResult);
      resp.result = resp.response!.headers['etag'];
      return Future.value(ContinueResult.doBreak);
    };
    final sendRes = await send<String>(request, sendPar);
    return sendRes?.result;
  }

  static const nextPartitionName = 'NextPartitionKey';
  static const nextRowName = 'NextRowKey';
  static const msContinuation = 'x-ms-continuation-';
  static final nextPartitionPar = msContinuation + nextPartitionName.toLowerCase();
  static final nextRowPar = msContinuation + nextRowName.toLowerCase();

  Future<List<dynamic>> queryLow<T>(Query? query, {SendPar? sendPar}) async {
    final request = _queryRequest(query: query);
    final res = <dynamic>[];
    var nextPartition = '';
    var nextRow = '';
    final oldUrl = request.uri.toString();
    sendPar ??= SendPar();

    Future<AzureRequest> getRequest() {
      if (nextPartition == '' && nextRow == '') return Future.value(request);
      var newUrl = oldUrl;
      if (nextPartition != '') newUrl += '&$nextPartitionName=$nextPartition';
      if (nextRow != '') newUrl += '&$nextRowName=$nextRow';
      request.uri = Uri.parse(newUrl);
      return Future.value(request);
    }

    while (true) {
      sendPar.finalizeResponse ??= (resp) async {
        final continueResult = resp.standardResponseProcesed();
        if (continueResult != null) return continueResult;
        final resStr = await resp.response!.stream.bytesToString();
        final resList = jsonDecode(resStr)['value'];
        assert(resList != null);
        res.addAll(resList);
        nextPartition = resp.response!.headers[nextPartitionPar] ?? '';
        nextRow = resp.response!.headers[nextRowPar] ?? '';
        resp.result = nextPartition != '' || nextRow != '';
        return ContinueResult.doBreak;
      };

      final sendRes = await send<bool>(null, sendPar, getRequest: getRequest);

      if (sendRes?.result != true) break;
    }
    return res;
  }

  // entity x table query
  AzureRequest _queryRequest({Query? query, Key? key /*, SendPar? sendPar*/}) {
    final uriAppend = key == null ? '()' : '(PartitionKey=\'${key.partition}\',RowKey=\'${key.row}\')';
    final queryString = key == null ? (query ?? Query()).queryString() : '';
    var uri = _uri[0] + uriAppend;
    if (queryString.isNotEmpty) uri += '?$queryString';
    final request = AzureRequest('GET', Uri.parse(uri));
    _sign(request.headers, uriAppend: uriAppend);
    request.headers['Accept'] = 'application/json;odata=nometadata';
    return request;
  }
}

class Account {
  const Account(this.account, this.key);
  final String account;
  final String key;
}

enum QO { eq, gt, ge, lt, le, ne }

class Q {
  Q(this.key, String? value, [QO? o])
      : o = o ?? QO.eq,
        value = _encodeValue(key, value);
  Q.p(String value, [QO? o]) : this('PartitionKey', value, o);
  Q.r(String value, [QO? o]) : this('RowKey', value, o);
  final String key;
  final String? value;
  final QO o;
  @override
  String toString() => '$key ${o.toString().split('.').last} \'$value\'';
  static String? _encodeValue(String key, String? value) {
    if (value == null) return null;
    if (key == 'PartitionKey' || key == 'RowKey') return Encoder.keys.encode(value);
    return value.replaceAll('\'', '\'\'');
  }
}

class Query {
  Query({String? filter, List<String>? select, int? top}) : this._(filter, select, top);
  Query.partition(String partitionKey, {int? top}) : this._('${Q.p(partitionKey)}', null, top);
  Query.property(String partitionKey, String rowKey, String propName) : this._('${Q.p(partitionKey)} and ${Q.r(rowKey)}', [propName], null);
  Query._(this._filter, this.select, this._top);
  final String? _filter;
  List<String>? select;
  final int? _top;

  String queryString() {
    final sb = StringBuffer();
    if (_filter != null) sb.write('\$filter=${Uri.encodeFull(_filter!)}');
    if (_top != null) {
      if (sb.length > 0) sb.write('&');
      sb.write('\$top=$_top');
    }
    if (select != null && select!.isNotEmpty) {
      if (sb.length > 0) sb.write('&');
      sb.write('\$select=');
      var first = true;
      for (final p in select!) {
        if (!first) sb.write(',');
        first = false;
        sb.write(p);
      }
    }
    return sb.toString();
  }
}
