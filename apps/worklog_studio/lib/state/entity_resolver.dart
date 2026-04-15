import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/domain/resolved_project.dart';
import 'package:worklog_studio/domain/resolved_task.dart';
import 'package:worklog_studio/domain/resolved_time_entry.dart';
import 'package:worklog_studio/domain/task.dart';
import 'package:worklog_studio/domain/time_entry.dart';
import 'package:worklog_studio/state/project_task_state.dart';
import 'package:worklog_studio/state/time_tracker_state.dart';

class EntityResolver extends ChangeNotifier {
  TimeTrackerState _timeTrackerState;
  ProjectTaskState _projectTaskState;

  EntityResolver({
    required TimeTrackerState timeTrackerState,
    required ProjectTaskState projectTaskState,
  })  : _timeTrackerState = timeTrackerState,
        _projectTaskState = projectTaskState {
    _timeTrackerState.addListener(notifyListeners);
    _projectTaskState.addListener(notifyListeners);
  }

  void update(TimeTrackerState timeTrackerState, ProjectTaskState projectTaskState) {
    if (_timeTrackerState != timeTrackerState) {
      _timeTrackerState.removeListener(notifyListeners);
      _timeTrackerState = timeTrackerState;
      _timeTrackerState.addListener(notifyListeners);
    }
    if (_projectTaskState != projectTaskState) {
      _projectTaskState.removeListener(notifyListeners);
      _projectTaskState = projectTaskState;
      _projectTaskState.addListener(notifyListeners);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timeTrackerState.removeListener(notifyListeners);
    _projectTaskState.removeListener(notifyListeners);
    super.dispose();
  }

  // --- TimeEntry Resolution ---

  ResolvedTimeEntry? getResolvedTimeEntry(String entryId) {
    final entry = _timeTrackerState.entries.firstWhereOrNull((e) => e.id == entryId);
    if (entry == null) return null;
    return _resolveTimeEntry(entry);
  }

  ResolvedTimeEntry _resolveTimeEntry(TimeEntry entry) {
    final task = entry.taskId != null
        ? _projectTaskState.tasks.firstWhereOrNull((t) => t.id == entry.taskId)
        : null;
    final project = entry.projectId != null
        ? _projectTaskState.projects.firstWhereOrNull((p) => p.id == entry.projectId)
        : null;
    return ResolvedTimeEntry(entry: entry, task: task, project: project);
  }

  List<ResolvedTimeEntry> getResolvedTimeEntries() {
    return _timeTrackerState.entries.map(_resolveTimeEntry).toList();
  }

  // --- Task Resolution ---

  ResolvedTask? getResolvedTask(String taskId) {
    final task = _projectTaskState.tasks.firstWhereOrNull((t) => t.id == taskId);
    if (task == null) return null;
    return _resolveTask(task);
  }

  ResolvedTask _resolveTask(Task task) {
    final project = task.projectId != null
        ? _projectTaskState.projects.firstWhereOrNull((p) => p.id == task.projectId)
        : null;
    final timeEntries = _timeTrackerState.entries.where((e) => e.taskId == task.id).toList();
    return ResolvedTask(task: task, project: project, timeEntries: timeEntries);
  }

  List<ResolvedTask> getResolvedTasks() {
    return _projectTaskState.tasks.map(_resolveTask).toList();
  }

  // --- Project Resolution ---

  ResolvedProject? getResolvedProject(String projectId) {
    final project = _projectTaskState.projects.firstWhereOrNull((p) => p.id == projectId);
    if (project == null) return null;
    return _resolveProject(project);
  }

  ResolvedProject _resolveProject(Project project) {
    final tasks = _projectTaskState.tasks
        .where((t) => t.projectId == project.id)
        .map(_resolveTask)
        .toList();
    final timeEntries = _timeTrackerState.entries
        .where((e) => e.projectId == project.id)
        .toList();
    return ResolvedProject(project: project, tasks: tasks, timeEntries: timeEntries);
  }

  List<ResolvedProject> getResolvedProjects() {
    return _projectTaskState.projects.map(_resolveProject).toList();
  }
}
