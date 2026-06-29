import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';
import 'package:money_control/features/transactions/domain/entities/pending_notification.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/presentation/providers/pending_notifications_provider.dart';
import 'package:money_control/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:money_control/features/transactions/presentation/widgets/approve_pending_dialog.dart';
import 'package:money_control/features/transactions/presentation/widgets/quick_rule_dialog.dart';

// Fecha: 2026-06-26
// Pantalla de notificaciones capturadas pendientes de aprobación manual.
class NotificationsLogScreen extends ConsumerWidget {
  const NotificationsLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones pendientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(pendingNotificationsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(pendingNotificationsProvider.notifier).refresh(),
        child: pendingAsync.when(
          data: (notifications) => _buildList(context, ref, notifications),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildRefreshableCenter('Error: $error'),
        ),
      ),
    );
  }

  // Fecha: 2026-06-28
  // Centro que permite arrastrar para recargar incluso cuando no hay contenido.
  Widget _buildRefreshableCenter(String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(child: Text(message)),
          ),
        );
      },
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
      return _buildRefreshableCenter('No hay notificaciones pendientes');
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

  // Fecha: 2026-06-28
  // Procesa una notificación pendiente como transacción del tipo indicado.
  // Si la app no tiene reglas para este texto, abre un asistente para crear una.
  // Si no logra detectar el monto, abre un diálogo para que el usuario lo complete.
  Future<void> _process(
    BuildContext context,
    WidgetRef ref,
    PendingNotification notification,
    MovementType type,
  ) async {
    final navigator = Navigator.of(context);
    final amount = _extractAmount(notification.text);

    final hasMatchingRule = await _hasMatchingRule(ref, notification);
    ParserRule? newRule;
    if (!hasMatchingRule && context.mounted) {
      newRule = await showDialog<ParserRule?>(
        context: context,
        builder: (_) => QuickRuleDialog(
          appPackageName: notification.packageName,
          appName: notification.packageName,
          notificationText: notification.text,
          initialType: type,
        ),
      );
      if (newRule == null && amount != null) {
        // El usuario canceló o eligió "Solo esta vez" y hay monto detectado.
        // Continuamos sin crear regla.
      } else if (newRule == null && amount == null) {
        // No hay monto y no quiere crear regla: no se puede guardar transacción.
        return;
      }
    }

    final Transaction transaction;
    if (amount == null) {
      if (!context.mounted) return;
      final approved = await showDialog<Transaction>(
        context: context,
        builder: (_) => ApprovePendingDialog(
          originalText: notification.text,
          type: newRule?.type ?? type,
        ),
      );
      if (approved == null) return;
      transaction = approved.copyWith(
        transactionDate: notification.timestamp,
        originalText: notification.text,
        source: notification.packageName,
        createdAt: DateTime.now(),
      );
    } else {
      transaction = Transaction(
        bank: notification.packageName,
        amount: amount,
        type: newRule?.type ?? type,
        category: newRule?.category ?? Category.otro,
        transactionDate: notification.timestamp,
        originalText: notification.text,
        source: notification.packageName,
        createdAt: DateTime.now(),
      );
    }

    if (newRule != null) {
      await ref.read(saveParserRuleProvider)(newRule);
    }

    await ref.read(transactionsProvider.notifier).saveTransaction(transaction);
    await ref.read(pendingNotificationsProvider.notifier).process(
          notification.id!,
          approved: true,
        );

    // ignore: use_build_context_synchronously
    if (context.mounted) navigator.pop();
  }

  // Fecha: 2026-06-28
  // Indica si la app de la notificación ya tiene una regla que coincida con el texto.
  Future<bool> _hasMatchingRule(WidgetRef ref, PendingNotification notification) async {
    final result = await ref.read(getParserRulesProvider)(notification.packageName);
    final rules = switch (result) {
      Success<List<ParserRule>>(value: final r) => r,
      Failure() => <ParserRule>[],
    };
    final normalized = notification.text.toUpperCase();
    return rules.any((rule) => normalized.contains(rule.keyword.toUpperCase()));
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

  // Fecha: 2026-06-28
  // Extrae el monto de un texto de notificación.
  // Soporta formatos como $12, $12.000, $12.000,00, $1,234.56.
  double? _extractAmount(String text) {
    final pattern = RegExp(r'\$\s?(\d[\d.,]*)');
    final match = pattern.firstMatch(text);
    if (match == null) return null;

    var raw = match.group(1)!;
    raw = raw.replaceAll(RegExp(r'[.,]$'), '');

    final hasThousandSeparatorDots = RegExp(r'\d\.\d{3}').hasMatch(raw);
    final hasThousandSeparatorCommas = RegExp(r'\d,\d{3}').hasMatch(raw);

    String cleaned;
    if (hasThousandSeparatorDots && raw.contains(',')) {
      // Ej: 1.234,56
      cleaned = raw.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasThousandSeparatorDots) {
      // Ej: 12.000
      cleaned = raw.replaceAll('.', '');
    } else if (hasThousandSeparatorCommas && raw.contains('.')) {
      // Ej: 1,234.56
      cleaned = raw.replaceAll(',', '');
    } else if (hasThousandSeparatorCommas) {
      // Ej: 12,000
      cleaned = raw.replaceAll(',', '');
    } else if (raw.contains(',')) {
      // Decimal con coma: 12,5
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
