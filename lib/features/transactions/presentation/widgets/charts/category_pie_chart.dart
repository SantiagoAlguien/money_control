import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

// Fecha: 2026-06-26
// Gráfica de pastel que muestra la distribución de gastos por categoría del mes actual.
class CategoryPieChart extends StatelessWidget {
  final List<Transaction> transactions;
  final DateTime month;

  const CategoryPieChart({
    super.key,
    required this.transactions,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);

    // Fecha: 2026-06-26
    // Agrupa los gastos del mes por categoría.
    final categoryTotals = <String, double>{};
    for (final t in transactions) {
      if (t.type.value != 'expense') {
        continue;
      }
      if (t.transactionDate.isBefore(startOfMonth) ||
          t.transactionDate.isAtSameMomentAs(endOfMonth)) {
        continue;
      }
      categoryTotals[t.category.value] =
          (categoryTotals[t.category.value] ?? 0) + t.amount;
    }

    if (categoryTotals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Sin gastos este mes')),
        ),
      );
    }

    final total = categoryTotals.values.reduce((a, b) => a + b);
    final colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.yellowAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
    ];

    final sections = categoryTotals.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final categoryKey = entry.value.key;
      final displayName = Category.fromValue(categoryKey).displayName;
      final amount = entry.value.value;
      final percentage = total == 0 ? 0 : (amount / total * 100);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: amount,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        badgeWidget: _CategoryBadge(
          category: displayName,
          color: colors[index % colors.length],
        ),
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();

    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gastos por categoría del mes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoryTotals.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final categoryKey = entry.value.key;
                final displayName = Category.fromValue(categoryKey).displayName;
                final amount = entry.value.value;
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: colors[index % colors.length],
                    radius: 6,
                  ),
                  label: Text(
                    '$displayName ${currencyFormat.format(amount)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  final Color color;

  const _CategoryBadge({required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
