import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:worklog_studio/core/services/time_tracker_service.dart';
import 'package:worklog_studio/domain/time_entry.dart';
import 'package:worklog_studio/domain/time_tracker.dart';

class TimeTrackerState extends ChangeNotifier {
  final TimeTrackerService _service;
  final Clock _clock;

  TimeEntry? _activeEntry;
  Duration _elapsed = Duration.zero;

  Timer? _ticker;

  TimeTrackerState({required TimeTrackerService service, required Clock clock})
    : _service = service,
      _clock = clock {
    _init();
  }

  // ------------------
  // Public API
  // ------------------
  List<TimeEntry> _entries = [];
  List<TimeEntry> get entries => _entries;
  TimeEntry? get activeEntry => _activeEntry;
  Duration get elapsed => _elapsed;
  bool get isRunning => _activeEntry?.isRunning ?? false;

  Future<void> start({
    String? projectId,
    String? taskId,
    String? comment,
  }) async {
    _activeEntry = await _service.start(
      projectId: projectId,
      taskId: taskId,
      comment: comment,
    );
    await loadEntries();

    _startTicker();
    notifyListeners();
  }

  Future<void> stop() async {
    if (_activeEntry == null) return;

    await _service.stop();
    await loadEntries();

    _stopTicker();

    _activeEntry = null;
    _elapsed = Duration.zero;

    notifyListeners();
  }

  Future<void> updateActive({
    String? projectId,
    String? taskId,
    String? comment,
  }) async {
    if (_activeEntry == null) return;

    _activeEntry = await _service.updateActive(
      projectId: projectId,
      taskId: taskId,
      comment: comment,
    );

    await loadEntries();

    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    await _service.deleteEntry(id);
    await loadEntries();
  }

  Future<void> createEntry(TimeEntry entry) async {
    await _service.createEntry(entry);
    await loadEntries();
  }

  Future<void> updateEntry(TimeEntry entry) async {
    await _service.updateEntry(entry);
    await loadEntries();
  }

  // ------------------
  // Internal
  // ------------------

  Future<void> _init() async {
    await loadEntries();
    final active = await _service.getActive();
    if (active == null) return;

    _activeEntry = active;
    _recalculateElapsed();
    _startTicker();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _recalculateElapsed();
      notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _recalculateElapsed() {
    if (_activeEntry == null) {
      _elapsed = Duration.zero;
      return;
    }

    _elapsed = _clock.now().difference(_activeEntry!.startAt);
  }

  Duration? calculateDuration(DateTime startAt, DateTime? endAt) {
    if (endAt == null) return null;
    return endAt.difference(startAt);
  }

  Future<void> loadEntries() async {
    _entries = await _service.getAll();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
