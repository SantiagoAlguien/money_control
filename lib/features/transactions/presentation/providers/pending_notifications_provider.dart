import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/pending_notification.dart';

// Fecha: 2026-06-26
// Notifier que expone la lista de notificaciones pendientes de aprobación.
final pendingNotificationsProvider = AsyncNotifierProvider<
    PendingNotificationsNotifier, List<PendingNotification>>(
  PendingNotificationsNotifier.new,
);

class PendingNotificationsNotifier
    extends AsyncNotifier<List<PendingNotification>> {
  @override
  Future<List<PendingNotification>> build() async {
    await ref.read(cleanExpiredPendingNotificationsProvider)();
    final result = await ref.read(getPendingNotificationsProvider)();
    return switch (result) {
      Success(value: final notifications) => notifications,
      Failure(error: final error) => throw error,
    };
  }

  // Fecha: 2026-06-26
  // Refresca la lista de notificaciones pendientes.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(cleanExpiredPendingNotificationsProvider)();
      final result = await ref.read(getPendingNotificationsProvider)();
      return switch (result) {
        Success(value: final notifications) => notifications,
        Failure(error: final error) => throw error,
      };
    });
  }

  // Fecha: 2026-06-26
  // Marca una notificación como aprobada o descartada.
  Future<void> process(String id, {required bool approved}) async {
    final result = await ref.read(processPendingNotificationProvider)(
      id,
      approved: approved,
    );
    switch (result) {
      case Failure(error: final error):
        throw error;
      case Success():
        break;
    }
    await refresh();
  }
}
