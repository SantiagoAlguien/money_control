import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:money_control/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:money_control/features/transactions/domain/usecases/get_all_transactions.dart';
import 'package:money_control/features/transactions/domain/usecases/get_monthly_summary.dart';
import 'package:money_control/features/transactions/domain/usecases/parse_notification.dart';
import 'package:money_control/features/transactions/domain/usecases/save_transaction.dart';

final transactionLocalDatasourceProvider = Provider<TransactionLocalDatasource>(
  (ref) => TransactionLocalDatasourceImpl(),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(
    ref.watch(transactionLocalDatasourceProvider),
  ),
);

final getAllTransactionsProvider = Provider<GetAllTransactions>(
  (ref) => GetAllTransactions(ref.watch(transactionRepositoryProvider)),
);

final getMonthlySummaryProvider = Provider<GetMonthlySummary>(
  (ref) => GetMonthlySummary(ref.watch(transactionRepositoryProvider)),
);

final saveTransactionProvider = Provider<SaveTransaction>(
  (ref) => SaveTransaction(ref.watch(transactionRepositoryProvider)),
);

final parseNotificationProvider = Provider<ParseNotification>(
  (ref) => const ParseNotification(),
);
