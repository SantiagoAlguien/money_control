import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-28
// Caso de uso para eliminar una regla de parser por su id.
class DeleteParserRule {
  final TransactionRepository _repository;

  const DeleteParserRule(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteParserRule(id);
  }
}
