import 'package:go_router/go_router.dart';
import 'package:stylemake/core/widgets/app_shell.dart';
import 'package:stylemake/features/masters/screens/masters_home_screen.dart';
import 'package:stylemake/features/production/screens/production_home_screen.dart';
import 'package:stylemake/features/reports/screens/reports_home_screen.dart';

/// Application router configuration using go_router
class AppRouter {
  AppRouter._();

  /// Route paths
  static const String production = '/';
  static const String masters = '/masters';
  static const String reports = '/reports';

  /// Router configuration with ShellRoute for AppShell
  static final GoRouter router = GoRouter(
    initialLocation: production,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: production,
            name: 'production',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProductionHomeScreen()),
          ),
          GoRoute(
            path: masters,
            name: 'masters',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MastersHomeScreen()),
          ),
          GoRoute(
            path: reports,
            name: 'reports',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReportsHomeScreen()),
          ),
        ],
      ),
    ],
  );
}
