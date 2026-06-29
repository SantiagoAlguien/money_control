import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-28
// Caso de uso para eliminar todas las transacciones de un mes específico.
class DeleteTransactionsByMonth {
  final TransactionRepository _repository;

  const DeleteTransactionsByMonth(this._repository);

  Future<Result<int>> call(DateTime month) {
    return _repository.deleteTransactionsByMonth(month);
  }
}
