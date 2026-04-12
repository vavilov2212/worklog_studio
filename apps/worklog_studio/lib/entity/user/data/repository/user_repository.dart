import 'package:worklog_studio/entity/session/data/repository/session_storage_repository.dart';

class UserRepository {
  final SessionStorageRepository sessionStorageRepository;
  UserRepository(this.sessionStorageRepository);
}
