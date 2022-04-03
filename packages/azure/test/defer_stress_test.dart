@Timeout(Duration(seconds: 3600))

import 'dart:math';

import 'package:azure/azure.dart';
import 'package:test/test.dart';
import 'package:wikib_utils/wikb_utils.dart';

const isEmulator = false;

final tables = AzureTables(Azure.azureAccount(isEmulator));
final random = Random();

Future testProcSimple() => dpDate(() async {
      dpCounterReset();
      final now = DateTime.now();
      await _testProc(9999);
      setTestResult('${dbCounterDump()}\n${DateTime.now().difference(now)}');
    });

Future _testProc(int userId) async {
  final services = DebugService(Azure.azureAccount(isEmulator), 'conn$userId');
  final defers = services.rstorage; // DebugStorage(Azure.azureAccount(isEmulator), 'conn$userId');

  Future flush(int id) {
    services.addSync(id);
    // ignore: unused_local_variable
    final fake = defers.flush(debugId: '$userId.$id');
    return Future.delayed(Duration(milliseconds: random.nextInt(1000)));
  }

  for (var i = 0; i < 500; i++) {
    final ii = i << 1; // i*2
    await flush(ii);
    await flush(ii + (random.nextInt(20) == 10 ? 0 : 1));

    dpCounter('_testProc_count', 2);
  }
}

DebugService createDefers(int userId) => DebugService(Azure.azureAccount(isEmulator), 'user2$userId');
Table<T> _create<T extends RowData>(CreateFromMap<T> createFromMap) => Table<T>(Azure.azureAccount(isEmulator), 'users', createFromMap);

final helper = _create<RowData>(RowData.create);

Future testProcMultiUser() => dpDate(() async {
      dpCounterReset();
      final now = DateTime.now();
      final futures = Iterable.generate(100, (i) => _testProc(i));
      await Future.wait(futures);
      setTestResult('${dbCounterDump()}\n${DateTime.now().difference(now)}');
    });

Future runWrite(int userId, {int randomValue = 20000}) async {
  final services = createDefers(userId);
  for (var i = 0; i < 25200; i++) {
    services.addSync(i);
  }
  try {
    await Future.delayed(Duration(milliseconds: random.nextInt(randomValue)));
    await services.rstorage.flush(debugId: userId.toString(), sendPar: SendPar.init(retries: DebugRetries(randomValue: randomValue)));
  } catch (e) {}
}

Future runRead(int userId) async {
  final partition = 'user$userId';
  try {
    await helper.query(Query.partition(partition));
    print(partition);
  } catch (e) {
    print('*** $partition');
  }
}

class DebugRetries extends IRetries {
  DebugRetries({this.randomValue = 20000});
  final _random = Random();
  final int randomValue;
  @override
  int nextMSec() => _random.nextInt(randomValue);
}

void main() {
  group('deffer stress', () {
    test('recreateTable', () async {
      try {
        await tables.delete('users');
        await Future.delayed(Duration(seconds: 40));
      } catch (e) {}
      await tables.insert('users');
    }, skip: true);

    test('simple', () async {
      await testProcSimple();
    }, skip: true);

    test('multi user', () async {
      await testProcMultiUser();
    }, skip: true);

    test('defer 100 * 25200 props (every 40 bytes)', () async {
      dpCounterReset();
      final now = DateTime.now();
      await Future.wait(Iterable.generate(100, (i) => runWrite(i, randomValue: 60000)));
      setTestResult('${dbCounterDump()}\n${DateTime.now().difference(now)}');
    }, skip: true);

    test('read 100* 25200 props', () async {
      dpCounterReset();
      final now = DateTime.now();
      await Future.wait(Iterable.generate(100, (i) => runRead(i)));
      // 0:00:08.410752, 100/0
      setTestResult('${dbCounterDump()}\n${DateTime.now().difference(now)}');
    }, skip: true);

    test('write 100000 x small writes', () async {
      dpCounterReset();
      final now = DateTime.now();

      Future testUser(int userId, int i, DebugService services) async {
        await Future.delayed(Duration(milliseconds: random.nextInt(20000)));
        // defers.addSync(random.nextInt(5000));
        //await defers.add(random.nextInt(5000));
        await services.add(i * 10);
        await services.rstorage.flush(debugId: '$userId.$i');
      }

      await Future.wait(Iterable.generate(250, (userId) async {
        final defers = createDefers(userId);
        await Future.delayed(Duration(milliseconds: random.nextInt(10000)));
        await Future.wait(Iterable.generate(400, (i) => testUser(userId, i, defers)));
      }));
      setTestResult('${dbCounterDump()}\n${DateTime.now().difference(now)}');
    }, skip: true);
    /**
deffer_etag_wrong=1625,
flush_attempts=10355,
flush_undefers=115835,
flush_rows_attempts=38172,
send_attempts=10355,
flush_ignore=91590,
flush_etag_ok=91678,
flush_rows=32601,
flush_etag_changed=785,
send_errors=2134,
send_errors 1225=2134,
send_errors 121=0,
send_errors others=0,
flush_error=1945,

0:02:52.413093
       */
  });
}
