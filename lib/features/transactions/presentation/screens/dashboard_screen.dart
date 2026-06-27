import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_control/core/di/providers.dart';
import 'package:money_control/core/router/app_router.dart';
import 'package:money_control/core/services/notification_permission_service.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/presentation/providers/dashboard_provider.dart';
import 'package:money_control/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:money_control/features/transactions/presentation/widgets/summary_card.dart';
import 'package:money_control/features/transactions/presentation/widgets/transaction_list_tile.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const String _sampleNotification =
      'TX EXITOSA en *8128.\nEl 2026.05.30 a las 08:00\nTRANSFERENCIA por \$100.000\nBanco Caja Social.';

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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _simulateTransfer(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Simular Transferencia Caja Social'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
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
      children: recent.map((t) => TransactionListTile(transaction: t)).toList(),
    );
  }

  Future<void> _simulateTransfer() async {
    final notifier = ref.read(transactionsProvider.notifier);
    final transaction = ref.read(parseNotificationProvider)(
      _sampleNotification,
      source: 'manual_simulation',
    );
    if (transaction == null) return;
    await notifier.saveTransaction(transaction);
    await ref.read(dashboardProvider.notifier).refresh();
  }
}
