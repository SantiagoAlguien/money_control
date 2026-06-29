import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:money_control/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:money_control/features/transactions/domain/usecases/clean_expired_pending_notifications.dart';
import 'package:money_control/features/transactions/domain/usecases/create_balance_adjustment.dart';
import 'package:money_control/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:money_control/features/transactions/domain/usecases/get_all_transactions.dart';
import 'package:money_control/features/transactions/domain/usecases/get_app_configs.dart';
import 'package:money_control/features/transactions/domain/usecases/get_monthly_summary.dart';
import 'package:money_control/features/transactions/domain/usecases/get_pending_notifications.dart';
import 'package:money_control/features/transactions/domain/usecases/get_parser_rules.dart';
import 'package:money_control/features/transactions/domain/usecases/match_own_transfer.dart';
import 'package:money_control/features/transactions/domain/usecases/parse_notification.dart';
import 'package:money_control/features/transactions/domain/usecases/process_pending_notification.dart';
import 'package:money_control/features/transactions/domain/usecases/save_app_config.dart';
import 'package:money_control/features/transactions/domain/usecases/save_parser_rule.dart';
import 'package:money_control/features/transactions/domain/usecases/save_pending_notification.dart';
import 'package:money_control/features/transactions/domain/usecases/save_transaction.dart';
import 'package:money_control/features/transactions/domain/usecases/update_transaction.dart';

// Fecha: 2026-06-26
// Proveedor de la fuente de datos local de SQLite.
final transactionLocalDatasourceProvider = Provider<TransactionLocalDatasource>(
  (ref) => TransactionLocalDatasourceImpl(),
);

// Fecha: 2026-06-26
// Proveedor del repositorio de transacciones.
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(
    ref.watch(transactionLocalDatasourceProvider),
  ),
);

// Fecha: 2026-06-26
// Proveedores de casos de uso de transacciones.
final getAllTransactionsProvider = Provider<GetAllTransactions>(
  (ref) => GetAllTransactions(ref.watch(transactionRepositoryProvider)),
);

final getMonthlySummaryProvider = Provider<GetMonthlySummary>(
  (ref) => GetMonthlySummary(ref.watch(transactionRepositoryProvider)),
);

final saveTransactionProvider = Provider<SaveTransaction>(
  (ref) => SaveTransaction(ref.watch(transactionRepositoryProvider)),
);

final updateTransactionProvider = Provider<UpdateTransaction>(
  (ref) => UpdateTransaction(ref.watch(transactionRepositoryProvider)),
);

final deleteTransactionProvider = Provider<DeleteTransaction>(
  (ref) => DeleteTransaction(ref.watch(transactionRepositoryProvider)),
);

// Fecha: 2026-06-26
// Proveedores de casos de uso de apps y reglas.
final getAppConfigsProvider = Provider<GetAppConfigs>(
  (ref) => GetAppConfigs(ref.watch(transactionRepositoryProvider)),
);

final saveAppConfigProvider = Provider<SaveAppConfig>(
  (ref) => SaveAppConfig(ref.watch(transactionRepositoryProvider)),
);

final getParserRulesProvider = Provider<GetParserRules>(
  (ref) => GetParserRules(ref.watch(transactionRepositoryProvider)),
);

final saveParserRuleProvider = Provider<SaveParserRule>(
  (ref) => SaveParserRule(ref.watch(transactionRepositoryProvider)),
);

// Fecha: 2026-06-26
// Proveedores de casos de uso de notificaciones pendientes.
final getPendingNotificationsProvider = Provider<GetPendingNotifications>(
  (ref) => GetPendingNotifications(ref.watch(transactionRepositoryProvider)),
);

final savePendingNotificationProvider = Provider<SavePendingNotification>(
  (ref) => SavePendingNotification(ref.watch(transactionRepositoryProvider)),
);

final processPendingNotificationProvider = Provider<ProcessPendingNotification>(
  (ref) => ProcessPendingNotification(ref.watch(transactionRepositoryProvider)),
);

final cleanExpiredPendingNotificationsProvider =
    Provider<CleanExpiredPendingNotifications>(
  (ref) => CleanExpiredPendingNotifications(
    ref.watch(transactionRepositoryProvider),
  ),
);

// Fecha: 2026-06-26
// Proveedores de matching y ajuste de saldo.
final matchOwnTransferProvider = Provider<MatchOwnTransfer>(
  (ref) => MatchOwnTransfer(ref.watch(transactionRepositoryProvider)),
);

final createBalanceAdjustmentProvider = Provider<CreateBalanceAdjustment>(
  (ref) => CreateBalanceAdjustment(ref.watch(transactionRepositoryProvider)),
);

// Fecha: 2026-06-26
// Proveedor del parser de notificaciones. Ahora es parametrizable por reglas.
final parseNotificationProvider = Provider<ParseNotification>(
  (ref) => ParseNotification(),
);
