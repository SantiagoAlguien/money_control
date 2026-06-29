import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/pending_notification.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Obtiene las notificaciones pendientes que aún no han vencido.
class GetPendingNotifications {
  final TransactionRepository _repository;

  const GetPendingNotifications(this._repository);

  Future<Result<List<PendingNotification>>> call() {
    return _repository.getPendingNotifications();
  }
}
