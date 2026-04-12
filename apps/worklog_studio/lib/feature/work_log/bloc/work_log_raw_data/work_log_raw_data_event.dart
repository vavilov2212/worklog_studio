part of 'work_log_raw_data_bloc.dart';

@freezed
class WorkLogRawDataEvent with _$WorkLogRawDataEvent {
  const factory WorkLogRawDataEvent.load() = _LoadWorkLogRawDataEvent;

  const factory WorkLogRawDataEvent.refresh({Completer<void>? completer}) =
      _RefreshWorkLogRawDataEvent;
}
