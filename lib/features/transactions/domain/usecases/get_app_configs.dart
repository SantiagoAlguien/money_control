import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/app_config.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Obtiene la configuración de todas las apps de notificaciones.
class GetAppConfigs {
  final TransactionRepository _repository;

  const GetAppConfigs(this._repository);

  Future<Result<List<AppConfig>>> call() => _repository.getAppConfigs();
}
