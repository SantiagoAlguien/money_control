import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:money_control/features/transactions/data/models/transaction_model.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDatasource _datasource;

  const TransactionRepositoryImpl(this._datasource);

  @override
  Future<Result<void>> saveTransaction(Transaction transaction) async {
    try {
      await _datasource.insert(TransactionModel.fromEntity(transaction));
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<List<Transaction>>> getAllTransactions() async {
    try {
      final models = await _datasource.getAll();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<Map<String, double>>> getMonthlySummary(DateTime month) async {
    try {
      final summary = await _datasource.getMonthlySummary(month);
      return Success(summary);
    } catch (e) {
      return Failure(e);
    }
  }
}
