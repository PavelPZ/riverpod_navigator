import 'dart:async';

Map<String, int>? _dbCounter;
var _dpIgnore = false;

void dpCounterInit([bool dpIgnore = true]) {
  _dpIgnore = dpIgnore;
  _dbCounter = dpIgnore ? null : <String, int>{};
}

//typedef DpCounter = bool Function(String key, [int count]);
bool dpCounter(String key, [int? count]) {
  if (_dbCounter != null) {
    count ??= 1;
    _dbCounter!.update(key, (value) => _dbCounter![key] = value + count!, ifAbsent: () => count!);
  }
  return true;
}

Future<bool> dpActionDuration(Future action()) async {
  if (_dpIgnore != true) return true;
  final d = DateTime.now();
  await action();
  final dur = DateTime.now().difference(d);
  print('Duration: ${dur.toString()}');
  return true;
}

String dbCounterDump() {
  if (_dbCounter == null) return '';
  final sb = StringBuffer();
  for (final kv in _dbCounter!.entries) {
    sb.writeln('${kv.key}=${kv.value}, ');
  }
  return sb.toString();
}

bool dpMsg(String? msg) {
  if (msg != null && _dpIgnore != true) print(msg);
  return true;
}
