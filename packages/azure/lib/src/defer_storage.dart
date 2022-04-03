import 'dart:async';
import 'dart:typed_data';

import 'package:tuple/tuple.dart';
import 'package:wikib_utils/wikb_utils.dart';

import 'azure.dart';
import 'model.dart';

class DeferItem {
  DeferItem(this.id, {this.day});
  // When added this fake old item to defers => PUT daily empty rows
  DeferItem.old() : this(daySensitiveRowsFlagId, day: 1);
  final int id;
  int version = Day.nowSecUtc;
  final int? day;
  bool get dayIsWrong => day != null && day != 0 && day != Day.nowEx;
  // max signed int, due protobuf
  static const daySensitiveRowsFlagId = 0x7fffffff;
}

abstract class DeferHook {
  Future<ContinueResult> onException(int e) => Future.value(ContinueResult.doRethrow);
  void preprocessDefers(ProxyDefers proxyDefers) => Future.value();

  Future setMsgVersion(int toInt, int version);
  DeferItem msgToDeferItem(dynamic msg) => throw Exception();
  DeferItem deferItemFromBytes(Uint8List bytes) => throw Exception();
  Uint8List deferItemToBytes(DeferItem item) => throw Exception();

  // bytes, rowKey, propName
  Tuple3<Uint8List, String, String> getFromStorage(int toInt, int version);

  Future onDeviceIdRowChanged() => Future.value();

  IFileCommon get localDeferFile;
  Table<DeferRowData> get table;
}

class DeferStorage {
  DeferStorage(this.hook);

  void setPartitionKey(String partitionKey) => this.partitionKey = partitionKey;

  late String partitionKey;
  final DeferHook hook;
  final _defers = <int, DeferItem>{};
  Map<int, DeferItem> get debugDefers => _defers;

  bool get defersIsEmpty => _defers.isEmpty;
  int get defersLength => _defers.length;

  Future<List<DeferRowData>> readAllFromRemote() => hook.table.query(Query.partition(partitionKey));
  Future writeAllToRemote(List<DeferRowData> rows) => hook.table.batchInsertOrReplace(partitionKey, rows);

  //***** flush
  // forceWrite: performs batchInsertOrMerge when defers.isEmpty (e.g. for deviceId row updating)
  void flushStart({String? debugId, bool? forceWrite, SendPar? sendPar}) => _flush(debugId, forceWrite, sendPar);
  Future flush({String? debugId, bool? forceWrite, SendPar? sendPar}) => _flush(debugId, forceWrite, sendPar);

  Future? _flushFuture;
  Future _flush(String? debugId, bool? forceWrite, SendPar? sendPar) async {
    if (_flushFuture != null) return _flushFuture;
    try {
      _flushFuture = _flushLow(forceWrite, debugId, sendPar);
      await _flushFuture;
    } finally {
      _flushFuture = null;
    }
  }

  Future _flushLow(bool? forceWrite, String? debugId, SendPar? sendPar) async {
    List<DeferRowData>? rows;
    ProxyDefers? proxyDefers;
    sendPar ??= SendPar();

    Future<AzureRequest?> getBatchRequest() async {
      proxyDefers = await _getDefers(forceWrite);
      if (proxyDefers == null) return null;
      assert(proxyDefers!.rows.values.length <= 100 && (dp('- $debugId: ${proxyDefers!.etags2.length}')));
      rows = List<DeferRowData>.from(proxyDefers!.rows.values);
      return hook.table.getBatchRequest(partitionKey, rows!, BatchMethod.merge);
    }

    while (true) {
      sendPar.finalizeResponse ??= (resp) async {
        // ********** cannot happends, check:
        // internet connection is checked just before SEND call. Call exception now:
        if (resp.error == ErrorCodes.noInternet) return ContinueResult.doRethrow;
        // canno happend: following errors are known after parsing batch response
        assert(resp.error != ErrorCodes.notFound || resp.error != ErrorCodes.eTagConflict);

        final continueResult = resp.standardResponseProcesed();
        if (continueResult != null) return Future.value(continueResult);

        // response OK:
        final respStr = await resp.response!.stream.bytesToString();
        resp.error = ErrorCodes.fromResponse(hook.table.finishBatchRows(respStr, rows!));
        if (resp.error == ErrorCodes.notFound || resp.error == ErrorCodes.eTagConflict) {
          return await hook.onException(resp.error);
        }
        if (resp.error != ErrorCodes.no) return ContinueResult.doRethrow;
        return ContinueResult.doBreak;
      };
      final sendRes = await hook.table.send<String>(null, sendPar, getRequest: getBatchRequest);

      if (hook.table.debugCanceled || sendRes == null) break;

      forceWrite = false;

      // actual eTag writed to deviceIdRow => notify in order to save this new tag to local file
      await hook.onDeviceIdRowChanged();

      assert(dpCounter('batch_rows', proxyDefers!.rows.values.length));
      await _undefer(proxyDefers!.etags2);
      assert(dp(debugId == null ? null : '** $debugId: ${proxyDefers!.etags2.length}'));
    }
  }

