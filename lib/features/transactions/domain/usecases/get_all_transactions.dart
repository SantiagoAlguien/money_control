import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

class GetAllTransactions {
  final TransactionRepository _repository;

  const GetAllTransactions(this._repository);

  Future<Result<List<Transaction>>> call() => _repository.getAllTransactions();
}
