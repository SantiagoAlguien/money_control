import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

class GetMonthlySummary {
  final TransactionRepository _repository;

  const GetMonthlySummary(this._repository);

  Future<Result<Map<String, double>>> call(DateTime month) {
    return _repository.getMonthlySummary(month);
  }
}
