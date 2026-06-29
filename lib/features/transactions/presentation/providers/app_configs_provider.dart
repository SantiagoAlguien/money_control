import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/app_config.dart';

// Fecha: 2026-06-28
// Provider que expone la lista de apps configuradas como AsyncValue.
// Se declara a nivel de archivo para evitar recargas infinitas por rebuilds.
final appConfigsProvider = FutureProvider<List<AppConfig>>((ref) async {
  final result = await ref.watch(getAppConfigsProvider)();
  return switch (result) {
    Success(value: final configs) => configs,
    Failure(error: final error) => throw error,
  };
});
