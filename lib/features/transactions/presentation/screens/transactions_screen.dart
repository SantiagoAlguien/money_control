import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_control/core/router/app_router.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/presentation/providers/selected_month_provider.dart';
import 'package:money_control/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:money_control/features/transactions/presentation/widgets/month_year_picker_dialog.dart';
import 'package:money_control/features/transactions/presentation/widgets/transaction_list_tile.dart';

// Fecha: 2026-06-26
// Pantalla de historial completo de movimientos.
// Permite navegar al formulario para agregar o editar transacciones.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextButton.icon(
          onPressed: () => _pickMonth(context, ref),
          icon: const Icon(Icons.calendar_today, size: 18),
          label: Text(
            DateFormat('MMMM yyyy', 'es_CO').format(selectedMonth),
            style: Theme.of(context).appBarTheme.titleTextStyle ??
                Theme.of(context).textTheme.titleLarge,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear') {
                await _confirmClearMonth(context, ref, selectedMonth);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Limpiar mes'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
      body: transactionsAsync.when(
        data: (transactions) => _buildList(
          context,
          ref,
          transactions,
          selectedMonth,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context, WidgetRef ref) async {
    final selected = await showDialog<DateTime>(
      context: context,
      builder: (_) => MonthYearPickerDialog(
        initialDate: ref.read(selectedMonthProvider),
      ),
    );
    if (selected != null) {
      ref.read(selectedMonthProvider.notifier).state = selected;
    }
  }

  Future<void> _confirmClearMonth(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedMonth,
  ) async {
    final monthLabel = DateFormat('MMMM yyyy', 'es_CO').format(selectedMonth);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar mes'),
        content: Text(
          '¿Eliminar todos los movimientos de $monthLabel? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final count = await ref.read(transactionsProvider.notifier).deleteByMonth();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Se eliminaron $count movimientos')),
        );
      }
    }
  }

  // Fecha: 2026-06-28
  // Construye la lista de transacciones del mes seleccionado.
  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Transaction> transactions,
    DateTime month,
  ) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final monthTransactions = transactions.where((t) {
      return !t.transactionDate.isBefore(start) && t.transactionDate.isBefore(end);
    }).toList();

    if (monthTransactions.isEmpty) {
      return const Center(child: Text('No hay movimientos este mes'));
    }

    return ListView.builder(
      itemCount: monthTransactions.length,
      itemBuilder: (context, index) {
        final transaction = monthTransactions[index];
        return Dismissible(
          key: Key(transaction.id?.toString() ?? ''),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) async {
            if (transaction.id != null) {
              await ref
                  .read(transactionsProvider.notifier)
                  .deleteTransaction(transaction.id!);
            }
          },
          child: TransactionListTile(
            transaction: transaction,
            onTap: () => _openForm(context, transaction),
          ),
        );
      },
    );
  }

  // Fecha: 2026-06-26
  // Abre el formulario para agregar una transacción nueva o editar una existente.
  void _openForm(BuildContext context, Transaction? transaction) {
    context.push(AppRouter.addEditTransaction, extra: transaction);
  }
}
