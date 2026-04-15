part of 'time_tracker_bloc.dart'; // Новый сгенерированный файл

/// Представляет все возможные события для блока управления таймером.
///
/// Использует Freezed для создания иммутабельных событий.
@freezed
sealed class TimeTrackerEvent with _$TimeTrackerEvent {
  const TimeTrackerEvent._();

  /// Событие для инициализации или перезагрузки всех записей времени.
  const factory TimeTrackerEvent.loaded() = TimeTrackerLoaded;

  /// Событие для начала новой записи времени.
  const factory TimeTrackerEvent.started({
    String? projectId,
    String? taskId,
    String? comment,
  }) = TimeTrackerStarted;

  /// Событие для остановки активной записи времени.
  const factory TimeTrackerEvent.stopped() = TimeTrackerStopped;

  /// Событие для обновления полей активной (запущенной) записи времени.
  const factory TimeTrackerEvent.activeEntryUpdated({
    String? projectId,
    String? taskId,
    String? comment,
  }) = TimeTrackerActiveEntryUpdated;

  /// Событие для удаления записи времени по её ID.
  const factory TimeTrackerEvent.entryDeleted(String id) =
      TimeTrackerEntryDeleted;

  /// Событие для создания новой записи времени.
  const factory TimeTrackerEvent.entryCreated(TimeEntry entry) =
      TimeTrackerEntryCreated;

  /// Событие для обновления существующей записи времени.
  const factory TimeTrackerEvent.entryUpdated(TimeEntry entry) =
      TimeTrackerEntryUpdated;
}
