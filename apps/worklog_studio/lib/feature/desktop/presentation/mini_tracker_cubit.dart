import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worklog_studio/domain/time_entry.dart';
import 'package:worklog_studio/feature/desktop/ipc/ipc_models.dart';
import 'package:worklog_studio/core/services/desktop/desktop_service.dart';

class MiniTrackerState {
  final bool isRunning;
  final TimeEntry? activeEntry;
  final List<TimeEntry> allEntries;
  final int lastTimestamp;

  const MiniTrackerState({
    this.isRunning = false,
    this.activeEntry,
    this.allEntries = const [],
    this.lastTimestamp = 0,
  });

  MiniTrackerState copyWith({
    bool? isRunning,
    TimeEntry? activeEntry,
    List<TimeEntry>? allEntries,
    int? lastTimestamp,
  }) {
    return MiniTrackerState(
      isRunning: isRunning ?? this.isRunning,
      activeEntry: activeEntry ?? this.activeEntry,
      allEntries: allEntries ?? this.allEntries,
      lastTimestamp: lastTimestamp ?? this.lastTimestamp,
    );
  }
}

class MiniTrackerCubit extends Cubit<MiniTrackerState> {
  MiniTrackerCubit() : super(const MiniTrackerState());

  void updateFromSnapshot(TimerSnapshot snapshot) {
    if (snapshot.timestamp < state.lastTimestamp) {
      // Discard older snapshot
      return;
    }
    emit(state.copyWith(
      isRunning: snapshot.isRunning,
      activeEntry: snapshot.activeEntry,
      allEntries: snapshot.entries,
      lastTimestamp: snapshot.timestamp,
    ));
  }

  void startTimer({String? projectId, String? taskId, String? comment}) {
    // Avoid double-sending if UI reflects already running
    if (state.isRunning) return; 

    DesktopService().dispatchAction(TimerAction(
      type: TimerActionType.start,
      projectId: projectId,
      taskId: taskId,
      comment: comment,
    ));
  }

  void stopTimer() {
    if (!state.isRunning) return;

    DesktopService().dispatchAction(TimerAction(
      type: TimerActionType.stop,
    ));
  }
}
