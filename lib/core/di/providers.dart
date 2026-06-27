import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:money_control/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:money_control/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:money_control/features/transactions/domain/usecases/get_all_transactions.dart';
import 'package:money_control/features/transactions/domain/usecases/get_monthly_summary.dart';
import 'package:money_control/features/transactions/domain/usecases/parse_notification.dart';
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
// Proveedor del caso de uso para obtener todas las transacciones.
final getAllTransactionsProvider = Provider<GetAllTransactions>(
  (ref) => GetAllTransactions(ref.watch(transactionRepositoryProvider)),
);

// Fecha: 2026-06-26
// Proveedor del caso de uso para obtener el resumen mensual.
final getMonthlySummaryProvider = Provider<GetMonthlySummary>(
  (ref) => GetMonthlySummary(ref.watch(transactionRepositoryProvider)),
);

// Fecha: 2026-06-26
// Proveedor del caso de uso para guardar una nueva transacción.
final saveTransactionProvider = Provider<SaveTransaction>(
  (ref) => SaveTransaction(ref.watch(transactionRepositoryProvider)),
);

// Fecha: 2026-06-26
// Proveedor del caso de uso para actualizar una transacción existente.
final updateTransactionProvider = Provider<UpdateTransaction>(
  (ref) => UpdateTransaction(ref.watch(transactionRepositoryProvider)),
);

// Fecha: 2026-06-26
// Proveedor del caso de uso para eliminar una transacción.
final deleteTransactionProvider = Provider<DeleteTransaction>(
  (ref) => DeleteTransaction(ref.watch(transactionRepositoryProvider)),
);

// Fecha: 2026-06-26
// Proveedor del parser de notificaciones bancarias.
final parseNotificationProvider = Provider<ParseNotification>(
  (ref) => const ParseNotification(),
);
