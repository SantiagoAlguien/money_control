import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

class SaveTransaction {
  final TransactionRepository _repository;

  const SaveTransaction(this._repository);

  Future<Result<void>> call(Transaction transaction) {
    return _repository.saveTransaction(transaction);
  }
}
