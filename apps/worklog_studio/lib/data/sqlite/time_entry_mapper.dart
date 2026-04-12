import 'package:worklog_studio/domain/time_entry.dart';

class TimeEntryMapper {
  static Map<String, Object?> toMap(TimeEntry entry) {
    return {
      'id': entry.id,
      'project_id': entry.projectId,
      'task_id': entry.taskId,
      'comment': entry.comment,
      'start_at': entry.startAt.millisecondsSinceEpoch,
      'end_at': entry.endAt?.millisecondsSinceEpoch,
      'status': entry.status.name,
    };
  }

  static TimeEntry fromMap(Map<String, Object?> map) {
    return TimeEntry(
      id: map['id'] as String,
      projectId: map['project_id'] as String?,
      taskId: map['task_id'] as String?,
      comment: map['comment'] as String?,
      startAt: DateTime.fromMillisecondsSinceEpoch(map['start_at'] as int),
      endAt: map['end_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_at'] as int)
          : null,
      status: TimeEntryStatus.values.byName(map['status'] as String),
    );
  }
}
