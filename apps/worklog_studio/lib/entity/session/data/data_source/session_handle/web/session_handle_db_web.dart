import 'package:idb_shim/idb_browser.dart';
import 'package:worklog_studio/entity/session/domain/i_session_handle_db.dart';
import 'package:worklog_studio/entity/session/session_handle.dart';

class SessionHandleDbWeb implements SessionHandleDb {
  static const _dbName = 'sessions_db';
  static const _storeName = 'sessions';

  late final Future<Database> _db = _openDb();

  Future<Database> _openDb() async {
    final factory = getIdbFactory()!;
    return factory.open(
      _dbName,
      version: 1,
      onUpgradeNeeded: (event) {
        final db = event.database;
        db.createObjectStore(_storeName, keyPath: 'id');
      },
    );
  }

  @override
  Future<void> save(SessionHandle session) async {
    final db = await _db;
    final txn = db.transaction(_storeName, idbModeReadWrite);
    final store = txn.objectStore(_storeName);

    await store.put({
      'id': session.id,
      'title': session.title,
      'createdAt': session.createdAt.toIso8601String(),
    });

    await txn.completed;
  }

  @override
  Future<List<SessionHandle>> getAll() async {
    final db = await _db;
    final txn = db.transaction(_storeName, idbModeReadOnly);
    final store = txn.objectStore(_storeName);

    final result = <SessionHandle>[];

    await for (final cursor in store.openCursor()) {
      final value = cursor.value as Map;

      result.add(
        SessionHandle(
          id: value['id'],
          title: value['title'],
          createdAt: DateTime.parse(value['createdAt']),
        ),
      );
      cursor.next();
    }

    return result;
  }

  @override
  Future<SessionHandle?> getById(String id) async {
    final db = await _db;
    final txn = db.transaction(_storeName, idbModeReadOnly);
    final store = txn.objectStore(_storeName);

    final value = await store.getObject(id) as Map?;
    if (value == null) return null;

    return SessionHandle(
      id: value['id'],
      title: value['title'],
      createdAt: DateTime.parse(value['createdAt']),
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    final txn = db.transaction(_storeName, idbModeReadWrite);
    await txn.objectStore(_storeName).delete(id);
    await txn.completed;
  }
}
