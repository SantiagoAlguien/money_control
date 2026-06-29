import 'package:flutter/material.dart';

// Fecha: 2026-06-28
// Diálogo para seleccionar un mes y año.
class MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const MonthYearPickerDialog({super.key, required this.initialDate});

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int _year;
  late int _month;

  final _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialDate.year;
    _month = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar mes'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selector de año
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _year--),
                ),
                Text(
                  '$_year',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _year++),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Grid de meses
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(12, (index) {
                final monthIndex = index + 1;
                final isSelected = monthIndex == _month;
                return ChoiceChip(
                  label: Text(_months[index]),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _month = monthIndex),
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, DateTime(_year, _month, 1));
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}
