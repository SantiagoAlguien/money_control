import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/app_config.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';
import 'package:money_control/features/transactions/domain/entities/pending_notification.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

// Fecha: 2026-06-26
// Contrato del repositorio de transacciones y configuración de notificaciones.
abstract class TransactionRepository {
  // Transacciones
  Future<Result<int>> saveTransaction(Transaction transaction);
  Future<Result<List<Transaction>>> getAllTransactions();
  Future<Result<Map<String, double>>> getMonthlySummary(DateTime month);
  Future<Result<void>> updateTransaction(Transaction transaction);
  Future<Result<void>> deleteTransaction(int id);

  // Apps de notificaciones
  Future<Result<List<AppConfig>>> getAppConfigs();
  Future<Result<void>> saveAppConfig(AppConfig config);
  Future<Result<AppConfig?>> getAppConfigByPackage(String packageName);

  // Reglas de parser
  Future<Result<List<ParserRule>>> getParserRules(String packageName);
  Future<Result<void>> saveParserRule(ParserRule rule);

  // Notificaciones pendientes
  Future<Result<void>> savePendingNotification(PendingNotification notification);
  Future<Result<List<PendingNotification>>> getPendingNotifications();
  Future<Result<void>> updatePendingNotificationStatus(
    String id,
    String status,
  );
  Future<Result<void>> deletePendingNotification(String id);
  Future<Result<void>> cleanExpiredPendingNotifications();
}
