import 'package:worklog_studio/entity/session/data/data_source/input_storage/input_storage.dart';
import 'package:worklog_studio/entity/session/domain/i_input_storage.dart';

class SessionStorageRepository {
  static const _sessionId = 'default';
  late final InputStorage _storage = createInputStorage();

  Future<String?> load(String fileDescriptor) async =>
      await _storage.load(_sessionId, fileDescriptor);

  Future<void> save(String text) async {
    await _storage.save(_sessionId, text);
  }

  Future<void> attachSession() async =>
      await _storage.attachSession(_sessionId);
}
