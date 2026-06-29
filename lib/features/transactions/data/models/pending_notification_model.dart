import 'package:money_control/features/transactions/domain/entities/pending_notification.dart';

// Fecha: 2026-06-26
// Modelo de datos para notificaciones pendientes de aprobación.
class PendingNotificationModel {
  final String? id;
  final String packageName;
  final String title;
  final String text;
  final String timestamp;
  final String status;
  final String expiresAt;

  const PendingNotificationModel({
    this.id,
    required this.packageName,
    required this.title,
    required this.text,
    required this.timestamp,
    required this.status,
    required this.expiresAt,
  });

  factory PendingNotificationModel.fromEntity(PendingNotification entity) {
    return PendingNotificationModel(
      id: entity.id,
      packageName: entity.packageName,
      title: entity.title,
      text: entity.text,
      timestamp: entity.timestamp.toIso8601String(),
      status: entity.status,
      expiresAt: entity.expiresAt.toIso8601String(),
    );
  }

  PendingNotification toEntity() {
    return PendingNotification(
      id: id,
      packageName: packageName,
      title: title,
      text: text,
      timestamp: DateTime.parse(timestamp),
      status: status,
      expiresAt: DateTime.parse(expiresAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packageName': packageName,
      'title': title,
      'text': text,
      'timestamp': timestamp,
      'status': status,
      'expiresAt': expiresAt,
    };
  }

  factory PendingNotificationModel.fromMap(Map<String, dynamic> map) {
    return PendingNotificationModel(
      id: map['id']?.toString(),
      packageName: map['packageName'] as String,
      title: map['title'] as String,
      text: map['text'] as String,
      timestamp: map['timestamp'] as String,
      status: map['status'] as String,
      expiresAt: map['expiresAt'] as String,
    );
  }
}
