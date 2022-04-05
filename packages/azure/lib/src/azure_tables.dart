part of 'azure.dart';

class Tables extends Azure {
  Tables({bool? isEmulator}) : super._('tables', isEmulator: isEmulator);

  Future<List<String>> query(Query? query) async {
    final res = await queryLow(query);
    return List<String>.from(res.map((map) => map['TableName']));
  }

  // https://docs.microsoft.com/en-us/rest/api/storageservices/delete-table
  // Note that deleting a table is likely to take at least 40 seconds to complete.
  // If an operation is attempted against the table while it was being deleted, the service returns status code 409 (Conflict),
  Future delete(String tableName) {
    return _writeBytesRequest(null, 'DELETE', uriAppend: '(\'$tableName\')');
    // final now = DateTime.now();
    // while (true) {
    //   await Future.delayed(Duration(seconds: 5));
    //   if (!await exists(tableName)) break;
    //   if (DateTime.now().difference(now).inSeconds > 45) throw Exception();
    // }
  }

  Future<bool> exists(String tableName) async {
    final all = await query(Query(filter: '${Q('TableName', '$tableName')}'));
    assert(all.length <= 1);
    return all.length == 1;
  }

  Future recreate(String tableName) async {
    try {
      await delete(tableName);
      await Future.delayed(Duration(seconds: 10));
    } catch (e) {}
    await forceInsert(tableName);
  }

  Future<String?> insert(String tableName) => _writeBytesRequest(utf8.encode(jsonEncode({'TableName': tableName})), 'POST',
      finishHttpRequest: (req) => req.headers['Prefer'] = 'return-no-content');

  Future forceInsert(String tableName) async {
    final start = DateTime.now();
    while (true) {
      try {
        if (await exists(tableName)) break;
        await insert(tableName);
      } catch (e) {
        if (e != ErrorCodes.conflict) rethrow;
        //if (e.isNot(AzureErrors.conflict)) rethrow;
        //if (e.reasonPhrase != 'Conflict') rethrow;
      }
      await Future.delayed(Duration(seconds: 5));
      if (DateTime.now().difference(start) > _forceInsertLimit) {
        throw Exception('Azure table recreate limit exceeded');
      }
    }
  }

  static const _forceInsertLimit = Duration(seconds: 80);
}
