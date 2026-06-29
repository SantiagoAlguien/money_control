import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Elimina las notificaciones pendientes que ya vencieron (más de 24 horas).
class CleanExpiredPendingNotifications {
  final TransactionRepository _repository;

  const CleanExpiredPendingNotifications(this._repository);

  Future<Result<void>> call() => _repository.cleanExpiredPendingNotifications();
}
