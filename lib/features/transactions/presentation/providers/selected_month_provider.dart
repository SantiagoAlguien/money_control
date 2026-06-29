import 'package:flutter_riverpod/flutter_riverpod.dart';

// Fecha: 2026-06-28
// Provider global con el mes seleccionado para filtrar resúmenes y listas.
// Siempre almacena el primer día del mes para facilitar comparaciones.
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});
