import 'package:worklog_studio/entity/session/session_handle.dart';

abstract interface class SessionHandleDb {
  Future<void> save(SessionHandle session);
  Future<List<SessionHandle>> getAll();
  Future<SessionHandle?> getById(String id);
  Future<void> delete(String id);
}
