import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

// Fecha: 2026-06-26
// Widget reutilizable que muestra una transacción en formato de tarjeta.
class TransactionListTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionListTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type.value == 'income';
    final isNeutral = transaction.type.value == 'neutral';
    final color = isNeutral
        ? Colors.grey
        : isIncome
            ? Colors.greenAccent
            : Colors.redAccent;
    final sign = isNeutral
        ? ''
        : isIncome
            ? '+'
            : '-';
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(
            isNeutral
                ? Icons.swap_horiz
                : isIncome
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
            color: color,
          ),
        ),
        title: Text(transaction.bank),
        subtitle: Text(
          '${transaction.category.displayName} · ${dateFormat.format(transaction.transactionDate)}${transaction.description != null ? '\n${transaction.description}' : ''}',
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
