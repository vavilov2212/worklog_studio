import 'package:worklog_studio/core/services/web/web_file_system_api.dart';

sealed class SessionDirectoryHandle {}

class WebSessionDirectoryHandle extends SessionDirectoryHandle {
  final FileSystemDirectoryHandle handle;

  WebSessionDirectoryHandle(this.handle);
}
