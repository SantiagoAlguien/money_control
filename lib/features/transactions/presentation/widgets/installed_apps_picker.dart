import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

// Fecha: 2026-06-28
// Diálogo para seleccionar una app instalada del dispositivo.
class InstalledAppsPicker extends StatefulWidget {
  const InstalledAppsPicker({super.key});

  @override
  State<InstalledAppsPicker> createState() => _InstalledAppsPickerState();
}

class _InstalledAppsPickerState extends State<InstalledAppsPicker> {
  List<AppInfo> _apps = [];
  List<AppInfo> _filtered = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  // Fecha: 2026-06-28
  // Carga las apps instaladas excluyendo las del sistema y las no lanzables.
  Future<void> _loadApps() async {
    try {
      final apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: true,
        excludeNonLaunchableApps: true,
      );
      apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if (mounted) {
        setState(() {
          _apps = apps;
          _filtered = apps;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar apps: $e')),
        );
      }
    }
  }

  // Fecha: 2026-06-28
  // Filtra las apps por nombre o package name.
  void _onSearch(String query) {
    setState(() {
      _query = query.toLowerCase();
      _filtered = _apps.where((app) {
        return app.name.toLowerCase().contains(_query) ||
            app.packageName.toLowerCase().contains(_query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar app'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Buscar app',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearch,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? const Center(child: Text('No se encontraron apps'))
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final app = _filtered[index];
                            return ListTile(
                              leading: app.icon != null
                                  ? Image.memory(
                                      app.icon!,
                                      width: 40,
                                      height: 40,
                                    )
                                  : const Icon(Icons.android),
                              title: Text(app.name),
                              subtitle: Text(app.packageName),
                              onTap: () => Navigator.pop(context, app),
                            );
                          },
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
      ],
    );
  }
}
