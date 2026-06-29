import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/app_config.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Guarda o actualiza la configuración de una app de notificaciones.
class SaveAppConfig {
  final TransactionRepository _repository;

  const SaveAppConfig(this._repository);

  Future<Result<void>> call(AppConfig config) => _repository.saveAppConfig(config);
}
