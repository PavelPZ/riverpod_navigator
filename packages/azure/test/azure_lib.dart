@Timeout(Duration(seconds: 3600))

import 'dart:math';

import 'package:azure/azure.dart';
import 'package:test/test.dart';

const isEmulator = false;

const tableName = 'users';

Table<T> _create<T extends RowData>(CreateFromMap<T> createFromMap) => Table<T>(tableName, isEmulator: isEmulator, createFromMap: createFromMap);

final table = _create<RowData>(RowData.create);
final customTable = _create<CustomModel>(CustomModel.create);
// final deferHelper = _create<DeferRowData>(DeferRowData.create);
final tables = Tables(isEmulator: isEmulator);

final random = Random();

var batchOK = 0;
var batchError = 0;

class CustomModel extends RowData {
  CustomModel(Key key) : super(key);

  CustomModel.fromMap(Map<String, dynamic> data) : super.fromMap(data);
  static CustomModel create(Map<String, dynamic> map) => CustomModel.fromMap(map);

  int get intValue => data['IntValue'];
  set intValue(int value) => data['IntValue'] = value;

  bool get boolValue => data['BoolValue'];
  set boolValue(bool value) => data['BoolValue'] = value;

  double get doubleValue => data['DoubleValue'];
  set doubleValue(double value) => data['DoubleValue'] = value;

  List<int> get binaryValue => getBinaryValue('BinaryValue')!;
  set binaryValue(List<int> value) => setBinaryValue('BinaryValue', value);
}
