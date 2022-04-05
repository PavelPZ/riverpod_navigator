@Timeout(Duration(seconds: 3600))

import 'package:azure/azure2.dart';
import 'package:test/test.dart';

import 'azure_lib2.dart';

void main() {
  group('tables', () {
    test('recreate', () async {
      await tables.forceInsert('testtable');
      await tables.recreate('testtable');
      await tables.delete('testtable');
    }, skip: true);
    test('create and delete', () async {
      await tables.forceInsert('testtable');
      var exists = await tables.exists(tableName);
      expect(exists, true);

      await tables.delete('testtable');
      exists = await tables.exists(tableName);
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
