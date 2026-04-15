import 'dart:developer' as developer;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'db_create.dart';

class DatabaseProvider {
  static const _dbName = 'worklog.db';
  static const _dbVersion = 1;

  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dir = await getApplicationSupportDirectory();
    final path = join(dir.path, _dbName);

    // ЛОГИРОВАНИЕ ПУТИ
    developer.log(
      'DATABASE INITIALIZED',
      name: 'worklog.database',
      error: 'Path: $path',
    );

    _db = await openDatabase(path, version: _dbVersion, onCreate: onCreate);

    return _db!;
  }
}
