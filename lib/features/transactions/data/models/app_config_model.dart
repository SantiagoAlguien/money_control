import 'package:money_control/features/transactions/domain/entities/app_config.dart';

// Fecha: 2026-06-26
// Modelo de datos para la configuración de apps de notificaciones.
class AppConfigModel {
  final String? id;
  final String packageName;
  final String appName;
  final int enabled;
  final int autoProcess;
  final String bankName;

  const AppConfigModel({
    this.id,
    required this.packageName,
    required this.appName,
    required this.enabled,
    required this.autoProcess,
    required this.bankName,
  });

  factory AppConfigModel.fromEntity(AppConfig entity) {
    return AppConfigModel(
      id: entity.id,
      packageName: entity.packageName,
      appName: entity.appName,
      enabled: entity.enabled ? 1 : 0,
      autoProcess: entity.autoProcess ? 1 : 0,
      bankName: entity.bankName,
    );
  }

  AppConfig toEntity() {
    return AppConfig(
      id: id,
      packageName: packageName,
      appName: appName,
      enabled: enabled == 1,
      autoProcess: autoProcess == 1,
      bankName: bankName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packageName': packageName,
      'appName': appName,
      'enabled': enabled,
      'autoProcess': autoProcess,
      'bankName': bankName,
    };
  }

  factory AppConfigModel.fromMap(Map<String, dynamic> map) {
    return AppConfigModel(
      id: map['id']?.toString(),
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
      enabled: map['enabled'] as int,
      autoProcess: map['autoProcess'] as int,
      bankName: map['bankName'] as String,
    );
  }
}
