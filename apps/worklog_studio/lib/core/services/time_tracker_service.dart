import 'package:uuid/uuid.dart';
import 'package:worklog_studio/domain/time_entry.dart';
import 'package:worklog_studio/domain/time_tracker.dart';

class TimeTrackerService {
  final TimeEntryRepository repository;
  final Clock clock;
  final Uuid _uuid = const Uuid();

  TimeTrackerService({required this.repository, required this.clock});

  Future<TimeEntry?> getActive() {
    return repository.getActive();
  }

  Future<List<TimeEntry>> getAll() async {
    return await repository.getAll();
  }

  Future<TimeEntry> start({
    String? projectId,
    String? taskId,
    String? comment,
  }) async {
    final active = await repository.getActive();
    if (active != null) {
      stop();
    }

    final entry = TimeEntry(
      id: _uuid.v4(),
      projectId: projectId,
      taskId: taskId,
      comment: comment,
      startAt: clock.now(),
      status: TimeEntryStatus.running,
    );

    repository.insert(entry);
    return entry;
  }

  Future<TimeEntry> stop() async {
    final active = await repository.getActive();
    if (active == null) {
      throw StateError('No active timer to stop');
    }

    final now = clock.now();

    final stopped = active.copyWith(
      endAt: now,
      status: TimeEntryStatus.stopped,
    );

    repository.update(stopped);
    return stopped;
  }

  Future<TimeEntry> updateActive({
    String? projectId,
    String? taskId,
    String? comment,
    DateTime? startAt,
  }) async {
    final active = await repository.getActive();
    if (active == null) {
      throw StateError('No active timer to update');
    }

    final updated = active.copyWith(
      projectId: projectId,
      taskId: taskId,
      comment: comment,
      startAt: startAt,
    );

    repository.update(updated);
    return updated;
  }

  Future<void> deleteEntry(String id) async {
    await repository.delete(id);
  }

  Future<void> createEntry(TimeEntry entry) async {
    await repository.insert(entry);
  }

  Future<void> updateEntry(TimeEntry entry) async {
    await repository.update(entry);
  }
}
