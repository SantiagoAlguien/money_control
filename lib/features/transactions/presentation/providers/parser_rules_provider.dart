import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';

// Fecha: 2026-06-28
// Provider que expone las reglas de parser de una app como AsyncValue.
// Se declara a nivel de archivo para evitar recargas infinitas por rebuilds.
final parserRulesProvider = FutureProvider.family<List<ParserRule>, String>(
  (ref, packageName) async {
    final result = await ref.watch(getParserRulesProvider)(packageName);
    return switch (result) {
      Success<List<ParserRule>>(value: final rules) => rules,
      Failure(error: final error) => throw error,
    };
  },
);
