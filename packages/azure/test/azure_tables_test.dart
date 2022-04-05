@Timeout(Duration(seconds: 3600))

import 'package:azure/azure.dart';
import 'package:test/test.dart';

import 'azure_lib.dart';

const testtableName = 'testtable';

void main() {
  group('tables', () {
    test('recreate', () async {
      await tables.forceInsert(testtableName);
      await tables.recreate(testtableName);
      await tables.delete(testtableName);
    }, skip: true);
    test('create and delete', () async {
      await tables.forceInsert(testtableName);
      var exists = await tables.exists(tableName);
      expect(exists, true);

      await tables.delete(testtableName);
      exists = await tables.exists(testtableName);
      expect(exists, false);
    }, skip: true);
    test('query all', () async {
      final all = await tables.query(null);
      expect(all.length >= 2, true);
    });
    test('query filter', () async {
      final all = await tables.query(Query(filter: '${Q('TableName', 'u', QO.gt)}'));
      expect(all.isNotEmpty, true);
    });
  });
}
