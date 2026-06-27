import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/utils/result.dart';

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, Map<String, double>>(
  DashboardNotifier.new,
);

class DashboardNotifier extends AsyncNotifier<Map<String, double>> {
  @override
  Future<Map<String, double>> build() async {
    final now = DateTime.now();
    final result = await ref.read(getMonthlySummaryProvider)(now);
    return switch (result) {
      Success(value: final summary) => summary,
      Failure(error: final error) => throw error,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final now = DateTime.now();
      final result = await ref.read(getMonthlySummaryProvider)(now);
      return switch (result) {
        Success(value: final summary) => summary,
        Failure(error: final error) => throw error,
      };
    });
  }
}
