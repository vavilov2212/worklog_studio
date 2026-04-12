import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/domain/task.dart';
import 'package:worklog_studio/domain/time_tracker.dart';

class ProjectTaskState extends ChangeNotifier {
  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final Clock _clock;
  final Uuid _uuid = const Uuid();

  List<Project> _projects = [];
  List<Task> _tasks = [];

  ProjectTaskState({
    required ProjectRepository projectRepository,
    required TaskRepository taskRepository,
    required Clock clock,
  }) : _projectRepository = projectRepository,
       _taskRepository = taskRepository,
       _clock = clock {
    _init();
  }

  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  Future<void> _init() async {
    await loadData();
  }

  Future<void> loadData() async {
    _projects = await _projectRepository.getAll();
    _tasks = await _taskRepository.getAll();
    notifyListeners();
  }

  Future<Project> createProject(String name, String description) async {
    final project = Project(
      id: _uuid.v4(),
      name: name,
      description: description,
      status: ProjectStatus.open,
      createdAt: _clock.now(),
    );
    await _projectRepository.insert(project);
    await loadData();
    return project;
  }

  Future<Task> createTask(
    String projectId,
    String title,
    String description,
  ) async {
    final task = Task(
      id: _uuid.v4(),
      projectId: projectId,
      title: title,
      description: description,
      status: TaskStatus.open,
      createdAt: _clock.now(),
    );
    await _taskRepository.insert(task);
    await loadData();
    return task;
  }

  Future<void> updateProject(Project project) async {
    await _projectRepository.update(project);
    await loadData();
  }

  Future<void> updateTask(Task task) async {
    await _taskRepository.update(task);
    await loadData();
  }

  Future<void> deleteProject(String id) async {
    await _projectRepository.delete(id);
    await loadData();
  }

  Future<void> deleteTask(String id) async {
    await _taskRepository.delete(id);
    await loadData();
  }
}
