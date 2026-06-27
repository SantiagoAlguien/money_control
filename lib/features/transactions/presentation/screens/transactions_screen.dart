import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:money_control/features/transactions/presentation/widgets/transaction_list_tile.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos')),
      body: transactionsAsync.when(
        data: (transactions) => _buildList(context, transactions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildList(BuildContext context, List transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No hay movimientos registrados'));
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return TransactionListTile(transaction: transactions[index]);
      },
    );
  }
}
