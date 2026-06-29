import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/utils/result.dart';
import 'package:money_control/features/transactions/domain/entities/app_config.dart';
import 'package:money_control/features/transactions/domain/entities/category.dart';
import 'package:money_control/features/transactions/domain/entities/movement_type.dart';
import 'package:money_control/features/transactions/domain/entities/parser_rule.dart';

// Fecha: 2026-06-26
// Pantalla para configurar qué apps pueden enviar notificaciones y cómo procesarlas.
class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final configsAsync = ref.watch(
      FutureProvider((ref) async {
        final result = await ref.read(getAppConfigsProvider)();
        return switch (result) {
          Success(value: final configs) => configs,
          Failure(error: final error) => throw error,
        };
      }),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de apps')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppDialog,
        child: const Icon(Icons.add),
      ),
      body: configsAsync.when(
        data: (configs) => _buildList(configs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  // Fecha: 2026-06-26
  // Construye la lista de apps configuradas.
  Widget _buildList(List<AppConfig> configs) {
    if (configs.isEmpty) {
      return const Center(child: Text('No hay apps configuradas'));
    }

    return ListView.builder(
      itemCount: configs.length,
      itemBuilder: (context, index) {
        final config = configs[index];
        return Card(
          child: ListTile(
            title: Text(config.appName),
            subtitle: Text('${config.packageName}\nBanco: ${config.bankName}'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    config.enabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: config.enabled ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => _toggleEnabled(config),
                ),
                IconButton(
                  icon: Icon(
                    config.autoProcess ? Icons.auto_mode : Icons.touch_app,
                    color: config.autoProcess ? Colors.blue : Colors.orange,
                  ),
                  onPressed: () => _toggleAutoProcess(config),
                ),
              ],
            ),
            onTap: () => _showRulesDialog(config),
          ),
        );
      },
    );
  }

  // Fecha: 2026-06-26
  // Activa o desactiva la captura de notificaciones de una app.
  Future<void> _toggleEnabled(AppConfig config) async {
    final result = await ref.read(saveAppConfigProvider)(
      config.copyWith(enabled: !config.enabled),
    );
    switch (result) {
      case Failure(error: final error):
        throw error;
      case Success():
        break;
    }
    setState(() {});
  }

  // Fecha: 2026-06-26
  // Cambia entre procesamiento automático o manual.
  Future<void> _toggleAutoProcess(AppConfig config) async {
    final result = await ref.read(saveAppConfigProvider)(
      config.copyWith(autoProcess: !config.autoProcess),
    );
    switch (result) {
      case Failure(error: final error):
        throw error;
      case Success():
        break;
    }
    setState(() {});
  }

  // Fecha: 2026-06-26
  // Muestra diálogo para agregar una nueva app.
  void _showAddAppDialog() {
    final packageController = TextEditingController();
    final nameController = TextEditingController();
    final bankController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar app'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: packageController,
              decoration: const InputDecoration(labelText: 'Package name'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre visible'),
            ),
            TextField(
              controller: bankController,
              decoration: const InputDecoration(labelText: 'Banco asociado'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final config = AppConfig(
                packageName: packageController.text.trim(),
                appName: nameController.text.trim(),
                enabled: true,
                autoProcess: true,
                bankName: bankController.text.trim(),
              );
              final navigator = Navigator.of(context);
              final result = await ref.read(saveAppConfigProvider)(config);
              if (mounted) {
                switch (result) {
                  case Failure(error: final error):
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Error: $error')),
                    );
                  case Success():
                    navigator.pop();
                    setState(() {});
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Fecha: 2026-06-26
  // Muestra las reglas de parser de una app y permite agregar nuevas.
  Future<void> _showRulesDialog(AppConfig config) async {
    final result = await ref.read(getParserRulesProvider)(config.packageName);
    final List<ParserRule> rules;
    switch (result) {
      case Success<List<ParserRule>>(value: final r):
        rules = r;
      case Failure():
        return;
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reglas: ${config.appName}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    return ListTile(
                      title: Text(rule.keyword),
                      subtitle: Text(
                        '${rule.category.value.toUpperCase()} · ${rule.type.value}',
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddRuleDialog(config),
                icon: const Icon(Icons.add),
                label: const Text('Agregar regla'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Fecha: 2026-06-26
  // Muestra diálogo para agregar una regla de parser.
  void _showAddRuleDialog(AppConfig config) {
    final keywordController = TextEditingController();
    Category selectedCategory = Category.transfer;
    MovementType selectedType = MovementType.expense;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nueva regla'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keywordController,
                decoration: const InputDecoration(labelText: 'Palabra clave'),
              ),
              DropdownButtonFormField<Category>(
                key: ValueKey(selectedCategory),
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: Category.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedCategory = value);
                  }
                },
              ),
              DropdownButtonFormField<MovementType>(
                key: ValueKey(selectedType),
                initialValue: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: MovementType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t.value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedType = value);
                  }
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
              onPressed: () async {
                final navigator = Navigator.of(context);
                final rule = ParserRule(
                  appPackageName: config.packageName,
                  keyword: keywordController.text.trim(),
                  category: selectedCategory,
                  type: selectedType,
                );
                await ref.read(saveParserRuleProvider)(rule);
                if (mounted) navigator.pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