  Future<ProxyDefers?> _getDefers(bool? forceWrite) async {
    //if (!forceWrite && defersIsEmpty) return null;
    final proxies = <String, DeferRowData>{};
    final etags = <_ProxyETag>[];
    final now = Day.nowEx;
    final putDaySensitiveRows = _defers.values.any((item) => item.day != null && item.day != now);
    final res = ProxyDefers(proxies, etags, putDaySensitiveRows: putDaySensitiveRows);
    hook.preprocessDefers(res);
    for (final item in _defers.values) {
      if (item.dayIsWrong) continue;
      if (item.id == DeferItem.daySensitiveRowsFlagId) continue;
      final fromStorage = hook.getFromStorage(item.id, item.version); // bytes, rowKey, propName
      etags.add(_ProxyETag(toInt: item.id, version: item.version));
      final row = proxies.putIfAbsent(fromStorage.item2, () => DeferRowData(fromStorage.item2));
      row.setBinaryValue(fromStorage.item3, fromStorage.item1);
    }
    return forceWrite == true || etags.isNotEmpty ? res : null; // forceWrite != true && etags.isEmpty ? null : res;
  }

  Future _undefer(List<_ProxyETag> etags) async {
    // delete old
    for (final id in List<int>.from(_defers.keys)) {
      final item = _defers[id];
      if (item?.dayIsWrong == true) _defers.remove(id);
    }
    // delete all with correct eTag
    for (final d in etags) {
      final item = _defers[d.toInt];
      if (item == null) continue;
      if (item.version != d.version) {
        assert(dpCounter('deffer_etag_wrong'));
        continue;
      }
      _defers.remove(d.toInt);
      await hook.setMsgVersion(d.toInt, item.version);
      assert(dpCounter('deffer_etag_ok'));
    }
    // recreate defer file
    await defersToFile();
  }

  // DEFFER lib
  //***** lib
  Future defersFromFile() async {
    // if (hook.localDeferFile == null) return;
    _defers.clear();
    final bytess = await hook.localDeferFile.platformReads().toList();
    for (final item in bytess.map((bytes) => hook.deferItemFromBytes(bytes))) {
      _defers[item.id] = item;
    }
  }

  Future defersToFile() {
    //if (hook.localDeferFile == null) return Future.value();
    if (defersIsEmpty) return hook.localDeferFile.platformDelete();

    Iterable<Uint8List> getItems() sync* {
      for (final item in _defers.values) {
        yield hook.deferItemToBytes(item);
      }
    }

    return hook.localDeferFile.platformAppends(getItems(), recreate: true);
  }

  Future deferClear() {
    _defers.clear();
    //return hook.localDeferFile == null ? Future.value() : hook.localDeferFile.platformDelete();
    return hook.localDeferFile.platformDelete();
  }

  DeferItem setDeferedLow(dynamic msg) {
    final res = hook.msgToDeferItem(msg);
    return _defers[res.id] = res;
  }

  Future setDefered(dynamic msg) => _toLocal(setDeferedLow(msg));

  Future putDaySensitiveRowsFlag() {
    final res = DeferItem.old();
    return _toLocal(_defers[res.id] = res);
  }

  Future _toLocal(DeferItem item) {
    //if (hook.localDeferFile == null) return Future.value();
    return hook.localDeferFile.platformAppend(hook.deferItemToBytes(item));
  }

  // new daylies creted
  Future setDayliesDefered(Iterable<dynamic> msgs) async {
    // azure batchMerge "PUT"'s empty rows with Day sensitive data
    await putDaySensitiveRowsFlag();
    // add to defers and to file
    final list = <Uint8List>[]; //hook.localDeferFile == null ? null : [];
    for (final item in msgs.map((m) => hook.msgToDeferItem(m))) {
      // final item = setDeferedLow2(id, hasDay: true);
      //if (item == null) continue;
      //if (list != null)
      list.add(hook.deferItemToBytes(item));
    }
    /*if (list != null)*/ await hook.localDeferFile.platformAppends(list);
  }
}

class _ProxyETag {
  _ProxyETag({this.toInt = 0, this.version = 0});
  final int version;
  final int toInt;
}

class ProxyDefers {
  ProxyDefers(this.rows, this.etags2, {this.putDaySensitiveRows = false});
  final Map<String, DeferRowData> rows;
  final List<_ProxyETag> etags2;
  final bool putDaySensitiveRows;
  bool get isNotEmpty => rows.isNotEmpty;
}

class DeferRowData extends RowData {
  DeferRowData(String rowKey) : super.forBatch(rowKey);
  DeferRowData.fromMap(Map<String, dynamic> data) : super.fromMap(data);
  static DeferRowData create(Map<String, dynamic> map) => DeferRowData.fromMap(map);
}

// 1 099 511 627 775 =  FFFF FFFF miliseconds from 1.1.2020 is 34 years
// https://stackoverflow.com/questions/31687376/what-is-the-max-value-of-integer-in-dart
// 9 007 199 254 740 992 = 20 0000 0000 0000 = 2^53
//String utcDateToString(DateTime date) => date.millisecondsSinceEpoch.toString().padLeft(13, '0');
// int _getETag() => Day.nowEx;
