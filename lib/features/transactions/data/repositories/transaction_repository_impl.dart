import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:money_control/features/transactions/data/models/app_config_model.dart';
import 'package:money_control/features/transactions/data/models/parser_rule_model.dart';
import 'package:money_control/features/transactions/data/models/pending_notification_model.dart';
import 'package:money_control/features/transactions/data/models/transaction_model.dart';
import 'package:money_control/features/transactions/domain/entities/app_config.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';
import 'package:money_control/features/transactions/domain/entities/pending_notification.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/domain/repositories/transaction_repository.dart';

// Fecha: 2026-06-26
// Implementación del repositorio. Conecta usecases con SQLite.
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDatasource _datasource;

  const TransactionRepositoryImpl(this._datasource);

  @override
  Future<Result<int>> saveTransaction(Transaction transaction) async {
    try {
      final id = await _datasource.insert(
        TransactionModel.fromEntity(transaction),
      );
      return Success(id);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<List<Transaction>>> getAllTransactions() async {
    try {
      final models = await _datasource.getAll();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<Map<String, double>>> getMonthlySummary(DateTime month) async {
    try {
      final summary = await _datasource.getMonthlySummary(month);
      return Success(summary);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<void>> updateTransaction(Transaction transaction) async {
    try {
      await _datasource.update(TransactionModel.fromEntity(transaction));
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<void>> deleteTransaction(int id) async {
    try {
      await _datasource.delete(id);
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<int>> deleteTransactionsByMonth(DateTime month) async {
    try {
      final count = await _datasource.deleteByMonth(month);
      return Success(count);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<List<AppConfig>>> getAppConfigs() async {
    try {
      final models = await _datasource.getAppConfigs();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<void>> saveAppConfig(AppConfig config) async {
    try {
      await _datasource.saveAppConfig(AppConfigModel.fromEntity(config));
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<AppConfig?>> getAppConfigByPackage(String packageName) async {
    try {
      final model = await _datasource.getAppConfigByPackage(packageName);
      return Success(model?.toEntity());
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<List<ParserRule>>> getParserRules(String packageName) async {
    try {
      final models = await _datasource.getParserRules(packageName);
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<void>> saveParserRule(ParserRule rule) async {
    try {
      await _datasource.saveParserRule(ParserRuleModel.fromEntity(rule));
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<void>> deleteParserRule(String id) async {
    try {
      await _datasource.deleteParserRule(id);
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<void>> savePendingNotification(
    PendingNotification notification,
  ) async {
    try {
      await _datasource.savePendingNotification(
        PendingNotificationModel.fromEntity(notification),
      );
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<List<PendingNotification>>> getPendingNotifications() async {
    try {
      final models = await _datasource.getPendingNotifications();
      return Success(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<void>> updatePendingNotificationStatus(
    String id,
    String status,
  ) async {
    try {
      await _datasource.updatePendingNotificationStatus(id, status);
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<void>> deletePendingNotification(String id) async {
    try {
      await _datasource.deletePendingNotification(id);
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }

  @override
  Future<Result<void>> cleanExpiredPendingNotifications() async {
    try {
      await _datasource.cleanExpiredPendingNotifications();
      return const Success(null);
    } catch (e) {
      return Failure(e);
    }
  }
}
