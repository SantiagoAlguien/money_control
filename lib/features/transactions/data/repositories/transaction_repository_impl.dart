import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:money_control/features/transactions/data/models/transaction_model.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Implementación del repositorio de transacciones.
// Conecta los usecases con la fuente de datos local (SQLite).
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDatasource _datasource;

  const TransactionRepositoryImpl(this._datasource);

  // Fecha: 2026-06-26
  // Guarda una nueva transacción en la base de datos.
  @override
  Future<Result<void>> saveTransaction(Transaction transaction) async {
    try {
      await _datasource.insert(TransactionModel.fromEntity(transaction));
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }

  // Fecha: 2026-06-26
  // Obtiene todas las transacciones ordenadas por fecha.
  @override
  Future<Result<List<Transaction>>> getAllTransactions() async {
    try {
      final models = await _datasource.getAll();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Failure(e);
    }
  }

  // Fecha: 2026-06-26
  // Obtiene el resumen mensual: ingresos, gastos y saldo.
  @override
  Future<Result<Map<String, double>>> getMonthlySummary(DateTime month) async {
    try {
      final summary = await _datasource.getMonthlySummary(month);
      return Success(summary);
    } catch (e) {
      return Failure(e);
    }
  }

  // Fecha: 2026-06-26
  // Actualiza una transacción existente.
  @override
  Future<Result<void>> updateTransaction(Transaction transaction) async {
    try {
      await _datasource.update(TransactionModel.fromEntity(transaction));
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }

  // Fecha: 2026-06-26
  // Elimina una transacción por su id.
  @override
  Future<Result<void>> deleteTransaction(String id) async {
    try {
      await _datasource.delete(id);
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }
}
