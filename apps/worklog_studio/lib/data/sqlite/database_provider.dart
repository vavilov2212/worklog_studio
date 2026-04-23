import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:l/l.dart';
import 'package:worklog_studio/core/environment/app_environment.dart';

import 'db_create.dart';

class DatabaseProvider {
  static const _dbName = 'worklog.db';
  static const _dbVersion = 2; // Incremented for migration

  static Database? _db;
  static Future<Database>? _initFuture;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    try {
      _initFuture ??= _initDb();
      _db = await _initFuture;
      return _db!;
    } catch (e) {
      _initFuture = null;
      rethrow;
    } finally {
      _initFuture = null;
    }
  }

  static Future<Database> _initDb() async {
    final flavor = appEnvironment.config.flavor;
    l.i(
      'DatabaseProvider: Bootstrapping DB for environment: ${flavor.appTitle}',
    );

    Directory baseDir;
    try {
      if (!kIsWeb &&
          (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
        baseDir = await getApplicationSupportDirectory();
      } else {
        final fallbackPath = await getDatabasesPath();
        baseDir = Directory(fallbackPath);
      }
    } catch (e) {
      l.w(
        'DatabaseProvider: Failed to get Application Support Directory. Error: $e',
      );
      final fallbackPath = await getDatabasesPath();
      baseDir = Directory(fallbackPath);
    }

    l.i('DatabaseProvider: Resolved base directory path: ${baseDir.path}');

    if (!kIsWeb && !await baseDir.exists()) {
      l.i(
        'DatabaseProvider: Directory does not exist. Creating recursively...',
      );
      await baseDir.create(recursive: true);
    }

    final path = join(baseDir.path, _dbName);
    l.i('DatabaseProvider: Final DB path: $path');

    final watch = Stopwatch()..start();

    Future<void> onCreateCallback(Database db, int version) async {
      l.i('DatabaseProvider: Creating database schema (v$version)...');
      await onCreate(db, version);
      l.i('DatabaseProvider: Database schema created successfully.');
    }

    Future<void> onUpgradeCallback(
      Database db,
      int oldVersion,
      int newVersion,
    ) async {
      l.i(
        'DatabaseProvider: Upgrading database from v$oldVersion to v$newVersion...',
      );
      await _onUpgrade(db, oldVersion, newVersion);
      l.i('DatabaseProvider: Database upgraded successfully.');
    }

    void onOpenCallback(Database db) {
      l.i(
        'DatabaseProvider: Database opened successfully in ${watch.elapsedMilliseconds}ms.',
      );
    }

    try {
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: onCreateCallback,
        onUpgrade: onUpgradeCallback,
        onOpen: onOpenCallback,
      );
    } catch (e, st) {
      l.e('DatabaseProvider: DB open failed, recreating...', st, {
        'error': e.toString(),
      });
      try {
        await deleteDatabase(path);
      } catch (deletionError) {
        l.e('DatabaseProvider: DB delete failed');
        l.e(deletionError);
      }
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: onCreateCallback,
        onUpgrade: onUpgradeCallback,
        onOpen: onOpenCallback,
      );
    }
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
