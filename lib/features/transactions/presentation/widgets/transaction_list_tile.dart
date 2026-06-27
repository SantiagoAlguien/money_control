import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

class TransactionListTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionListTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type.value == 'income';
    final color = isIncome ? Colors.greenAccent : Colors.redAccent;
    final sign = isIncome ? '+' : '-';
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
          ),
        ),
        title: Text(transaction.bank),
        subtitle: Text(
          '${transaction.category.value.toUpperCase()} · ${dateFormat.format(transaction.transactionDate)}',
        ),
        trailing: Text(
          '$sign${currencyFormat.format(transaction.amount)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
