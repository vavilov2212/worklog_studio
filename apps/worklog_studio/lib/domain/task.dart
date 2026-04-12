enum TaskStatus { open, done, archived }

class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  Task copyWith({
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isCompleted => status == TaskStatus.done;
}

abstract class TaskRepository {
  Future<List<Task>> getAll();
  Future<List<Task>> getByProjectId(String projectId);
  Future<Task?> getById(String id);
  Future<void> insert(Task task);
  Future<void> update(Task task);
  Future<void> delete(String id);
}
