part of 'time_tracker_bloc.dart';

/// Представляет различные состояния блока управления таймером.
///
/// Использует Freezed для создания иммутабельных и типобезопасных состояний
/// с удобными методами `copyWith` и `when/map`.
@freezed
class TimeTrackerBlocState with _$TimeTrackerBlocState {
  const TimeTrackerBlocState._(); // Позволяет добавлять кастомные геттеры и методы

  /// Начальное состояние, когда нет загруженных данных и активного таймера.
  const factory TimeTrackerBlocState.idle() = _TimeTrackerIdleState;

  /// Состояние, когда идет загрузка записей времени из репозитория.
  const factory TimeTrackerBlocState.loading() = _TimeTrackerLoadingState;

  /// Состояние, когда записи времени успешно загружены, но таймер неактивен.
  const factory TimeTrackerBlocState.loaded({
    @Default([]) List<TimeEntry> entries, // Список всех загруженных записей
    TimeEntry? activeEntry, // Активная запись, если есть (но таймер не идет)
  }) = _TimeTrackerLoadedState;

  /// Состояние, когда таймер активно работает.
  ///
  /// Обязательно содержит `activeEntry` и список всех записей.
  const factory TimeTrackerBlocState.running({
    @Default([]) List<TimeEntry> entries, // Список всех загруженных записей
    required TimeEntry activeEntry, // Активная запись, таймер идет
  }) = _TimeTrackerRunningState;

  /// Состояние, когда произошла ошибка во время какой-либо операции.
  ///
  /// Может содержать предыдущие записи и активный таймер для контекста.
  const factory TimeTrackerBlocState.error({
    required Object errorHandler, // Объект ошибки для обработки
    @Default([]) List<TimeEntry> entries, // Предыдущие записи для контекста
    TimeEntry? activeEntry, // Предыдущая активная запись для контекста
  }) = _TimeTrackerErrorState;

  // ---------------------------------------------------------------------------
  // ВСПОМОГАТЕЛЬНЫЕ ГЕТТЕРЫ ДЛЯ УДОБНОГО ДОСТУПА К СОСТОЯНИЮ
  // ---------------------------------------------------------------------------

  /// Возвращает `true`, если таймер активно работает.
  bool get isRunning => this is _TimeTrackerRunningState;

  /// Возвращает активную запись времени, если она есть, иначе `null`.
  TimeEntry? get activeEntryOrNull {
    return when(
      idle: () => null,
      loading: () =>
          null, // Во время загрузки активной записи может не быть или она устарела
      loaded: (entries, activeEntry) => activeEntry,
      running: (entries, activeEntry) => activeEntry,
      error: (errorHandler, entries, activeEntry) => activeEntry,
    );
  }

  /// Возвращает все загруженные записи времени.
  /// Возвращает пустой список, если записи еще не загружены или состояние не применимо.
  List<TimeEntry> get allEntries {
    return when(
      idle: () => [],
      loading: () =>
          [], // Во время загрузки список может быть устаревшим или пустым
      loaded: (entries, activeEntry) => entries,
      running: (entries, activeEntry) => entries,
      error: (errorHandler, entries, activeEntry) => entries,
    );
  }
}
