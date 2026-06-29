import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Marca una notificación pendiente como aprobada o descartada.
class ProcessPendingNotification {
  final TransactionRepository _repository;

  const ProcessPendingNotification(this._repository);

  Future<Result<void>> call(String id, {required bool approved}) {
    return _repository.updatePendingNotificationStatus(
      id,
      approved ? 'approved' : 'discarded',
    );
  }
}
