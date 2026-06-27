import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

// Fecha: 2026-06-26
// Gráfica de barras que compara ingresos y gastos de los últimos 6 meses.
class MonthlyBarChart extends StatelessWidget {
  final List<Transaction> transactions;

  const MonthlyBarChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Fecha: 2026-06-26
    // Genera los últimos 6 meses (más reciente a la derecha).
    final now = DateTime.now();
    final months = List.generate(6, (index) {
      final month = DateTime(now.year, now.month - (5 - index), 1);
      return month;
    });

    // Fecha: 2026-06-26
    // Calcula ingresos y gastos por mes.
    final incomeData = <double>[];
    final expenseData = <double>[];
    for (final month in months) {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 1);

      double income = 0;
      double expense = 0;
      for (final t in transactions) {
        if (t.transactionDate.isBefore(start) ||
            t.transactionDate.isAtSameMomentAs(end)) {
          continue;
        }
        if (t.type.value == 'income') {
          income += t.amount;
        } else if (t.type.value == 'expense') {
          expense += t.amount;
        }
      }
      incomeData.add(income);
      expenseData.add(expense);
    }

    final maxValue = [...incomeData, ...expenseData]
        .fold<double>(0, (prev, curr) => curr > prev ? curr : prev);
    final interval = (maxValue == 0 ? 100000.0 : maxValue / 5).toDouble();

    final currencyFormat = NumberFormat.compactCurrency(
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
              'Ingresos vs Gastos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (maxValue * 1.2).toDouble(),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= months.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            DateFormat('MMM').format(months[index]),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            currencyFormat.format(value),
                            style: const TextStyle(fontSize: 8),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(months.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: incomeData[index],
                          color: Colors.greenAccent,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        BarChartRodData(
                          toY: expenseData[index],
                          color: Colors.redAccent,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.greenAccent, label: 'Ingresos'),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.redAccent, label: 'Gastos'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: color, radius: 6),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
