import 'package:go_router/go_router.dart';
import 'package:stylemake/core/widgets/adaptive_app_shell.dart';
import 'package:stylemake/features/masters/screens/masters_home_screen.dart';
import 'package:stylemake/features/masters/screens/styles/style_form_screen.dart';
import 'package:stylemake/features/masters/screens/styles/styles_list_screen.dart';
import 'package:stylemake/features/masters/screens/vendors/vendor_form_screen.dart';
import 'package:stylemake/features/masters/screens/vendors/vendors_list_screen.dart';
import 'package:stylemake/features/production/screens/bills/bill_form_screen.dart';
import 'package:stylemake/features/production/screens/bills/bills_list_screen.dart';
import 'package:stylemake/features/production/screens/cuttings/cutting_detail_screen.dart';
import 'package:stylemake/features/production/screens/cuttings/cutting_form_screen.dart';
import 'package:stylemake/features/production/screens/cuttings/cuttings_list_screen.dart';
import 'package:stylemake/features/production/screens/issues/issue_form_screen.dart';
import 'package:stylemake/features/production/screens/issues/issues_list_screen.dart';
import 'package:stylemake/features/production/screens/pos/po_detail_screen.dart';
import 'package:stylemake/features/production/screens/pos/po_form_screen.dart';
import 'package:stylemake/features/production/screens/pos/pos_list_screen.dart';
import 'package:stylemake/features/production/screens/production_home_screen.dart';
import 'package:stylemake/features/production/screens/receipts/receipt_form_screen.dart';
import 'package:stylemake/features/production/screens/receipts/receipts_list_screen.dart';
import 'package:stylemake/features/reports/screens/reports_home_screen.dart';
import 'package:stylemake/features/reports/screens/production_summary_screen.dart';

/// Application router configuration using go_router
class AppRouter {
  AppRouter._();

  /// Route paths
  static const String production = '/';
  static const String masters = '/masters';
  static const String reports = '/reports';

  // Style routes
  static const String stylesList = '/masters/styles';
  static const String stylesAdd = '/masters/styles/add';
  static String stylesEdit(String id) => '/masters/styles/$id/edit';

  // Vendor routes
  static const String vendorsList = '/masters/vendors';
  static const String vendorsAdd = '/masters/vendors/add';
  static String vendorsEdit(String id) => '/masters/vendors/$id/edit';

  // Cutting routes
  static const String cuttingsList = '/production/cuttings';
  static const String cuttingsAdd = '/production/cuttings/add';
  static String cuttingsEdit(String id) => '/production/cuttings/$id/edit';
  static String cuttingsDetail(String id) => '/production/cuttings/$id';

  // PO routes
  static const String posList = '/production/pos';
  static const String posAdd = '/production/pos/add';
  static String posEditPath(String id) => '/production/pos/$id/edit';
  static String posDetailPath(String id) => '/production/pos/$id';

  // Issue routes
  static const String issuesList = '/production/issues';
  static const String issuesAdd = '/production/issues/add';
  static String issuesEdit(String id) => '/production/issues/$id/edit';

  // Bill routes
  static const String billsList = '/production/bills';
  static const String billsAdd = '/production/bills/add';
  static String billsEdit(String id) => '/production/bills/$id/edit';

  // Receipt routes
  static const String receiptsList = '/production/receipts';
  static const String receiptsAdd = '/production/receipts/add';
  static String receiptsEdit(String id) => '/production/receipts/$id/edit';

  // Reports
  static const String productionSummary = '/reports/production-summary';

  /// Router configuration with ShellRoute for AppShell
  static final GoRouter router = GoRouter(
    initialLocation: production,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AdaptiveAppShell(child: child);
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
          GoRoute(
            path: productionSummary,
            name: 'productionSummary',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProductionSummaryScreen()),
          ),
          // Style routes
          GoRoute(
            path: stylesList,
            name: 'stylesList',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StylesListScreen()),
          ),
          GoRoute(
            path: stylesAdd,
            name: 'stylesAdd',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StyleFormScreen()),
          ),
          GoRoute(
            path: '/masters/styles/:id/edit',
            name: 'stylesEdit',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(child: StyleFormScreen(styleId: id));
            },
          ),
          // Vendor routes
          GoRoute(
            path: vendorsList,
            name: 'vendorsList',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: VendorsListScreen()),
          ),
          GoRoute(
            path: vendorsAdd,
            name: 'vendorsAdd',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: VendorFormScreen()),
          ),
          GoRoute(
            path: '/masters/vendors/:id/edit',
            name: 'vendorsEdit',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(child: VendorFormScreen(vendorId: id));
            },
          ),
          // Cutting routes
          GoRoute(
            path: cuttingsList,
            name: 'cuttingsList',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CuttingsListScreen()),
          ),
          GoRoute(
            path: cuttingsAdd,
            name: 'cuttingsAdd',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CuttingFormScreen()),
          ),
          GoRoute(
            path: '/production/cuttings/:id/edit',
            name: 'cuttingsEdit',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(child: CuttingFormScreen(cuttingId: id));
            },
          ),
          GoRoute(
            path: '/production/cuttings/:id',
            name: 'cuttingsDetail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(
                child: CuttingDetailScreen(cuttingId: id),
              );
            },
          ),
          // PO routes
          GoRoute(
            path: posList,
            name: 'posList',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PosListScreen()),
          ),
          GoRoute(
            path: posAdd,
            name: 'posAdd',
            pageBuilder: (context, state) {
              final cuttingId = state.uri.queryParameters['cuttingId'];
              return NoTransitionPage(
                child: PoFormScreen(cuttingId: cuttingId),
              );
            },
          ),
          GoRoute(
            path: '/production/pos/:id/edit',
            name: 'posEdit',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(child: PoFormScreen(poId: id));
            },
          ),
          GoRoute(
            path: '/production/pos/:id',
            name: 'posDetail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(child: PoDetailScreen(poId: id));
            },
          ),
          // Issue routes
          GoRoute(
            path: issuesList,
            name: 'issuesList',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: IssuesListScreen()),
          ),
          GoRoute(
            path: issuesAdd,
            name: 'issuesAdd',
            pageBuilder: (context, state) {
              final poId = state.uri.queryParameters['poId'];
              return NoTransitionPage(child: IssueFormScreen(poId: poId));
            },
          ),
          GoRoute(
            path: '/production/issues/:id/edit',
            name: 'issuesEdit',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(child: IssueFormScreen(issueId: id));
            },
          ),
          // Bill routes
          GoRoute(
            path: billsList,
            name: 'billsList',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BillsListScreen()),
          ),
          GoRoute(
            path: billsAdd,
            name: 'billsAdd',
            pageBuilder: (context, state) {
              final poId = state.uri.queryParameters['poId'];
              return NoTransitionPage(child: BillFormScreen(poId: poId));
            },
          ),
          GoRoute(
            path: '/production/bills/:id/edit',
            name: 'billsEdit',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(child: BillFormScreen(billId: id));
            },
          ),

          // Receipt routes
          GoRoute(
            path: receiptsList,
            name: 'receiptsList',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReceiptsListScreen()),
          ),
          GoRoute(
            path: receiptsAdd,
            name: 'receiptsAdd',
            pageBuilder: (context, state) {
              final cuttingId = state.uri.queryParameters['cuttingId'];
              return NoTransitionPage(
                child: ReceiptFormScreen(prefillCuttingId: cuttingId),
              );
            },
          ),
          GoRoute(
            path: '/production/receipts/:id/edit',
            name: 'receiptsEdit',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(child: ReceiptFormScreen(receiptId: id));
            },
          ),
        ],
      ),
    ],
  );
}
