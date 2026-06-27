import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/services/notification_channel_service.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

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
    _initNotificationListener();
    final result = await ref.read(getAllTransactionsProvider)();
    return switch (result) {
      Success(value: final transactions) => transactions,
      Failure(error: final error) => throw error,
    };
  }

  // Fecha: 2026-06-26
  // Inicia el listener de notificaciones del sistema (SMS, apps bancarias, Nequi).
  // Cada notificación recibida se imprime para poder analizar su formato.
  void _initNotificationListener() {
    final service = NotificationChannelService();
    if (!service.isSupported) return;

    service.notificationStream.listen((data) {
      // Fecha: 2026-06-26
      // Log temporal para capturar el formato de notificaciones de Nequi y otras apps.
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
  // Procesa una notificación: la parsea y la guarda si es reconocida.
  Future<void> _processNotification(
    String text,
    String source,
    DateTime? receivedAt,
  ) async {
    final transaction = ref.read(parseNotificationProvider)(
      text,
      source: source,
      receivedAt: receivedAt,
    );
    if (transaction == null) return;
    await saveTransaction(transaction);
  }

  // Fecha: 2026-06-26
  // Guarda una nueva transacción y refresca la lista.
  Future<void> saveTransaction(Transaction transaction) async {
    final result = await ref.read(saveTransactionProvider)(transaction);
    switch (result) {
      case Failure(error: final error):
        throw error;
      case Success():
        break;
    }
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
  Future<void> deleteTransaction(String id) async {
    final result = await ref.read(deleteTransactionProvider)(id);
    switch (result) {
      case Failure(error: final error):
        throw error;
      case Success():
        break;
    }
    await refresh();
  }

  // Fecha: 2026-06-26
  // Vuelve a cargar las transacciones desde la base de datos.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getAllTransactionsProvider)();
      return switch (result) {
        Success(value: final transactions) => transactions,
        Failure(error: final error) => throw error,
      };
    });
  }
}
