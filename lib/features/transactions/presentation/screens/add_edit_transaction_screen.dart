import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/presentation/providers/transactions_provider.dart';

// Fecha: 2026-06-26
// Pantalla para agregar una transacción manual o editar una existente.
class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _bankController;
  late final TextEditingController _descriptionController;

  late MovementType _selectedType;
  late Category _selectedCategory;
  late DateTime _selectedDate;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountController = TextEditingController(
      text: t != null ? t.amount.toStringAsFixed(0) : '',
    );
    _bankController = TextEditingController(text: t?.bank ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _selectedType = t?.type ?? MovementType.expense;
    _selectedCategory = t?.category ?? Category.other;
    _selectedDate = t?.transactionDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar movimiento' : 'Nuevo movimiento'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Fecha: 2026-06-26
              // Selector de tipo de movimiento.
              SegmentedButton<MovementType>(
                segments: const [
                  ButtonSegment(
                    value: MovementType.income,
                    label: Text('Ingreso'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: MovementType.expense,
                    label: Text('Gasto'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: MovementType.neutral,
                    label: Text('Movimiento'),
                    icon: Icon(Icons.swap_horiz),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (set) {
                  setState(() => _selectedType = set.first);
                },
              ),
              const SizedBox(height: 16),
              // Fecha: 2026-06-26
              // Campo de monto.
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (double.tryParse(value.replaceAll('.', '').replaceAll(',', '')) == null) {
                    return 'Monto inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Fecha: 2026-06-26
              // Campo de banco o fuente.
              TextFormField(
                controller: _bankController,
                decoration: const InputDecoration(
                  labelText: 'Banco / Fuente',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Fecha: 2026-06-26
              // Selector de categoría. Usa initialValue + ValueKey para evitar el warning deprecado.
              DropdownButtonFormField<Category>(
                key: ValueKey(_selectedCategory),
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: Category.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Fecha: 2026-06-26
              // Selector de fecha.
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).dividerColor),
                ),
                title: const Text('Fecha'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              // Fecha: 2026-06-26
              // Campo de descripción: motivo o destino del movimiento.
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Motivo / Destino',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Guardar cambios' : 'Guardar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fecha: 2026-06-26
  // Abre el selector de fecha nativo.
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

  // Fecha: 2026-06-26
  // Valida el formulario y guarda o actualiza la transacción.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amountText = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    final amount = double.parse(amountText);
    final bank = _bankController.text.trim();
    final description = _descriptionController.text.trim();

    final transaction = Transaction(
      id: widget.transaction?.id,
      bank: bank,
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      transactionDate: _selectedDate,
      originalText: widget.transaction?.originalText ?? 'manual',
      source: widget.transaction?.source ?? 'manual',
      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
      description: description.isNotEmpty ? description : null,
    );

    final notifier = ref.read(transactionsProvider.notifier);
    if (_isEditing) {
      await notifier.updateTransaction(transaction);
    } else {
      await notifier.saveTransaction(transaction);
    }

    if (mounted) context.pop();
  }

  // Fecha: 2026-06-26
  // Elimina la transacción actual después de confirmar.
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Seguro que quieres eliminar este movimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.transaction?.id != null) {
      await ref
          .read(transactionsProvider.notifier)
          .deleteTransaction(widget.transaction!.id!);
      if (mounted) context.pop();
    }
  }
}
