@Timeout(Duration(seconds: 3600))

import 'dart:math';

import 'package:azure/azure.dart';
import 'package:test/test.dart';
import 'package:wikib_utils/wikb_utils.dart';

const isEmulator = false;

Table<T> _create<T extends RowData>(CreateFromMap<T> createFromMap) =>
    Table<T>(Azure.azureAccount(isEmulator), 'users', createFromMap: createFromMap);

final helper = _create<RowData>(RowData.create);
final tables = Tables(Azure.azureAccount(isEmulator));
final random = Random();

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

Future runWrite(int userId, {int randomValue = 20000}) async {
  final services = createDefers(userId);
  for (var i = 0; i < 25200; i++) {
    services.addSync(i);
  }
  try {
    await Future.delayed(Duration(milliseconds: random.nextInt(randomValue)));
    await services.rstorage.flush(debugId: userId.toString(), sendPar: SendPar(retries: DebugRetries(randomValue: randomValue)));
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

Future testProcSimple() => dpActionDuration(() async {
      dpCounterInit();
      final now = DateTime.now();
      await _testProc(9999);
      dpMsg('${dbCounterDump()}\n${DateTime.now().difference(now)}');
    });

Future testProcMultiUser() => dpActionDuration(() async {
      dpCounterInit();
      final now = DateTime.now();
      final futures = Iterable.generate(100, (i) => _testProc(i));
      await Future.wait(futures);
      dpMsg('${dbCounterDump()}\n${DateTime.now().difference(now)}');
    });

class DebugRetries extends IRetries {
  DebugRetries({this.randomValue = 20000});
  final _random = Random();
  final int randomValue;
  @override
  int nextMSec() => _random.nextInt(randomValue);
}
