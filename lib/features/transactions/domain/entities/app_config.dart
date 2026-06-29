// Fecha: 2026-06-26
// Entidad que representa la configuración de una app de notificaciones.
class AppConfig {
  final String? id;
  final String packageName;
  final String appName;
  final bool enabled;
  final bool autoProcess;
  final String bankName;

  const AppConfig({
    this.id,
    required this.packageName,
    required this.appName,
    required this.enabled,
    required this.autoProcess,
    required this.bankName,
  });

  AppConfig copyWith({
    String? id,
    String? packageName,
    String? appName,
    bool? enabled,
    bool? autoProcess,
    String? bankName,
  }) {
    return AppConfig(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      enabled: enabled ?? this.enabled,
      autoProcess: autoProcess ?? this.autoProcess,
      bankName: bankName ?? this.bankName,
    );
  }
}
