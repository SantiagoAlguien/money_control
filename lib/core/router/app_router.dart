import 'package:go_router/go_router.dart';
import 'package:money_control/features/transactions/presentation/screens/dashboard_screen.dart';
import 'package:money_control/features/transactions/presentation/screens/transactions_screen.dart';

abstract final class AppRouter {
  static const String dashboard = '/';
  static const String transactions = '/transactions';

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
        ],
      );
}
