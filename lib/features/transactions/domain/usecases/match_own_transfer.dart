import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Detecta si una transacción es parte de una transferencia entre cuentas propias.
// Busca una transacción del monto opuesto en los últimos 5 minutos entre Caja Social y Nequi.
class MatchOwnTransfer {
  final TransactionRepository _repository;

  const MatchOwnTransfer(this._repository);

  Future<void> call(Transaction transaction) async {
    final result = await _repository.getAllTransactions();
    if (result is! Success<List<Transaction>>) return;

    final transactions = result.value;

    // Fecha: 2026-06-26
    // Solo empareja transferencias entre Caja Social y Nequi.
    const validBanks = {'Caja Social', 'Nequi'};
    if (!validBanks.contains(transaction.bank)) return;
    if (transaction.type == MovementType.neutral) return;

    final fiveMinutesAgo = transaction.createdAt.subtract(
      const Duration(minutes: 5),
    );

    final match = transactions.where((t) {
      if (t.id == transaction.id) return false;
      if (!validBanks.contains(t.bank)) return false;
      if (t.bank == transaction.bank) return false;
      if (t.type == MovementType.neutral) return false;
      if (t.amount != transaction.amount) return false;
      if (t.createdAt.isBefore(fiveMinutesAgo)) return false;
      // Debe ser tipo opuesto: income vs expense.
      if (t.type == transaction.type) return false;
      return true;
    }).firstOrNull;

    if (match == null) return;

    // Fecha: 2026-06-26
    // Marca ambas transacciones como neutral (movimiento entre cuentas propias).
    await _repository.updateTransaction(
      transaction.copyWith(type: MovementType.neutral),
    );
    await _repository.updateTransaction(
      match.copyWith(type: MovementType.neutral),
    );
  }
}
