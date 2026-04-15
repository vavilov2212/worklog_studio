import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/domain/resolved_project.dart';
import 'package:worklog_studio/domain/resolved_task.dart';
import 'package:worklog_studio/domain/resolved_time_entry.dart';
import 'package:worklog_studio/domain/task.dart';
import 'package:worklog_studio/domain/time_entry.dart';
import 'package:worklog_studio/feature/time_tracker/bloc/time_tracker_bloc.dart';
import 'package:worklog_studio/state/project_task_state.dart';

class EntityResolver extends ChangeNotifier {
  TimeTrackerBlocState _timeTrackerBlocState;
  ProjectTaskState _projectTaskState;
  StreamSubscription<TimeTrackerBlocState>? _subscription;

  EntityResolver({
    required TimeTrackerBloc bloc,
    required ProjectTaskState projectTaskState,
  }) : _timeTrackerBlocState = bloc.state,
       _projectTaskState = projectTaskState {
    _projectTaskState.addListener(notifyListeners);
    _subscription = bloc.stream.listen((state) {
      _timeTrackerBlocState = state;
      notifyListeners();
    });
  }

  void update(TimeTrackerBloc bloc, ProjectTaskState projectTaskState) {
    _timeTrackerBlocState = bloc.state;
    if (_projectTaskState != projectTaskState) {
      _projectTaskState.removeListener(notifyListeners);
      _projectTaskState = projectTaskState;
      _projectTaskState.addListener(notifyListeners);
    }
    // We don't need to notify here because the stream listener handles it
    // but we do it once for the initial update if needed.
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _projectTaskState.removeListener(notifyListeners);
    super.dispose();
  }

  // --- TimeEntry Resolution ---

  ResolvedTimeEntry? getResolvedTimeEntry(String entryId) {
    final entry = _timeTrackerBlocState.allEntries.firstWhereOrNull(
      (e) => e.id == entryId,
    );
    if (entry == null) return null;
    return _resolveTimeEntry(entry);
  }

  ResolvedTimeEntry _resolveTimeEntry(TimeEntry entry) {
    final task = entry.taskId != null
        ? _projectTaskState.tasks.firstWhereOrNull((t) => t.id == entry.taskId)
        : null;
    final project = entry.projectId != null
        ? _projectTaskState.projects.firstWhereOrNull(
            (p) => p.id == entry.projectId,
          )
        : null;
    return ResolvedTimeEntry(entry: entry, task: task, project: project);
  }

  List<ResolvedTimeEntry> getResolvedTimeEntries() {
    return _timeTrackerBlocState.allEntries.map(_resolveTimeEntry).toList();
  }

  // --- Task Resolution ---

  ResolvedTask? getResolvedTask(String taskId) {
    final task = _projectTaskState.tasks.firstWhereOrNull(
      (t) => t.id == taskId,
    );
    if (task == null) return null;
    return _resolveTask(task);
  }

  ResolvedTask _resolveTask(Task task) {
    final project = task.projectId != null
        ? _projectTaskState.projects.firstWhereOrNull(
            (p) => p.id == task.projectId,
          )
        : null;
    final timeEntries = _timeTrackerBlocState.allEntries
        .where((e) => e.taskId == task.id)
        .toList();
    return ResolvedTask(task: task, project: project, timeEntries: timeEntries);
  }

  List<ResolvedTask> getResolvedTasks() {
    return _projectTaskState.tasks.map(_resolveTask).toList();
  }

  // --- Project Resolution ---

  ResolvedProject? getResolvedProject(String projectId) {
    final project = _projectTaskState.projects.firstWhereOrNull(
      (p) => p.id == projectId,
    );
    if (project == null) return null;
    return _resolveProject(project);
  }

  ResolvedProject _resolveProject(Project project) {
    final tasks = _projectTaskState.tasks
        .where((t) => t.projectId == project.id)
        .map(_resolveTask)
        .toList();
    final timeEntries = _timeTrackerBlocState.allEntries
        .where((e) => e.projectId == project.id)
        .toList();
    return ResolvedProject(
      project: project,
      tasks: tasks,
      timeEntries: timeEntries,
    );
  }

  List<ResolvedProject> getResolvedProjects() {
    return _projectTaskState.projects.map(_resolveProject).toList();
  }
}
