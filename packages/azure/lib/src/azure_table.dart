part of 'azure.dart';

typedef CreateFromMap<T extends RowData> = T Function(Map<String, dynamic> map);

class Table<T extends RowData> extends Azure {
  Table(String table, {bool? isEmulator, this.createFromMap = RowData.create}) : super._(table, isEmulator: isEmulator); // azure server

  Future<List<T>> query(Query query, {SendPar? sendPar}) async {
    final res = await queryLow(query, sendPar: sendPar);
    return List<T>.from(res.map((map) => createFromMap(map)));
  }

  final CreateFromMap createFromMap;

  Future<T?> read(Key key, {SendPar? sendPar}) async {
    final tup = await readLow(key, sendPar: sendPar);
    final res = tup == null ? null : (createFromMap(tup.item1)..eTag = tup.item2);
    return res as T?;
  }

  Future<Tuple2<Map<String, dynamic>, String>?> readLow(Key key, {SendPar? sendPar}) async {
    final request = _queryRequest(key: key);

    final res = await send<Tuple2<Map<String, dynamic>, String>>(
        request: request,
        sendPar: sendPar,
        finalizeResponse: (resp) async {
          if (resp.error == ErrorCodes.notFound) return ContinueResult.doBreak; // => doBreak with null result
          if (resp.error != ErrorCodes.no) return ContinueResult.doRethrow;
          final json = await resp.response!.stream.bytesToString();
          final map = jsonDecode(json);
          resp.result = Tuple2<Map<String, dynamic>, String>(map, resp.response!.headers['etag']!);
          return ContinueResult.doBreak;
        });
    return res!.result;
  }

  // rethrowExceptionDuringSend=true => response.statusCode == 500 or 503 raises exception
  // used in Defers._flush
  Future batchInsertOrMerge(String partitionKey, List<RowData> data, {SendPar? sendPar}) => runBatch(partitionKey, data, BatchMethod.merge, sendPar);

  Future batchInsertOrReplace(String partitionKey, List<RowData> data, {SendPar? sendPar}) => runBatch(partitionKey, data, BatchMethod.put, sendPar);

  Future batchDelete(String partitionKey, Query? query, {SendPar? sendPar}) async {
    query ??= Query.partition(partitionKey);
    query.select = <String>['RowKey'];
    final res = await queryLow(query);
    if (res.isEmpty) return null;
    final data = List<RowData>.from(res.map((m) => RowData.fromMap({'RowKey': m['RowKey']})..eTag = '*'));
    return runBatch(partitionKey, data, BatchMethod.delete, sendPar);
  }

  Future insert(T data) async =>
      data.eTag = await _writeBytesRequest(data.toJsonBytes(), 'POST', finishHttpRequest: (req) => req.headers['Prefer'] = 'return-no-content');

  Future insertOrReplace(T data) => _writeRowRequest(data, 'PUT');
  Future insertOrMerge(T data) => _writeRowRequest(data, 'MERGE');
  Future update(T data) => _writeRowRequest(data, 'PUT');
  Future merge(T data) => _writeRowRequest(data, 'MERGE');
  Future delete(T data) => _writeRowRequest(data, 'DELETE');

  //************* BATCH */
  AzureRequest getBatchRequest(String partitionKey, List<RowData> data, BatchMethod defaultMethod) {
    final request = AzureRequest('POST', Uri.parse(_uri[1]));
    _sign(request.headers, idx: 1);

    final batch = Batch(partitionKey, request, batchInnerUri!, defaultMethod);
    for (var i = 0; i < data.length; i++) {
      batch.appendData(data[i]..batchDataId = i);
    }
    request.bodyBytes = batch.getBody();
    return request;
  }

  int finishBatchRows(String res, List<RowData> data) {
    final rowResponses = List<ResponsePart>.from(ResponsePart.parseResponse(res));
    var code = 0;
    for (final resp in rowResponses) {
      final row = data[int.parse(resp.headers['Content-ID'] ?? '9999')];
      row.batchResponse = resp;
      row.eTag = resp.headers['ETag'];
      code = max(code, resp.statusCode);
    }
    return code;
  }

  Future runBatch(String partitionKey, List<RowData> data, BatchMethod defaultMethod, SendPar? sendPar) async {
    for (var i = 0; i < data.length; i += 100) {
      final request = getBatchRequest(
        partitionKey,
        List<RowData>.from(data.skip(i).take(100)),
        defaultMethod,
      );
      final sendRes = await send<String>(
          request: request,
          sendPar: sendPar,
          finalizeResponse: (resp) async {
            if (resp.error != ErrorCodes.no) return ContinueResult.doRethrow;
            // reponse OK, parse response string:
            final respStr = await resp.response!.stream.bytesToString();
            resp.error = ErrorCodes.computeStatusCode(finishBatchRows(respStr, data));
            if (resp.error != ErrorCodes.no) return ContinueResult.doRethrow;
            resp.result = respStr;
            return ContinueResult.doBreak;
          });
      if (sendRes!.error >= 400) throw sendRes;
    }
  }
}

class Batch {
  Batch(String partitionKey, this._request, this._innerBatchUri, this._defaultMethod) : partitionKey = Encoder.keys.encode(partitionKey)! {
    _request.headers['Content-Type'] = 'multipart/mixed; boundary=$_batchId';
    _sb.writeln('--$_batchId');
    _sb.writeln('Content-Type: multipart/mixed; boundary=$_changesetId');
    _sb.writeln();
  }
  final String partitionKey;
  final BatchMethod _defaultMethod;
  final AzureRequest _request;
  final String _innerBatchUri;
  final String _batchId = 'batch_${_nextId()}';
  final String _changesetId = 'changeset_${_nextId()}';
  final _sb = StringBuffer();
  void appendData(RowData data) {
    _sb.writeln('--$_changesetId');
    _sb.writeln('Content-Type: application/http');
    _sb.writeln('Content-Transfer-Encoding: binary');
    _sb.writeln();
    final method = data.batchMethod ?? _defaultMethod;
    final methodName = batchMethodName[method];
    _sb.writeln('$methodName $_innerBatchUri${data.batchKeyUrlPart(partitionKey)} HTTP/1.1');
    if (data.eTag != null) _sb.writeln('If-Match: ${data.eTag}');
    _sb.writeln('Content-ID: ${data.batchDataId}');
    _sb.writeln('Accept: application/json;odata=nometadata');
    _sb.writeln('Content-Type: application/json');
    // if (data.eTag != null) _sb.writeln('ETag: ${data.eTag}');
    //assert((method == 'DELETE') == (data == null));
    if (method != BatchMethod.delete) {
      _sb.writeln();
      _sb.writeln(data.toJson());
    } else {
      _sb.writeln('Content-Length: 0');
      _sb.writeln();
    }
  }

  List<int> getBody() {
    final str = _getBodyStr();
    final res = utf8.encode(str);
    final len = res.length;
    // https://support.microsoft.com/cs-cz/help/4016806/the-request-body-is-too-large-error-when-writing-data-to-azure-file
    if (len > 4000000) throw Exception('Azure request limit');
    return res;
  }

  String _getBodyStr() {
    _sb.writeln('--$_changesetId--');
    _sb.writeln('--$_batchId--');
    return _sb.toString();
  }

  // static final _uuid = Uuid();
  // static String _nextId() => _uuid.v4();
  static var _uuid = 0;
  static String _nextId() => (_uuid++).toString();
}
