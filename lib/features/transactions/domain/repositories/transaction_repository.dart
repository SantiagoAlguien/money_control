import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

// Fecha: 2026-06-26
// Contrato del repositorio de transacciones.
// Define las operaciones disponibles para guardar, consultar, actualizar y eliminar movimientos.
abstract class TransactionRepository {
  Future<Result<void>> saveTransaction(Transaction transaction);
  Future<Result<List<Transaction>>> getAllTransactions();
  Future<Result<Map<String, double>>> getMonthlySummary(DateTime month);
  Future<Result<void>> updateTransaction(Transaction transaction);
  Future<Result<void>> deleteTransaction(String id);
}
