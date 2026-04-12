abstract interface class InputStorage {
  Future<void> save(String sessionId, String text);
  Future<String?> load(String sessionId, String fileDescriptor);

  Future<void> attachSession(String sessionId);
  Future<bool> isSessionAvailable(String sessionId);
}
