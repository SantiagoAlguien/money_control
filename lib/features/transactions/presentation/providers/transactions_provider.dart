import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/services/notification_channel_service.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

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

  void _initNotificationListener() {
    final service = NotificationChannelService();
    if (!service.isSupported) return;

    service.notificationStream.listen((data) {
      final text = data['text'] ?? '';
      final source = data['packageName'] ?? 'notification';
      final timestamp = data['timestamp'] as int?;
      final receivedAt = timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null;
      _processNotification(text, source, receivedAt);
    });
  }

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
