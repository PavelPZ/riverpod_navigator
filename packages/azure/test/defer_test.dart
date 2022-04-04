@Timeout(Duration(seconds: 3600))

import 'package:azure/azure.dart';
import 'package:test/test.dart';
import 'package:wikib_utils/wikb_utils.dart';

const isEmulator = false;

Future runTest(int userId, Future action(DebugService st, String getDebugId(int id))) async {
  final st = DebugService(Azure.azureAccount(isEmulator), 'defer_$userId');
  Day.mockSet(null);
  mockConnection = null;
  dpCounterInit();
  await action(st, (id) => '$userId.$id');
  dpMsg('${dbCounterDump()}');
}

void main() {
  group('deffer', () {
    test('7 daily no inet', () async {
      return runTest(7, (st, getDebugId) async {
        mockConnection = true;
        Day.mockSet(1);
        await st.rstorage.putDaySensitiveRowsFlag();
        st.addSync(503);
        final f = st.rstorage.flush(debugId: getDebugId(0));
        await Future.delayed(Duration(seconds: 1));

        Day.mockSet(2);
        await st.rstorage.putDaySensitiveRowsFlag();
        st.addSync(251);
        mockConnection = false;
        await f;
      });
    });
    test('6 daily change day', () async {
      return runTest(6, (st, getDebugId) async {
        Day.mockSet(1);
        await st.rstorage.putDaySensitiveRowsFlag();
        st.addSync(503);
        await st.rstorage.flush(debugId: getDebugId(0));

        Day.mockSet(2);
        await st.rstorage.putDaySensitiveRowsFlag();
        st.addSync(251);
        await st.rstorage.flush(debugId: getDebugId(0));
      });
    });
    test('5 daily setFakeNow', () async {
      return runTest(5, (st, getDebugId) async {
        await st.rstorage.putDaySensitiveRowsFlag();
        await st.rstorage.flush(debugId: getDebugId(0));
      });
    });
    test('4 daily simple', () async {
      return runTest(4, (st, getDebugId) async {
        st.addSync(
          0,
        );
        await st.rstorage.flush(debugId: getDebugId(0));
      });
    });
    test('3 internet error', () async {
      return runTest(3, (st, getDebugId) async {
        st.addSync(0);

        mockConnection = true;
        final fu = st.rstorage.flush(debugId: getDebugId(0));
        await Future.delayed(Duration(microseconds: 1));
        expect(st.rstorage.defersLength, 1);

        mockConnection = false;
        await Future.delayed(Duration(seconds: 1));
        await fu; // retry => wait e.g. 30 seconds for next _flush
        expect(st.rstorage.defersLength, 0);
      });
    });
    test('2 eTag wrong', () async {
      return runTest(2, (st, getDebugId) async {
        final proxy = st.addSync(0);
        final f = st.rstorage.flush(debugId: getDebugId(2));
        await Future.delayed(Duration(milliseconds: 1));
        await st.rstorage.update(proxy);
        await f;
      });
    });
    test('12 update during flush', () async {
      return runTest(12, (st, getDebugId) async {
        final v = <int>[];

        final msg = await st.add(0);
        v.add(msg.version!); // 0..null
        await st.rstorage.flush(debugId: getDebugId(0));
        v.add(msg.version!); // 1: v1 writed

        await Future.delayed(Duration(seconds: 2));
        await st.rstorage.update(msg);
        v.add(st.rstorage.debugDefers[0]!.version); // 2: v2
        final f = st.rstorage.flush(debugId: getDebugId(0), forceWrite: false, sendPar: SendPar.init(debugWriteWaitMsec: 3000));
        v.add(msg.version!); // 3: still v1, flush not finished

        await Future.delayed(Duration(seconds: 2));
        await st.rstorage.update(msg);
        v.add(st.rstorage.debugDefers[0]!.version); // 4: v3
        v.add(msg.version!); // 5: v1, still v1
        await f;
        v.add(msg.version!); // 6: v3, flush finished

        print(v);
        expect(v[1] == v[3] && v[3] == v[5] && v[2] != v[4] && v[4] == v[6], true);
        expect(st.rstorage.defersLength, 0);
      });
    });
    test('11 versions', () async {
      return runTest(11, (st, getDebugId) async {
        final msg = await st.add(0);
        final v = <int>[];
        v.add(msg.version!);
        await st.rstorage.flush(debugId: getDebugId(0));
        v.add(msg.version!);
        await st.rstorage.update(msg);
        await st.rstorage.flush(debugId: getDebugId(0));
        v.add(msg.version!);
        print(v);
        expect(st.rstorage.defersLength, 0);
      });
    });
    test('1 simple', () async {
      return runTest(1, (st, getDebugId) async {
        st.addSync(0);
        await st.rstorage.flush(debugId: getDebugId(0));
        expect(st.rstorage.defersLength, 0);
      });
    });
  });
}
