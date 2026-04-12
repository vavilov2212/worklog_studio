import 'package:sqflite/sqflite.dart';
import 'package:worklog_studio/domain/project.dart';
import 'database_provider.dart';

class SqliteProjectRepository implements ProjectRepository {
  static const _table = 'projects';

  Future<Database> get _db async => DatabaseProvider.getDatabase();

  Project _fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      archivedAt: map['archived_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['archived_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> _toMap(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'description': project.description,
      'created_at': project.createdAt.millisecondsSinceEpoch,
      'archived_at': project.archivedAt?.millisecondsSinceEpoch,
    };
  }

  @override
  Future<List<Project>> getAll() async {
    final db = await _db;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map(_fromMap).toList();
  }

  @override
  Future<Project?> getById(String id) async {
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
  Future<void> insert(Project project) async {
    final db = await _db;
    await db.insert(
      _table,
      _toMap(project),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> update(Project project) async {
    final db = await _db;
    final count = await db.update(
      _table,
      _toMap(project),
      where: 'id = ?',
      whereArgs: [project.id],
    );
    if (count != 1) {
      throw StateError('Project not found: ${project.id}');
    }
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
