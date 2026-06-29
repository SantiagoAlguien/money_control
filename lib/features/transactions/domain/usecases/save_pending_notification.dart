import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/pending_notification.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Guarda una notificación pendiente de aprobación manual.
class SavePendingNotification {
  final TransactionRepository _repository;

  const SavePendingNotification(this._repository);

  Future<Result<void>> call(PendingNotification notification) {
    return _repository.savePendingNotification(notification);
  }
}
