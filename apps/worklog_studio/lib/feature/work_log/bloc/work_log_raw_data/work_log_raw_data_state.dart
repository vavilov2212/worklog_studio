part of 'work_log_raw_data_bloc.dart';

@freezed
class WorkLogRawDataState with _$WorkLogRawDataState {
  const WorkLogRawDataState._();

  const factory WorkLogRawDataState.idle() = _IdleWorkLogRawDataState;

  const factory WorkLogRawDataState.progress() = _LoadingWorkLogRawDataState;

  const factory WorkLogRawDataState.success(
    /*{
    required List<DtoVirtualCardProvider> virtualCardsProviders,
    @Default(false) bool isLoadingMore,
    IErrorHandler? loadMoreError,
  }*/
  ) = _SuccessWorkLogRawDataState;

  const factory WorkLogRawDataState.error({
    required IErrorHandler errorHandler,
  }) = _ErrorWorkLogRawDataState;
}
