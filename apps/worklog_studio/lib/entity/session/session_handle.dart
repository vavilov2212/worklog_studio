class SessionHandle {
  final String id; // UUID
  final String title; // Название сессии
  final DateTime createdAt;

  SessionHandle({
    required this.id,
    required this.title,
    required this.createdAt,
  });
}
