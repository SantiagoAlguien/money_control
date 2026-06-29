import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Crea una transacción de ajuste para cuadrar el saldo calculado con el saldo real.
class CreateBalanceAdjustment {
  final TransactionRepository _repository;

  const CreateBalanceAdjustment(this._repository);

  Future<Result<void>> call({
    required double desiredBalance,
    required DateTime date,
    String? description,
  }) async {
    final now = DateTime.now();
    final summaryResult = await _repository.getMonthlySummary(now);

    if (summaryResult is! Success<Map<String, double>>) {
      return Failure((summaryResult as Failure).error);
    }

    final currentBalance = summaryResult.value['balance'] ?? 0.0;
    final difference = desiredBalance - currentBalance;

    if (difference == 0) {
      return const Success(null);
    }

    final adjustment = Transaction(
      bank: 'Ajuste manual',
      amount: difference.abs(),
      type: difference > 0 ? MovementType.income : MovementType.expense,
      category: Category.other,
      transactionDate: date,
      originalText: 'Ajuste de saldo',
      source: 'manual',
      createdAt: now,
      description: description?.isNotEmpty == true
          ? description
          : 'Diferencia entre saldo calculado y saldo real',
    );

    final saveResult = await _repository.saveTransaction(adjustment);
    return switch (saveResult) {
      Success<int>() => const Success(null),
      Failure(error: final error) => Failure(error),
    };
  }
}
