import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'db_create.dart';

class DatabaseProvider {
  static const _dbName = 'worklog.db';
  static const _dbVersion = 2; // Incremented for migration

  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: onCreate,
      onUpgrade: _onUpgrade,
    );

    return _db!;
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        '''CREATE UNIQUE INDEX IF NOT EXISTS idx_single_running_entry 
           ON time_entries(status) 
           WHERE status = 'running';''',
      );
    }
  }
}
