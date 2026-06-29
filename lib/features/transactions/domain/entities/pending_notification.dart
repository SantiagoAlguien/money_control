// Fecha: 2026-06-26
// Entidad que representa una notificación capturada pendiente de aprobación.
class PendingNotification {
  final String? id;
  final String packageName;
  final String title;
  final String text;
  final DateTime timestamp;
  final String status; // pending, approved, discarded
  final DateTime expiresAt;

  const PendingNotification({
    this.id,
    required this.packageName,
    required this.title,
    required this.text,
    required this.timestamp,
    required this.status,
    required this.expiresAt,
  });

  PendingNotification copyWith({
    String? id,
    String? packageName,
    String? title,
    String? text,
    DateTime? timestamp,
    String? status,
    DateTime? expiresAt,
  }) {
    return PendingNotification(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      title: title ?? this.title,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
