import 'package:sqflite/sqflite.dart';
import 'package:worklog_studio/domain/time_entry.dart';
import 'package:worklog_studio/domain/time_tracker.dart';
import 'database_provider.dart';
import 'time_entry_mapper.dart';

class SqliteTimeEntryRepository implements TimeEntryRepository {
  static const _table = 'time_entries';

  Future<Database> get _db async => DatabaseProvider.getDatabase();

  @override
  Future<TimeEntry?> getActive() async {
    final db = await _db;

    final rows = await db.query(
      _table,
      where: 'status = ?',
      whereArgs: [TimeEntryStatus.running.name],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return TimeEntryMapper.fromMap(rows.first);
  }

  @override
  Future<List<TimeEntry>> getAll() async {
    final db = await _db;

    final rows = await db.query(_table, orderBy: 'start_at DESC');

    return rows.map(TimeEntryMapper.fromMap).toList();
  }

  @override
  Future<void> insert(TimeEntry entry) async {
    final db = await _db;

    await db.insert(
      _table,
      TimeEntryMapper.toMap(entry),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> update(TimeEntry entry) async {
    final db = await _db;

    final count = await db.update(
      _table,
      TimeEntryMapper.toMap(entry),
      where: 'id = ?',
      whereArgs: [entry.id],
    );

    if (count != 1) {
      throw StateError('TimeEntry not found: ${entry.id}');
    }
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
