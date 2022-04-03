@Timeout(Duration(seconds: 3600))

import 'package:azure/azure.dart';
import 'package:test/test.dart';
import 'package:wikib_utils/wikb_utils.dart';

import 'azure_lib.dart';

void main() {
  group('query', () {
    test('no inet', () async {
      await helper.batchInsertOrReplace('Q01', [RowData.forBatch('R01'), RowData.forBatch('R02')]);

      // not expired
      mockConnection = false;
      final fres3 = helper.read(
        Key('Q01', 'R02'),
        sendPar: SendPar.init(waitForConnectionPar: WaitForConnectionPar(1, 3)),
      );
      await Future.delayed(Duration(seconds: 2));
      mockConnection = true;
      final res3 = await fres3;
      expect(res3!.rowKey, 'R02');

      // expired
      mockConnection = false;
      try {
        await helper.read(
          Key('Q01', 'R02'),
          sendPar: SendPar.init(waitForConnectionPar: WaitForConnectionPar(1, 2)),
        );
        expect(false, true);
      } catch (err) {
        expect(err, 600);
      }
      mockConnection = true;
    });
    test('key query', () async {
      await helper.batchInsertOrReplace('Q01', [RowData.forBatch('R01'), RowData.forBatch('R02')]);
      final res = await helper.read(Key('Q01', 'R02'));
      expect(res != null, true);
      final res2 = await helper.read(Key('Q01x', 'R02'));
      expect(res2 == null, true);
    });
    test('partition query', () async {
      await helper.batchInsertOrReplace('Čau', [
        RowData.forBatch('ř1'),
        RowData.forBatch('ř2')
          ..data['prop1'] = 'value1'
          ..data['prop2'] = 'value2',
      ]);
      var res = await helper.query(Query.partition('Čau'));
      expect(res.length, 2);
      final ent = await helper.read(Key('Čau', 'ř2'));
      expect(ent!.data['prop1'] == 'value1' && ent.data['prop2'] == 'value2', true);
      res = await helper.query(Query.property('Čau', 'ř2', 'prop1'));
      expect(res[0].data['prop1'] == 'value1' && res[0].data['prop2'] == null, true);
    });
    test('filter', () async {
      await helper.batchInsertOrReplace('Q01', [RowData.forBatch('R01'), RowData.forBatch('R02')]);
      var res = await helper.query(Query(filter: '${Q.p('Q01')} and ${Q.r('R01', QO.gt)}'));
      expect(res.length, 1);
      expect(res[0].rowKey, 'R02');
      res = await helper.query(Query(filter: '${Q.p('Q01')}'));
      expect(res.length, 2);
    });
  });
}
