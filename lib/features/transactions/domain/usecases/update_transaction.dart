import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Caso de uso para actualizar una transacción existente.
class UpdateTransaction {
  final TransactionRepository _repository;

  const UpdateTransaction(this._repository);

  Future<Result<void>> call(Transaction transaction) {
    return _repository.updateTransaction(transaction);
  }
}
