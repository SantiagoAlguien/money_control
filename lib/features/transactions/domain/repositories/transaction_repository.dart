import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<Result<void>> saveTransaction(Transaction transaction);
  Future<Result<List<Transaction>>> getAllTransactions();
  Future<Result<Map<String, double>>> getMonthlySummary(DateTime month);
}
