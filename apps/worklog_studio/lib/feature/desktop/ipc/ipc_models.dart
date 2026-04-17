import 'dart:convert';
import 'package:worklog_studio/domain/time_entry.dart';

class TimerSnapshot {
  final bool isRunning;
  final TimeEntry? activeEntry;
  final List<TimeEntry> entries;
  final int timestamp; // Added to prevent out-of-order snapshots

  TimerSnapshot({
    required this.isRunning,
    this.activeEntry,
    required this.entries,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'isRunning': isRunning,
      'activeEntry': _timeEntryToJson(activeEntry),
      'entries': entries.map((e) => _timeEntryToJson(e)).toList(),
      'timestamp': timestamp,
    };
  }

  static TimerSnapshot fromJson(Map<String, dynamic> json) {
    return TimerSnapshot(
      isRunning: json['isRunning'] ?? false,
      activeEntry: _timeEntryFromJson(json['activeEntry']),
      entries: (json['entries'] as List?)
              ?.map((e) => _timeEntryFromJson(e))
              .whereType<TimeEntry>()
              .toList() ??
          [],
      timestamp: json['timestamp'] ?? 0,
    );
  }

  static Map<String, dynamic>? _timeEntryToJson(TimeEntry? entry) {
    if (entry == null) return null;
    return {
      'id': entry.id,
      'projectId': entry.projectId,
      'taskId': entry.taskId,
      'comment': entry.comment,
      'startAt': entry.startAt.toIso8601String(),
      'endAt': entry.endAt?.toIso8601String(),
      'status': entry.status == TimeEntryStatus.running ? 'running' : 'stopped',
    };
  }

  static TimeEntry? _timeEntryFromJson(dynamic json) {
    if (json == null) return null;
    return TimeEntry(
      id: json['id'],
      projectId: json['projectId'],
      taskId: json['taskId'],
      comment: json['comment'],
      startAt: DateTime.parse(json['startAt']),
      endAt: json['endAt'] != null ? DateTime.parse(json['endAt']) : null,
      status: json['status'] == 'running'
          ? TimeEntryStatus.running
          : TimeEntryStatus.stopped,
    );
  }
}

enum TimerActionType { start, stop }

class TimerAction {
  final TimerActionType type;
  final String? projectId;
  final String? taskId;
  final String? comment;

  TimerAction({
    required this.type,
    this.projectId,
    this.taskId,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type == TimerActionType.start ? 'start' : 'stop',
      'projectId': projectId,
      'taskId': taskId,
      'comment': comment,
    };
  }

  static TimerAction fromJson(Map<String, dynamic> json) {
    return TimerAction(
      type: json['type'] == 'start' ? TimerActionType.start : TimerActionType.stop,
      projectId: json['projectId'],
      taskId: json['taskId'],
      comment: json['comment'],
    );
  }
}
