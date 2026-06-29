import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Guarda una nueva regla de parseo para una app.
class SaveParserRule {
  final TransactionRepository _repository;

  const SaveParserRule(this._repository);

  Future<Result<void>> call(ParserRule rule) => _repository.saveParserRule(rule);
}
