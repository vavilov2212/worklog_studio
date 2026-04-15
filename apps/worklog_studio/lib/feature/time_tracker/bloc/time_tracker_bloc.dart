import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worklog_studio/core/services/time_tracker_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:worklog_studio/domain/time_entry.dart';

part 'time_tracker_bloc.freezed.dart'; // <-- Генерируемый файл Freezed
part 'time_tracker_event.dart'; // <-- Часть определения событий
part 'time_tracker_state.dart'; // <-- Часть определения состояний

class TimeTrackerBloc extends Bloc<TimeTrackerEvent, TimeTrackerBlocState> {
  final TimeTrackerService _service;

  TimeTrackerBloc({required TimeTrackerService service})
    : _service = service,
      super(const TimeTrackerBlocState.idle()) {
    // <-- ИСПРАВЛЕНО: Начальное состояние
    on<TimeTrackerLoaded>(_onLoaded);
    on<TimeTrackerStarted>(_onStarted);
    on<TimeTrackerStopped>(_onStopped);
    on<TimeTrackerActiveEntryUpdated>(_onActiveEntryUpdated);
    on<TimeTrackerEntryDeleted>(_onEntryDeleted);
    on<TimeTrackerEntryCreated>(_onEntryCreated);
    on<TimeTrackerEntryUpdated>(_onEntryUpdated);
  }

  Future<void> _onLoaded(
    TimeTrackerLoaded event,
    Emitter<TimeTrackerBlocState> emit,
  ) async {
    emit(const TimeTrackerBlocState.loading()); // <-- ИСПРАВЛЕНО
    try {
      final entries = await _service.getAll();
      final active = await _service.getActive();

      if (active != null) {
        emit(
          TimeTrackerBlocState.running(entries: entries, activeEntry: active),
        ); // <-- ИСПРАВЛЕНО
      } else {
        emit(TimeTrackerBlocState.loaded(entries: entries)); // <-- ИСПРАВЛЕНО
      }
    } on Object catch (e) {
      // <-- ИСПРАВЛЕНО: Обработка ошибок
      emit(
        TimeTrackerBlocState.error(
          errorHandler: e,
          entries: state.allEntries, // <-- ИСПРАВЛЕНО
          activeEntry: state.activeEntryOrNull, // <-- ИСПРАВЛЕНО
        ),
      );
    }
  }

  Future<void> _onStarted(
    TimeTrackerStarted event,
    Emitter<TimeTrackerBlocState> emit,
  ) async {
    try {
      final active = await _service.start(
        projectId: event.projectId,
        taskId: event.taskId,
        comment: event.comment,
      );
      final entries = await _service.getAll();

      emit(
        TimeTrackerBlocState.running(entries: entries, activeEntry: active),
      ); // <-- ИСПРАВЛЕНО
    } on Object catch (e) {
      // <-- ИСПРАВЛЕНО
      emit(
        TimeTrackerBlocState.error(
          errorHandler: e,
          entries: state.allEntries,
          activeEntry: state.activeEntryOrNull,
        ),
      );
    }
  }

  Future<void> _onStopped(
    TimeTrackerStopped event,
    Emitter<TimeTrackerBlocState> emit,
  ) async {
    try {
      await _service.stop();
      final entries = await _service.getAll();

      emit(TimeTrackerBlocState.loaded(entries: entries)); // <-- ИСПРАВЛЕНО
    } on Object catch (e) {
      // <-- ИСПРАВЛЕНО
      emit(
        TimeTrackerBlocState.error(
          errorHandler: e,
          entries: state.allEntries,
          activeEntry: state.activeEntryOrNull,
        ),
      );
    }
  }

  Future<void> _onActiveEntryUpdated(
    TimeTrackerActiveEntryUpdated event,
    Emitter<TimeTrackerBlocState> emit,
  ) async {
    if (state.activeEntryOrNull == null) return; // <-- ИСПРАВЛЕНО
    try {
      final active = await _service.updateActive(
        projectId: event.projectId,
        taskId: event.taskId,
        comment: event.comment,
      );
      final entries = await _service.getAll();

      emit(
        TimeTrackerBlocState.running(entries: entries, activeEntry: active),
      ); // <-- ИСПРАВЛЕНО
    } on Object catch (e) {
      // <-- ИСПРАВЛЕНО
      emit(
        TimeTrackerBlocState.error(
          errorHandler: e,
          entries: state.allEntries,
          activeEntry: state.activeEntryOrNull,
        ),
      );
    }
  }

  Future<void> _onEntryDeleted(
    TimeTrackerEntryDeleted event,
    Emitter<TimeTrackerBlocState> emit,
  ) async {
    try {
      await _service.deleteEntry(event.id);
      final entries = await _service.getAll();
      final active = await _service
          .getActive(); // <-- ИСПРАВЛЕНО: Перезагружаем активную запись

      if (active != null) {
        emit(
          TimeTrackerBlocState.running(entries: entries, activeEntry: active),
        ); // <-- ИСПРАВЛЕНО
      } else {
        emit(TimeTrackerBlocState.loaded(entries: entries)); // <-- ИСПРАВЛЕНО
      }
    } on Object catch (e) {
      // <-- ИСПРАВЛЕНО
      emit(
        TimeTrackerBlocState.error(
          errorHandler: e,
          entries: state.allEntries,
          activeEntry: state.activeEntryOrNull,
        ),
      );
    }
  }

  Future<void> _onEntryCreated(
    TimeTrackerEntryCreated event,
    Emitter<TimeTrackerBlocState> emit,
  ) async {
    try {
      await _service.createEntry(event.entry);
      final entries = await _service.getAll();
      final active = await _service.getActive(); // <-- ИСПРАВЛЕНО

      if (active != null) {
        emit(
          TimeTrackerBlocState.running(entries: entries, activeEntry: active),
        ); // <-- ИСПРАВЛЕНО
      } else {
        emit(TimeTrackerBlocState.loaded(entries: entries)); // <-- ИСПРАВЛЕНО
      }
    } on Object catch (e) {
      // <-- ИСПРАВЛЕНО
      emit(
        TimeTrackerBlocState.error(
          errorHandler: e,
          entries: state.allEntries,
          activeEntry: state.activeEntryOrNull,
        ),
      );
    }
  }

  Future<void> _onEntryUpdated(
    TimeTrackerEntryUpdated event,
    Emitter<TimeTrackerBlocState> emit,
  ) async {
    try {
      await _service.updateEntry(event.entry);
      final entries = await _service.getAll();
      final active = await _service.getActive(); // <-- ИСПРАВЛЕНО

      if (active != null) {
        emit(
          TimeTrackerBlocState.running(entries: entries, activeEntry: active),
        ); // <-- ИСПРАВЛЕНО
      } else {
        emit(TimeTrackerBlocState.loaded(entries: entries)); // <-- ИСПРАВЛЕНО
      }
    } on Object catch (e) {
      // <-- ИСПРАВЛЕНО
      emit(
        TimeTrackerBlocState.error(
          errorHandler: e,
          entries: state.allEntries,
          activeEntry: state.activeEntryOrNull,
        ),
      );
    }
  }
}
