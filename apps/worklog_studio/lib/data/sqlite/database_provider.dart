import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static const _dbName = 'worklog.db';
  static const _dbVersion = 1;

  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(path, version: _dbVersion, onCreate: _onCreate);

    return _db!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        archived_at INTEGER NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        completed_at INTEGER NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE time_entries (
        id TEXT PRIMARY KEY,
        project_id TEXT NULL,
        task_id TEXT NULL,
        comment TEXT NULL,
        start_at INTEGER NOT NULL,
        end_at INTEGER NULL,
        status TEXT NOT NULL
      );
    ''');

    await db.execute(
      'CREATE INDEX idx_time_entries_status ON time_entries(status);',
    );
    await db.execute(
      'CREATE INDEX idx_time_entries_start_at ON time_entries(start_at);',
    );
  }
}
