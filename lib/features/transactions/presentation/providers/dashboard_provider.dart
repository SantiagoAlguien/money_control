import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/presentation/providers/selected_month_provider.dart';

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, Map<String, double>>(
  DashboardNotifier.new,
);

class DashboardNotifier extends AsyncNotifier<Map<String, double>> {
  @override
  Future<Map<String, double>> build() async {
    final month = ref.watch(selectedMonthProvider);
    final result = await ref.read(getMonthlySummaryProvider)(month);
    return switch (result) {
      Success(value: final summary) => summary,
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final month = ref.read(selectedMonthProvider);
      final result = await ref.read(getMonthlySummaryProvider)(month);
      return switch (result) {
        Success(value: final summary) => summary,
        Failure(error: final error) => throw error,
      };
    });
  }
}
