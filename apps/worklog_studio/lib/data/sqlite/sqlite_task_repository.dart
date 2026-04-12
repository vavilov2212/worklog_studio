import 'package:sqflite/sqflite.dart';
import 'package:worklog_studio/domain/task.dart';
import 'database_provider.dart';

class SqliteTaskRepository implements TaskRepository {
  static const _table = 'tasks';

  Future<Database> get _db async => DatabaseProvider.getDatabase();

  Task _fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: TaskStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> _toMap(Task task) {
    return {
      'id': task.id,
      'project_id': task.projectId,
      'title': task.title,
      'description': task.description,
      'status': task.status.name,
      'created_at': task.createdAt.millisecondsSinceEpoch,
      'completed_at': task.completedAt?.millisecondsSinceEpoch,
    };
  }

  @override
  Future<List<Task>> getAll() async {
    final db = await _db;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<List<Task>> getByProjectId(String projectId) async {
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromMap).toList();
  }

  @override
  Future<Task?> getById(String id) async {
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  @override
  Future<void> insert(Task task) async {
    final db = await _db;
    await db.insert(
      _table,
      _toMap(task),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> update(Task task) async {
    final db = await _db;
    final count = await db.update(
      _table,
      _toMap(task),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    if (count != 1) {
      throw StateError('Task not found: ${task.id}');
    }
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
