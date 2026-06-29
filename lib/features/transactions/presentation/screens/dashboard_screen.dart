import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_control/core/router/app_router.dart';
import 'package:money_control/core/services/notification_permission_service.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/presentation/providers/dashboard_provider.dart';
import 'package:money_control/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:money_control/features/transactions/presentation/widgets/balance_adjustment_dialog.dart';
import 'package:money_control/features/transactions/presentation/widgets/charts/category_pie_chart.dart';
import 'package:money_control/features/transactions/presentation/widgets/charts/monthly_bar_chart.dart';
import 'package:money_control/features/transactions/presentation/widgets/summary_card.dart';
import 'package:money_control/features/transactions/presentation/widgets/transaction_list_tile.dart';

// Fecha: 2026-06-26
// Pantalla principal con resumen, gráficas y accesos a configuración.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool? _permissionGranted;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await NotificationPermissionService.isGranted();
    if (mounted) {
      setState(() => _permissionGranted = granted);
    }
  }

  Future<void> _openSettings() async {
    await NotificationPermissionService.openSettings();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.push(AppRouter.transactions),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.addEditTransaction),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(transactionsProvider.notifier).refresh();
          await ref.read(dashboardProvider.notifier).refresh();
          await _checkPermission();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPermissionBanner(),
            dashboardAsync.when(
              data: (summary) => _buildSummary(context, summary),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 16),
            // Fecha: 2026-06-26
            // Accesos rápidos a funciones de configuración y ajustes.
            _buildQuickActions(context),
            const SizedBox(height: 24),
            // Fecha: 2026-06-26
            // Gráficas compactas en el dashboard.
            transactionsAsync.when(
              data: (transactions) => _buildCharts(transactions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Últimos movimientos',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => context.push(AppRouter.transactions),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            transactionsAsync.when(
              data: (transactions) => _buildRecentTransactions(transactions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionBanner() {
    if (_permissionGranted == null) return const SizedBox.shrink();
    if (_permissionGranted == true) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Card(
          color: Colors.green,
          child: ListTile(
            leading: Icon(Icons.check_circle, color: Colors.white),
            title: Text(
              'Acceso a notificaciones activado',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Colors.orange,
        child: ListTile(
          leading: const Icon(Icons.notifications_off, color: Colors.white),
          title: const Text(
            'Activa el acceso a notificaciones para capturar movimientos bancarios',
            style: TextStyle(color: Colors.white),
          ),
          trailing: TextButton(
            onPressed: _openSettings,
            child: const Text(
              'Activar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, Map<String, double> summary) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Column(
      children: [
        SummaryCard(
          title: 'Saldo Actual',
          amount: summary['balance'] ?? 0,
          format: currencyFormat,
          icon: Icons.account_balance_wallet,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Ingresos',
                amount: summary['income'] ?? 0,
                format: currencyFormat,
                icon: Icons.trending_up,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Gastos',
                amount: summary['expense'] ?? 0,
                format: currencyFormat,
                icon: Icons.trending_down,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Fecha: 2026-06-26
  // Botones rápidos para notificaciones pendientes, configuración y ajuste de saldo.
  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ActionChip(
          avatar: const Icon(Icons.notifications),
          label: const Text('Pendientes'),
          onPressed: () => context.push(AppRouter.notificationsLog),
        ),
        ActionChip(
          avatar: const Icon(Icons.settings),
          label: const Text('Apps'),
          onPressed: () => context.push(AppRouter.appSettings),
        ),
        ActionChip(
          avatar: const Icon(Icons.tune),
          label: const Text('Ajustar saldo'),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const BalanceAdjustmentDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildCharts(List<Transaction> transactions) {
    return Column(
      children: [
        CategoryPieChart(transactions: transactions),
        const SizedBox(height: 16),
        MonthlyBarChart(transactions: transactions),
      ],
    );
  }

  Widget _buildRecentTransactions(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Aún no hay movimientos registrados')),
        ),
      );
    }

    final recent = transactions.take(5).toList();
    return Column(
      children: recent
          .map((t) => TransactionListTile(
                transaction: t,
                onTap: () => context.push(
                  AppRouter.addEditTransaction,
                  extra: t,
                ),
              ))
          .toList(),
    );
  }
}
