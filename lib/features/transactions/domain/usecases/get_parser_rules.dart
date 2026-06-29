import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Obtiene las reglas de parseo de una app específica.
class GetParserRules {
  final TransactionRepository _repository;

  const GetParserRules(this._repository);

  Future<Result<List<ParserRule>>> call(String packageName) {
    return _repository.getParserRules(packageName);
  }
}
