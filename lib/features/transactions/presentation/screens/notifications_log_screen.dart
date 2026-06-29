import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/pending_notification.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/presentation/providers/pending_notifications_provider.dart';
import 'package:money_control/features/transactions/presentation/providers/transactions_provider.dart';

// Fecha: 2026-06-26
// Pantalla de notificaciones capturadas pendientes de aprobación manual.
class NotificationsLogScreen extends ConsumerWidget {
  const NotificationsLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingNotificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones pendientes')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(pendingNotificationsProvider.notifier).refresh(),
        child: pendingAsync.when(
          data: (notifications) => _buildList(context, ref, notifications),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  // Fecha: 2026-06-26
  // Construye la lista de notificaciones pendientes agrupadas por app.
  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<PendingNotification> notifications,
  ) {
    if (notifications.isEmpty) {
      return const Center(child: Text('No hay notificaciones pendientes'));
    }

    final grouped = <String, List<PendingNotification>>{};
    for (final n in notifications) {
      grouped.putIfAbsent(n.packageName, () => []).add(n);
    }

    return ListView(
      children: grouped.entries.map((entry) {
        return ExpansionTile(
          title: Text(entry.key),
          subtitle: Text('${entry.value.length} pendientes'),
          children: entry.value.map((n) => _buildItem(context, ref, n)).toList(),
        );
      }).toList(),
    );
  }

  // Fecha: 2026-06-26
  // Renderiza un item con las acciones disponibles.
  Widget _buildItem(
    BuildContext context,
    WidgetRef ref,
    PendingNotification notification,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final remaining = notification.expiresAt.difference(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${dateFormat.format(notification.timestamp)} · Vence en: ${_formatDuration(remaining)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _process(context, ref, notification, MovementType.income),
                  child: const Text('Ingreso'),
                ),
                TextButton(
                  onPressed: () => _process(context, ref, notification, MovementType.expense),
                  child: const Text('Gasto'),
                ),
                TextButton(
                  onPressed: () => _process(context, ref, notification, MovementType.neutral),
                  child: const Text('Movimiento'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _discard(ref, notification),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fecha: 2026-06-26
  // Procesa una notificación pendiente como transacción del tipo indicado.
  Future<void> _process(
    BuildContext context,
    WidgetRef ref,
    PendingNotification notification,
    MovementType type,
  ) async {
    final amount = _extractAmount(notification.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo detectar el monto')),
      );
      return;
    }

    final transaction = Transaction(
      bank: notification.packageName,
      amount: amount,
      type: type,
      category: Category.other,
      transactionDate: notification.timestamp,
      originalText: notification.text,
      source: notification.packageName,
      createdAt: DateTime.now(),
    );

    await ref.read(transactionsProvider.notifier).saveTransaction(transaction);
    await ref.read(pendingNotificationsProvider.notifier).process(
          notification.id!,
          approved: true,
        );
  }

  // Fecha: 2026-06-26
  // Descarta una notificación pendiente.
  Future<void> _discard(WidgetRef ref, PendingNotification notification) async {
    if (notification.id != null) {
      await ref.read(pendingNotificationsProvider.notifier).process(
            notification.id!,
            approved: false,
          );
    }
  }

  // Fecha: 2026-06-26
  // Extrae el monto de un texto de notificación.
  double? _extractAmount(String text) {
    final pattern = RegExp(r'\\$\\s?(\\d[\\d.,]*)');
    final match = pattern.firstMatch(text);
    if (match == null) return null;

    var raw = match.group(1)!;
    raw = raw.replaceAll(RegExp(r'[.,]$'), '');

    final hasThousandSeparatorDots = RegExp(r'\\d\\.\\d{3}').hasMatch(raw);
    final hasThousandSeparatorCommas = RegExp(r'\\d,\\d{3}').hasMatch(raw);

    String cleaned;
    if (hasThousandSeparatorDots) {
      cleaned = raw.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasThousandSeparatorCommas) {
      cleaned = raw.replaceAll(',', '');
    } else if (raw.contains(',')) {
      cleaned = raw.replaceAll(',', '.');
    } else {
      cleaned = raw;
    }

    return double.tryParse(cleaned);
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return 'vencida';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
