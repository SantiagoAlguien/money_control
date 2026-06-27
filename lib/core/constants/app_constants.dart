// Fecha: 2026-06-26
// Constantes globales de la aplicación.
abstract final class AppConstants {
  static const String appName = 'Money Control';
  static const String databaseName = 'money_control.db';
  // Fecha: 2026-06-26
  // Versión 2: incluye la columna description en la tabla transactions.
  static const int databaseVersion = 2;

  static const String eventChannelNotifications =
      'com.example.money_control/notifications';
}
