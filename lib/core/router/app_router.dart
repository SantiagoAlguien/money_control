import 'package:go_router/go_router.dart';
import 'package:money_control/features/transactions/domain/entities/transaction.dart';
import 'package:money_control/features/transactions/presentation/screens/add_edit_transaction_screen.dart';
import 'package:money_control/features/transactions/presentation/screens/dashboard_screen.dart';
import 'package:money_control/features/transactions/presentation/screens/transactions_screen.dart';

// Fecha: 2026-06-26
// Configuración centralizada de rutas de la aplicación con Go Router.
abstract final class AppRouter {
  static const String dashboard = '/';
  static const String transactions = '/transactions';
  static const String addEditTransaction = '/add-edit-transaction';

  static GoRouter get router => GoRouter(
        initialLocation: dashboard,
        routes: [
          GoRoute(
            path: dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: transactions,
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: addEditTransaction,
            builder: (context, state) {
              final transaction = state.extra as Transaction?;
              return AddEditTransactionScreen(transaction: transaction);
            },
          ),
        ],
      );
}
