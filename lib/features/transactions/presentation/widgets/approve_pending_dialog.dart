import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';

// Fecha: 2026-06-28
// Diálogo para aprobar una notificación pendiente cuyo monto no pudo detectarse automáticamente.
// Permite al usuario ingresar monto, banco y descripción manualmente.
class ApprovePendingDialog extends StatefulWidget {
  final String originalText;
  final MovementType type;

  const ApprovePendingDialog({
    super.key,
    required this.originalText,
    required this.type,
  });

  @override
  State<ApprovePendingDialog> createState() => _ApprovePendingDialogState();
}

class _ApprovePendingDialogState extends State<ApprovePendingDialog> {
  final _amountController = TextEditingController();
  final _bankController = TextEditingController();
  final _descriptionController = TextEditingController();
  Category _category = Category.otro;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.originalText;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Fecha: 2026-06-28
  // Parsea un monto escrito con separadores de miles y decimales en español.
  double? _parseAmount(String text) {
    if (text.trim().isEmpty) return null;
    var raw = text.trim();

    final hasThousandDots = RegExp(r'\d\.\d{3}').hasMatch(raw);
    final hasThousandCommas = RegExp(r'\d,\d{3}').hasMatch(raw);

    String cleaned;
    if (hasThousandDots && raw.contains(',')) {
      // Ej: 1.234,56
      cleaned = raw.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasThousandDots) {
      // Ej: 1.234
      cleaned = raw.replaceAll('.', '');
    } else if (hasThousandCommas && raw.contains('.')) {
      // Ej: 1,234.56
      cleaned = raw.replaceAll(',', '');
    } else if (hasThousandCommas) {
      // Ej: 1,234
      cleaned = raw.replaceAll(',', '');
    } else if (raw.contains(',')) {
      // Decimal con coma: 12,5
      cleaned = raw.replaceAll(',', '.');
    } else {
      cleaned = raw;
    }

    return double.tryParse(cleaned);
  }

  void _submit() {
    final amount = _parseAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido')),
      );
      return;
    }

    final bank = _bankController.text.trim();
    if (bank.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el banco')),
      );
      return;
    }

    final transaction = Transaction(
      bank: bank,
      amount: amount,
      type: widget.type,
      category: _category,
      transactionDate: DateTime.now(),
      originalText: widget.originalText,
      source: 'manual',
      createdAt: DateTime.now(),
      description: _descriptionController.text.trim(),
    );

    Navigator.pop(context, transaction);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aprobar notificación'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.originalText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bankController,
              decoration: const InputDecoration(
                labelText: 'Banco',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Category>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
                items: Category.values.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
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
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
