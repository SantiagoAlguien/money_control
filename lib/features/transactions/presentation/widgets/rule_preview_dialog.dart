import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/app_config.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/domain/usecases/parse_notification.dart';

// Fecha: 2026-06-28
// Diálogo para probar cómo se parsearía una notificación con las reglas actuales de una app.
class RulePreviewDialog extends ConsumerStatefulWidget {
  final String packageName;
  final String appName;

  const RulePreviewDialog({
    super.key,
    required this.packageName,
    required this.appName,
  });

  @override
  ConsumerState<RulePreviewDialog> createState() => _RulePreviewDialogState();
}

class _RulePreviewDialogState extends ConsumerState<RulePreviewDialog> {
  final _textController = TextEditingController();
  Transaction? _preview;
  ParserRule? _matchedRule;
  bool _tested = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final rulesResult = await ref.read(getParserRulesProvider)(widget.packageName);
    final rules = switch (rulesResult) {
      Success<List<ParserRule>>(value: final r) => r,
      Failure() => <ParserRule>[],
    };

    // Fecha: 2026-06-28
    // Busca la primera regla cuya keyword esté contenida en el texto.
    final normalized = text.toUpperCase();
    final matched = rules.cast<ParserRule?>().firstWhere(
      (r) => normalized.contains(r!.keyword.toUpperCase()),
      orElse: () => null,
    );

    final parser = const ParseNotification();
    final transaction = parser.parseWithConfig(
      text,
      AppConfig(
        packageName: widget.packageName,
        appName: widget.appName,
        enabled: true,
        autoProcess: true,
        bankName: widget.appName,
      ),
      rules,
      source: widget.packageName,
    );

    if (mounted) {
      setState(() {
        _preview = transaction;
        _matchedRule = matched;
        _tested = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Probar reglas: ${widget.appName}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Pega aquí el texto de una notificación',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _test,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Probar'),
              ),
              const SizedBox(height: 16),
              if (_tested) _buildResult(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildResult() {
    if (_matchedRule == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Ninguna regla coincide con ese texto.'),
        ),
      );
    }

    if (_preview == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Regla coincidente: ${_matchedRule!.keyword}'),
              Text('Categoría: ${_matchedRule!.category.displayName}'),
              Text('Tipo: ${_matchedRule!.type.value}'),
              const SizedBox(height: 8),
              const Text(
                'La regla coincide pero no se pudo crear la transacción. Probablemente no se detectó un monto válido.',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
        ),
      );
    }

    final t = _preview!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Regla coincidente: ${_matchedRule!.keyword}'),
            Text('Banco: ${t.bank}'),
            Text('Monto: \$${t.amount.toStringAsFixed(0)}'),
            Text('Categoría: ${t.category.displayName}'),
            Text('Tipo: ${t.type.value}'),
            Text('Fecha: ${t.transactionDate.toIso8601String()}'),
          ],
        ),
      ),
    );
  }
}
