// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';

// // import 'package:azure/azure.dart';
// import 'package:tuple/tuple.dart';

// import 'azure.dart';
// import 'defer_storage.dart';

// class DebugMessage {
//   DebugMessage(this.id, {this.day});
//   final Uint8List data = _bytes;
//   List<int> writeToBuffer() => data;
//   int? version;
//   final int id;
//   final int? day;
//   bool get hasDay => day != null;
// }

// final _bytes = Uint8List.fromList(utf8.encode(''.padLeft(40, '0')));
// const NORMAL = 1;
// const DAILY = 2;

// String dailyRowKey(int id) => '!${id ~/ 252}';

// class DebugService extends DeferHook {
//   DebugService(Account account, String partitionKey) : table = Table<DeferRowData>(account, 'users', DeferRowData.create) {
//     rstorage = DebugStorage(this);
//     rstorage.setPartitionKey(partitionKey);
//   }
//   @override
//   final Table<DeferRowData> table;
//   DebugStorage? rstorage;

//   @override
//   Tuple3<Uint8List, String, String> getFromStorage(int toInt, int version) {
//     final msg = _items[toInt];
//     if (msg == null) return null;
//     final proxyId = fromIntLow(toInt);
//     final propName = 'p${proxyId.item2 % 252}';
//     final rowKey = '${proxyId.item1 == DAILY ? '!' : '*'}${proxyId.item2 ~/ 252}';
//     return Tuple3<Uint8List, String, String>(msg.data, rowKey, propName);
//   }

//   @override
//   IFileCommon get localDeferFile => null;

//   @override
//   Future preprocessDefers(ProxyDefers proxyDefers) async {
//     if (!proxyDefers.putDaySensitiveRows) return;
//     proxyDefers.rows['!0'] = DeferRowData('!0')..batchMethod = BatchMethod.put;
//     proxyDefers.rows['!1'] = DeferRowData('!1')..batchMethod = BatchMethod.put;
//   }

//   @override
//   Future setMsgVersion(int toInt, int version) {
//     final msg = _items[toInt];
//     assert(msg != null);
//     msg.version = version;
//     return Future.value();
//   }

//   @override
//   DeferItem msgToDeferItem(dynamic msg) {
//     final DebugMessage m = msg;
//     return DeferItem(m.id, day: m.day);
//   }

//   final _items = <int, DebugMessage>{};

//   Future<DebugMessage> add(int id, {bool hasDay}) async {
//     final msg = _items[id] = DebugMessage(id, day: Day.nowEx);
//     await rstorage.update(msg);
//     return msg;
//   }

//   DebugMessage addSync(int id, {bool hasDay}) {
//     final msg = _items[id] = DebugMessage(id, day: Day.nowEx);
//     rstorage.debugUpdate(msg);
//     return msg;
//   }
// }

// class DebugStorage extends DeferStorage {
//   DebugStorage(DeferHook hook) : super(hook);

//   void debugUpdate(DebugMessage msg) {
//     setDeferedLow(msg);
//   }

//   Future update(DebugMessage msg) {
//     return setDefered(msg);
//   }

//   // @override
//   // Tuple2<String, String> getAzureRowAndPropNames(AzureProxy proxy) => throw UnimplementedError();

//   // //********** DUE TO DAILY LIKE DEFERS */

//   // @override
//   // AzureProxy defferIdToStorage(ProxyId deferId) => throw UnimplementedError();

//   // @override
//   // Future preprocessDefers(ProxyDefers proxyDefers) => throw UnimplementedError();
// }
