import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/services/notification_channel_service.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/app_config.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';
import 'package:money_control/features/transactions/domain/entities/pending_notification.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/presentation/providers/dashboard_provider.dart';
import 'package:money_control/features/transactions/presentation/providers/selected_month_provider.dart';

// Fecha: 2026-06-26
// Notifier que expone la lista de transacciones y escucha notificaciones automáticas.
final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
  TransactionsNotifier.new,
);

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    await ref.read(transactionLocalDatasourceProvider).init();
    await ref.read(cleanExpiredPendingNotificationsProvider)();
    _initNotificationListener();
    final result = await ref.read(getAllTransactionsProvider)();
    return switch (result) {
      Success(value: final transactions) => transactions,
      Failure(error: final error) => throw error,
    };
  }

  // Fecha: 2026-06-26
  // Inicia el listener de notificaciones del sistema.
  void _initNotificationListener() {
    final service = NotificationChannelService();
    if (!service.isSupported) return;

    service.notificationStream.listen((data) {
      // Fecha: 2026-06-26
      // Log temporal para analizar cualquier notificación recibida.
      // ignore: avoid_print
      print('NOTIFICACION RECIBIDA: $data');

      final text = data['text'] ?? '';
      final source = data['packageName'] ?? 'notification';
      final timestamp = data['timestamp'] as int?;
      final receivedAt = timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
      _processNotification(text, source, receivedAt);
    });
  }

  // Fecha: 2026-06-26
  // Procesa una notificación según la configuración de la app y sus reglas.
  Future<void> _processNotification(
    String text,
    String source,
    DateTime? receivedAt,
  ) async {
    if (text.toString().isEmpty) return;

    final appConfigResult =
        await ref.read(getAppConfigsProvider)().then((result) {
      if (result is! Success<List<AppConfig>>) return null;
      return result.value.firstWhere(
        (config) => source.toLowerCase().contains(config.packageName.toLowerCase()) ||
            config.packageName.toLowerCase().contains(source.toLowerCase()),
        orElse: () => const AppConfig(
          packageName: '',
          appName: '',
          enabled: false,
          autoProcess: false,
          bankName: '',
        ),
      );
    });

    if (appConfigResult == null || !appConfigResult.enabled) {
      // Fecha: 2026-06-26
      // Si la app no está configurada o deshabilitada, se ignora la notificación.
      return;
    }

    final rulesResult = await ref.read(getParserRulesProvider)(
      appConfigResult.packageName,
    );
    final List<ParserRule> rules;
    switch (rulesResult) {
      case Success<List<ParserRule>>(value: final r):
        rules = r;
      case Failure():
        return;
    }

    final parser = ref.read(parseNotificationProvider);
    final transaction = parser.parseWithConfig(
      text.toString(),
      appConfigResult,
      rules,
      source: source,
      receivedAt: receivedAt,
    );

    if (transaction == null) {
      // Fecha: 2026-06-26
      // Si no hay regla que coincida, se guarda como pendiente de aprobación.
      await _savePendingNotification(text.toString(), source, receivedAt);
      return;
    }

    if (!appConfigResult.autoProcess) {
      // Fecha: 2026-06-26
      // Si la app requiere aprobación manual, se guarda como pendiente.
      await _savePendingNotification(text.toString(), source, receivedAt);
      return;
    }

    await saveTransaction(transaction);
  }

  // Fecha: 2026-06-26
  // Guarda una notificación en la lista de pendientes con vencimiento de 24 horas.
  Future<void> _savePendingNotification(
    String text,
    String source,
    DateTime? receivedAt,
  ) async {
    final now = receivedAt ?? DateTime.now();
    final pending = PendingNotification(
      packageName: source,
      title: '',
      text: text,
      timestamp: now,
      status: 'pending',
      expiresAt: now.add(const Duration(hours: 24)),
    );
    final result = await ref.read(savePendingNotificationProvider)(pending);
    switch (result) {
      case Failure(error: final error):
        throw error;
      case Success():
        break;
    }
  }

  // Fecha: 2026-06-26
  // Guarda una nueva transacción, ejecuta matching y refresca la lista.
  Future<void> saveTransaction(Transaction transaction) async {
    final result = await ref.read(saveTransactionProvider)(transaction);
    final savedId = switch (result) {
      Failure(error: final error) => throw error,
      Success<int>(value: final id) => id,
    };

    final savedTransaction = transaction.copyWith(id: savedId);
    await ref.read(matchOwnTransferProvider)(savedTransaction);
    await refresh();
  }

  // Fecha: 2026-06-26
  // Actualiza una transacción existente y refresca la lista.
  Future<void> updateTransaction(Transaction transaction) async {
    final result = await ref.read(updateTransactionProvider)(transaction);
    switch (result) {
      case Failure(error: final error):
        throw error;
      case Success():
        break;
    }
    await refresh();
  }

  // Fecha: 2026-06-26
  // Elimina una transacción por su id y refresca la lista.
  Future<void> deleteTransaction(int id) async {
    final result = await ref.read(deleteTransactionProvider)(id);
    switch (result) {
      case Failure(error: final error):
        throw error;
      case Success():
        break;
    }
    await refresh();
  }

  // Fecha: 2026-06-28
  // Elimina todas las transacciones del mes seleccionado y refresca la lista.
  Future<int> deleteByMonth() async {
    final month = ref.read(selectedMonthProvider);
    final result = await ref.read(deleteTransactionsByMonthProvider)(month);
    return switch (result) {
      Failure(error: final error) => throw error,
      Success<int>(value: final count) => count,
    };
  }

  // Fecha: 2026-06-26
  // Vuelve a cargar las transacciones desde la base de datos.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(cleanExpiredPendingNotificationsProvider)();
      final result = await ref.read(getAllTransactionsProvider)();
      return switch (result) {
        Success(value: final transactions) => transactions,
        Failure(error: final error) => throw error,
      };
    });
    ref.invalidate(dashboardProvider);
  }
}
