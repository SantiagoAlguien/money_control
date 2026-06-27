import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

// Fecha: 2026-06-26
// Gráfica de línea que muestra la evolución del saldo acumulado por mes.
class BalanceLineChart extends StatelessWidget {
  final List<Transaction> transactions;

  const BalanceLineChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Fecha: 2026-06-26
    // Genera los últimos 6 meses.
    final now = DateTime.now();
    final months = List.generate(6, (index) {
      final month = DateTime(now.year, now.month - (5 - index), 1);
      return month;
    });

    // Fecha: 2026-06-26
    // Calcula el saldo acumulado mes a mes.
    final balanceData = <double>[];
    double accumulated = 0;
    for (final month in months) {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 1);

      double monthIncome = 0;
      double monthExpense = 0;
      for (final t in transactions) {
        if (t.transactionDate.isBefore(start) ||
            t.transactionDate.isAtSameMomentAs(end)) {
          continue;
        }
        if (t.type.value == 'income') {
          monthIncome += t.amount;
        } else if (t.type.value == 'expense') {
          monthExpense += t.amount;
        }
      }
      accumulated += monthIncome - monthExpense;
      balanceData.add(accumulated);
    }

    final maxValue = balanceData.fold<double>(
      0,
      (prev, curr) => curr > prev ? curr : prev,
    );
    final minValue = balanceData.fold<double>(
      0,
      (prev, curr) => curr < prev ? curr : prev,
    );

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
              'Evolución del saldo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: minValue * 1.1,
                  maxY: maxValue * 1.1,
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
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
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        months.length,
                        (index) => FlSpot(index.toDouble(), balanceData[index]),
                      ),
                      isCurved: true,
                      color: Colors.tealAccent,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.tealAccent.withValues(alpha: 0.2),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
