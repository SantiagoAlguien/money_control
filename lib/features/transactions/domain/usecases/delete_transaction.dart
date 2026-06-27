import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Caso de uso para eliminar una transacción por su id.
class DeleteTransaction {
  final TransactionRepository _repository;

  const DeleteTransaction(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteTransaction(id);
  }
}
