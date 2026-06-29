import 'package:flutter/material.dart';
import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';

// Fecha: 2026-06-28
// Diálogo para crear o editar una regla de parser manualmente.
class RuleEditorDialog extends StatefulWidget {
  final String appPackageName;
  final ParserRule? rule;

  const RuleEditorDialog({
    super.key,
    required this.appPackageName,
    this.rule,
  });

  @override
  State<RuleEditorDialog> createState() => _RuleEditorDialogState();
}

class _RuleEditorDialogState extends State<RuleEditorDialog> {
  final _keywordController = TextEditingController();
  late Category _category;
  late MovementType _type;

  @override
  void initState() {
    super.initState();
    _keywordController.text = widget.rule?.keyword ?? '';
    _category = widget.rule?.category ?? Category.otro;
    _type = widget.rule?.type ?? MovementType.expense;
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  void _submit() {
    final keyword = _keywordController.text.trim();
    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La palabra clave es requerida')),
      );
      return;
    }

    final rule = ParserRule(
      id: widget.rule?.id,
      appPackageName: widget.appPackageName,
      keyword: keyword,
      category: _category,
      type: _type,
    );

    Navigator.pop(context, rule);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.rule != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar regla' : 'Nueva regla'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _keywordController,
            decoration: const InputDecoration(
              labelText: 'Palabra clave',
              hintText: 'Ej: TRANSFERENCIA',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
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
          DropdownButtonFormField<MovementType>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
            items: MovementType.values.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Text(_typeLabel(t)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }

  String _typeLabel(MovementType type) {
    return switch (type) {
      MovementType.income => 'Ingreso',
      MovementType.expense => 'Gasto',
      MovementType.neutral => 'Movimiento',
    };
  }
}
