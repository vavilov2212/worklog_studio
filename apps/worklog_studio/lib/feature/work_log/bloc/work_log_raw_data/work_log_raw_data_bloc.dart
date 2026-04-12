import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:worklog_studio/core/error/error_handler.dart';
import 'package:worklog_studio/feature/work_log/data/usecases/work_log_raw_data_usecase.dart';

part 'work_log_raw_data_bloc.freezed.dart';
part 'work_log_raw_data_event.dart';
part 'work_log_raw_data_state.dart';

class WorkLogRawDataBloc
    extends Bloc<WorkLogRawDataEvent, WorkLogRawDataState> {
  final IWorkLogRawDataUsecase _workLogRawDataUsecase;

  WorkLogRawDataBloc({required IWorkLogRawDataUsecase workLogRawDataUsecase})
    : _workLogRawDataUsecase = workLogRawDataUsecase,
      super(const WorkLogRawDataState.idle()) {
    on<WorkLogRawDataEvent>(
      (event, emit) => event.map(
        load: (event) => _load(emit),
        refresh: (event) => _refresh(event, emit),
      ),
      transformer: droppable(),
    );
  }

  Future<void> _load(Emitter<WorkLogRawDataState> emit) async {
    try {
      emit(const WorkLogRawDataState.progress());
      await _workLogRawDataUsecase.attachSession();

      emit(
        WorkLogRawDataState.success(/*virtualCardsProviders: virtualCards*/),
      );
    } on Object catch (error) {
      emit(WorkLogRawDataState.error(errorHandler: error.toHandler()));
    }
  }

  Future<void> _refresh(
    _RefreshWorkLogRawDataEvent event,
    Emitter<WorkLogRawDataState> emit,
  ) async {
    await _load(emit);
    event.completer?.complete();
  }
}
