import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/presentation/providers/transactions_provider.dart';

// Fecha: 2026-06-26
// Diálogo para crear una transacción de ajuste que cuadre el saldo calculado.
class BalanceAdjustmentDialog extends ConsumerStatefulWidget {
  const BalanceAdjustmentDialog({super.key});

  @override
  ConsumerState<BalanceAdjustmentDialog> createState() =>
      _BalanceAdjustmentDialogState();
}

class _BalanceAdjustmentDialogState
    extends ConsumerState<BalanceAdjustmentDialog> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(
      FutureProvider((ref) async {
        final result = await ref.read(getMonthlySummaryProvider)(DateTime.now());
        return switch (result) {
          Success(value: final summary) => summary,
          Failure(error: final error) => throw error,
        };
      }),
    );

    return AlertDialog(
      title: const Text('Ajustar saldo'),
      content: summaryAsync.when(
        data: (summary) => _buildForm(context, summary['balance'] ?? 0),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text('Error: $error'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('Ajustar'),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, double currentBalance) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saldo calculado: ${currencyFormat.format(currentBalance)}'),
        const SizedBox(height: 16),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Saldo real',
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          title: const Text('Fecha del ajuste'),
          subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: _pickDate,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Motivo',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final amountText = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '');
    final desiredBalance = double.tryParse(amountText);
    if (desiredBalance == null) return;

    final result = await ref.read(createBalanceAdjustmentProvider)(
      desiredBalance: desiredBalance,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
    );

    if (mounted) {
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      switch (result) {
        case Failure(error: final error):
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        case Success():
          await ref.read(transactionsProvider.notifier).refresh();
          navigator.pop();
      }
    }
  }
}
