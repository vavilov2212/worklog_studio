enum ProjectStatus { open, done, archived }

class Project {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime? archivedAt;

  // UI fields (defaulted for now)
  final String clientName;
  final double totalHours;
  final double budgetUtilization;
  final ProjectStatus status;
  final double billableAmount;
  final double averageRate;
  final double budgetLeft;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.archivedAt,
    this.clientName = 'Unknown Client',
    this.totalHours = 0.0,
    this.budgetUtilization = 0.0,
    this.status = ProjectStatus.open,
    this.billableAmount = 0.0,
    this.averageRate = 0.0,
    this.budgetLeft = 0.0,
  });

  Project copyWith({
    String? name,
    String? description,
    ProjectStatus? status,
    DateTime? archivedAt,
    String? clientName,
    double? totalHours,
    double? budgetUtilization,
    double? billableAmount,
    double? averageRate,
    double? budgetLeft,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      clientName: clientName ?? this.clientName,
      totalHours: totalHours ?? this.totalHours,
      budgetUtilization: budgetUtilization ?? this.budgetUtilization,
      status: status ?? this.status,
      billableAmount: billableAmount ?? this.billableAmount,
      averageRate: averageRate ?? this.averageRate,
      budgetLeft: budgetLeft ?? this.budgetLeft,
    );
  }

  bool get isArchived => archivedAt != null;
}

abstract class ProjectRepository {
  Future<List<Project>> getAll();
  Future<Project?> getById(String id);
  Future<void> insert(Project project);
  Future<void> update(Project project);
  Future<void> delete(String id);
}
