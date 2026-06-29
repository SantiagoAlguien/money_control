import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';

// Fecha: 2026-06-28
// Diálogo que propone crear una regla de parser a partir de una notificación real.
// Devuelve un ParserRule si el usuario quiere crear la regla, o null si solo
// quiere aplicar la transacción una vez.
class QuickRuleDialog extends ConsumerStatefulWidget {
  final String appPackageName;
  final String appName;
  final String notificationText;
  final MovementType initialType;

  const QuickRuleDialog({
    super.key,
    required this.appPackageName,
    required this.appName,
    required this.notificationText,
    required this.initialType,
  });

  @override
  ConsumerState<QuickRuleDialog> createState() => _QuickRuleDialogState();
}

class _QuickRuleDialogState extends ConsumerState<QuickRuleDialog> {
  final Set<String> _selectedKeywords = {};
  Category _category = Category.otro;
  MovementType _type = MovementType.expense;
  bool _saveRule = true;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _category = _defaultCategoryForType(_type);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keywords = ref.read(suggestKeywordsProvider)(widget.notificationText);
      if (mounted) {
        setState(() {
          _selectedKeywords.addAll(keywords.take(2));
        });
      }
    });
  }

  Category _defaultCategoryForType(MovementType type) {
    return switch (type) {
      MovementType.income => Category.transferencia,
      MovementType.expense => Category.transferencia,
      MovementType.neutral => Category.transferencia,
    };
  }

  String get _keyword {
    if (_selectedKeywords.isEmpty) return '';
    return _selectedKeywords.join(' ');
  }

  void _submit({required bool saveRule}) {
    if (saveRule && _keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una palabra clave')),
      );
      return;
    }

    if (saveRule) {
      final rule = ParserRule(
        appPackageName: widget.appPackageName,
        keyword: _keyword,
        category: _category,
        type: _type,
      );
      Navigator.pop(context, rule);
    } else {
      Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keywords = ref.watch(suggestKeywordsProvider).call(widget.notificationText);

    return AlertDialog(
      title: Text('Crear regla para ${widget.appName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.notificationText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Palabras clave detectadas:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: keywords.map((keyword) {
                final selected = _selectedKeywords.contains(keyword);
                return FilterChip(
                  label: Text(keyword),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _selectedKeywords.remove(keyword);
                      } else {
                        _selectedKeywords.add(keyword);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Palabra clave resultante',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _keyword),
              readOnly: true,
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
                if (value != null) {
                  setState(() {
                    _type = value;
                    _category = _defaultCategoryForType(value);
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Aplicar también a futuras notificaciones'),
              value: _saveRule,
              onChanged: (value) {
                setState(() => _saveRule = value ?? true);
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
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
          onPressed: () => _submit(saveRule: false),
          child: const Text('Solo esta vez'),
        ),
        TextButton(
          onPressed: _saveRule ? () => _submit(saveRule: true) : null,
          child: const Text('Crear regla y guardar'),
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
