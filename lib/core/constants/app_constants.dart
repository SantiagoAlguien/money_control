// Fecha: 2026-06-26
// Constantes globales de la aplicación.
abstract final class AppConstants {
  static const String appName = 'Money Control';
  static const String databaseName = 'money_control.db';
  // Fecha: 2026-06-28
  // Versión 4: categorías en español y soporte para borrar movimientos por mes.
  static const int databaseVersion = 4;

  static const String eventChannelNotifications =
      'com.example.money_control/notifications';
}
