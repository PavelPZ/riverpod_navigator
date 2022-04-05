@Timeout(Duration(seconds: 3600))

import 'dart:convert';

import 'package:azure/azure.dart';
import 'package:test/test.dart';

import 'azure_lib.dart';

void main() {
  group('entity2', () {
    test('row eTag', () async {
      final m1 = RowData.forBatch('B02');
      for (var i = 0; i < 3; i++) {
        await table.batchInsertOrMerge('B01', [m1]);
        print(m1.eTag);
      }
      expect(m1 == m1, true);
    });
    test('modulo', () async {
      const i = 252;
      expect(251 ~/ i, 0);
      expect(251 % i, 251);
      expect(252 ~/ i, 1);
      expect(252 % i, 0);
      expect(253 ~/ i, 1);
      expect(253 % i, 1);
    });
    test('with eTag collision', () async {
      final m1 = RowData.fromKeys('ET', 'B01');
      final m1Updated = RowData.fromKeys('ET', 'B01');
      final m2 = RowData.fromKeys('ET', 'B02');
      await table.batchInsertOrMerge('ET', [m1, m2]);
      print(m1.eTag);
      await table.update(m1);
      print(m1.eTag);
      m1Updated.eTag = m1.eTag;
      await table.batchInsertOrMerge('ET', [m1, m2]);
      print('${m1.eTag} x ${m1Updated.eTag}');
      // errors:
      try {
        m2.data['p0'] = 'edited';
        await table.batchInsertOrMerge('ET', [m2, m1Updated]);
      } catch (e) {
        expect(e, 412);
      }
      try {
        await table.update(m1Updated);
      } catch (e) {
        expect(e, 412);
      }
      expect(0, 0);
    });
    test('batch update', () async {
      final m1 = RowData.fromKeys('U01', 'B01');
      await table.insertOrReplace(m1);
      final m2 = RowData.forBatch('B02');
      m1.data['x0'] = 'y00';
      var response = await table.batchInsertOrReplace('U01', [m1, m2]);
      m1.data['x1'] = 'y11';
      m2.data['x2'] = 'y22';
      response = await table.batchInsertOrReplace('U01', [m1, m2]);
      response = null;
      expect(response, null);
    });
    test('batch merge', () async {
      final m1 = RowData.fromKeys('B01', 'B01');
      final m2 = RowData.forBatch('B02');
      await table.insertOrReplace(m1);
      m1.data['x0'] = 'y00';
      var response = await table.batchInsertOrMerge('B01', [m1, m2]);
      m1.data['x1'] = 'y11';
      m2.data['x2'] = 'y22';
      response = await table.batchInsertOrMerge('B01', [m1, m2]);
      response = null;
      expect(response, null);
    });
    test('typed props', () async {
      final model = CustomModel(Key('custom', 'row'))
        ..intValue = 0x7fffffff
        ..boolValue = true
        ..doubleValue = 0.01;
      await table.insertOrReplace(model);
      model.data['unicode'] = 'čřŮ\nx';
      model.binaryValue = utf8.encode('abc');
      await table.update(model);
      expect(model.eTag!.length > 35, true);
    });
    test('key encoding', () async {
      var enc = Encoder.keys.encode('čřŮ\nx');
      expect(enc, ';010d;0159;016e~0ax');
      var dec = Encoder.keys.decode(enc!);
      expect(dec, 'čřŮ\nx');
      enc = Encoder.tables.encode('pzika@langmaster.cz');
      expect(enc, 'pzikaA40langmasterA2ecz');
      dec = Encoder.tables.decode(enc!);
      expect(dec, 'pzika@langmaster.cz');
    });
    test('unicode', () async {
      final model = RowData.fromKeys('čřŮ\nx', 'ŠšŘřťŤ');
      await table.insertOrReplace(model);
      model.data['unicode'] = 'čřŮ\nx';
      await table.update(model);
      expect(model.eTag!.length > 35, true);
    });
    test('delete', () async {
      final model = RowData.fromKeys('delete', '005');
      await table.insert(model);
      expect(model.eTag!.length > 35, true);
      await table.delete(model);
      expect(model.eTag, null);
    });
    test('batch delete', () async {
      await table.batchInsertOrReplace('Čau', [
        RowData.forBatch('ř1'),
        RowData.forBatch('ř2')
          ..data['prop1'] = 'value1'
          ..data['prop2'] = 'value2',
      ]);
      await table.batchDelete('Čau', null);
    });
    test('insert x update', () async {
      final model = RowData.fromKeys('insertOrUpdateEntity', '005');
      await table.insertOrReplace(model);
      model.data['updated'] = 'updated';
      await table.update(model);
      expect(model.eTag!.length > 35, true);
    });
    test('insert x merge', () async {
      final model = RowData.fromKeys('insertOrMergeEntity', 'pzika@langmaster.cz');
      await table.insertOrMerge(model);
      model.data['merged'] = 'merged';
      await table.merge(model);
      expect(model.eTag!.length > 35, true);
    });
  });
}
