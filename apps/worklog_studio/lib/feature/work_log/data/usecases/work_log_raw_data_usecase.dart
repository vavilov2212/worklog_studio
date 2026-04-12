import 'package:injectable/injectable.dart';
import 'package:worklog_studio/entity/session/data/repository/session_storage_repository.dart';

abstract interface class IWorkLogRawDataUsecase {
  Future<void> attachSession();
}

@Injectable(as: IWorkLogRawDataUsecase)
final class WorkLogRawDataUsecase implements IWorkLogRawDataUsecase {
  final SessionStorageRepository _sessionStorageRepository;
  const WorkLogRawDataUsecase(this._sessionStorageRepository);

  @override
  Future<void> attachSession() async {
    await _sessionStorageRepository.attachSession();
  }
}
