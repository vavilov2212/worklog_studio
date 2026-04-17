import 'package:worklog_studio/domain/project.dart';
import 'package:worklog_studio/domain/resolved_task.dart';
import 'package:worklog_studio/domain/time_entry.dart';

class ResolvedProject {
  final Project project;
  final List<ResolvedTask> tasks;
  final List<TimeEntry> timeEntries;

  const ResolvedProject({
    required this.project,
    this.tasks = const [],
    this.timeEntries = const [],
  });

  String get id => project.id;
  String get name => project.name;
  String get description => project.description;
  ProjectStatus get status => project.status;
  DateTime get createdAt => project.createdAt;

  Duration duration(DateTime now) {
    return timeEntries.fold(
      Duration.zero,
      (prev, entry) => prev + entry.duration(now),
    );
  }
}
