import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/domain/task.dart';
import 'package:worklog_studio/domain/time_entry.dart';

class ResolvedTask {
  final Task task;
  final Project? project;
  final List<TimeEntry> timeEntries;

  const ResolvedTask({
    required this.task,
    this.project,
    this.timeEntries = const [],
  });

  String get id => task.id;
  String get title => task.title;
  String get description => task.description;
  String? get projectId => task.projectId;
  TaskStatus get status => task.status;
  DateTime get createdAt => task.createdAt;

  String get projectName => project?.name ?? 'No Project';

  Duration duration(DateTime now) {
    return timeEntries.fold(
      Duration.zero,
      (prev, entry) => prev + entry.duration(now),
    );
  }
}
