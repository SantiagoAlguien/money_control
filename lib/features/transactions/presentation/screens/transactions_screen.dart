import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/router/app_router.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:money_control/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:go_router/go_router.dart';

// Fecha: 2026-06-26
// Pantalla de historial completo de movimientos.
// Permite navegar al formulario para agregar o editar transacciones.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
      body: transactionsAsync.when(
        data: (transactions) => _buildList(context, ref, transactions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  // Fecha: 2026-06-26
  // Construye la lista de transacciones o un mensaje si está vacía.
  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<Transaction> transactions,
  ) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No hay movimientos registrados'));
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
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
