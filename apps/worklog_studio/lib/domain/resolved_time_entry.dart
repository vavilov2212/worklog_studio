import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/domain/task.dart';
import 'package:worklog_studio/domain/time_entry.dart';

class ResolvedTimeEntry {
  final TimeEntry entry;
  final Task? task;
  final Project? project;

  const ResolvedTimeEntry({required this.entry, this.task, this.project});

  String get taskTitle => task?.title ?? 'Unassigned Task';
  String? get taskId => task?.id;
  String get projectName => project?.name ?? 'No Project';
  String? get projectId => project?.id;

  String get id => entry.id;
  bool get isRunning => entry.isRunning;
  DateTime get startAt => entry.startAt;
  DateTime? get endAt => entry.endAt;

  Duration duration(DateTime now) => entry.duration(now);

  ResolvedTimeEntry copyWith({TimeEntry? entry, Task? task, Project? project}) {
    return ResolvedTimeEntry(
      entry: entry ?? this.entry,
      task: task ?? this.task,
      project: project ?? this.project,
    );
  }
}
