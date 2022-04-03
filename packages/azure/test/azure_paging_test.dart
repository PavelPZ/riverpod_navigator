@Timeout(Duration(seconds: 3600))

import 'package:azure/azure.dart';
import 'package:test/test.dart';

import 'azure_lib.dart';

Future writeHuge(String tableName, String partitionKey) async {
  await tables.insert(tableName);
  final table = Table<RowData>(Azure.azureAccount(isEmulator), tableName, RowData.create);

  Future write100(int base) {
    final futures = Iterable.generate(100, (i) => table.insertOrReplace(RowData.fromKeys(partitionKey, 'r${base + i}')));
    return Future.wait(futures);
  }

  for (var i = 0; i < 21; i++) {
    await write100(i * 100);
  }
}

const tableName = 'huge';

void main() {
  group('paging', () {
    test('write huge', () async {
      await writeHuge(tableName, 'huge');
    }, skip: true);
    test('query huge', () async {
      final table = Table<RowData>(Azure.azureAccount(isEmulator), tableName, RowData.create);
      final q = await table.query(Query.partition('huge'));
      expect(q.length, 2100);
    }, skip: false);
  });
}
