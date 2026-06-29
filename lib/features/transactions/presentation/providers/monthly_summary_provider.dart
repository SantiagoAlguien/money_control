import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/presentation/providers/selected_month_provider.dart';

// Fecha: 2026-06-28
// Provider que expone el resumen mensual actual como AsyncValue.
// Se declara a nivel de archivo para evitar recargas infinitas por rebuilds.
final monthlySummaryProvider = FutureProvider<Map<String, double>>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final result = await ref.watch(getMonthlySummaryProvider)(month);
  return switch (result) {
    Success(value: final summary) => summary,
    Failure(error: final error) => throw error,
  };
});
