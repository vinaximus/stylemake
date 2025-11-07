import 'package:go_router/go_router.dart';
import 'package:stylemake/shared/widgets/adaptive_app_shell.dart';

import 'package:stylemake/features/dispatch/presentation/views/dispatch_detail_screen.dart';
import 'package:stylemake/features/dispatch/presentation/views/dispatch_form_screen.dart';
import 'package:stylemake/features/dispatch/presentation/views/dispatch_home_screen.dart';
import 'package:stylemake/features/dispatch/presentation/views/dispatches_list_screen.dart';
import 'package:stylemake/features/fabric/presentation/views/fabric_home_screen.dart';
import 'package:stylemake/features/help/presentation/views/help_screen.dart';
import 'package:stylemake/features/masters/presentation/views/customers/customer_form_screen.dart';
import 'package:stylemake/features/masters/presentation/views/customers/customers_list_screen.dart';
import 'package:stylemake/features/masters/presentation/views/masters_home_screen.dart';
import 'package:stylemake/features/masters/presentation/views/styles/style_form_screen.dart';
import 'package:stylemake/features/masters/presentation/views/styles/styles_list_screen.dart';
import 'package:stylemake/features/masters/presentation/views/vendors/vendor_form_screen.dart';
import 'package:stylemake/features/masters/presentation/views/vendors/vendors_list_screen.dart';
import 'package:stylemake/features/production/presentation/views/bills/bill_form_screen.dart';
import 'package:stylemake/features/production/presentation/views/bills/bills_list_screen.dart';
import 'package:stylemake/features/production/presentation/views/cuttings/cutting_detail_screen.dart';
import 'package:stylemake/features/production/presentation/views/cuttings/cutting_form_screen.dart';
import 'package:stylemake/features/production/presentation/views/cuttings/cuttings_list_screen.dart';
import 'package:stylemake/features/production/presentation/views/issues/issue_form_screen.dart';
import 'package:stylemake/features/production/presentation/views/issues/issues_list_screen.dart';
import 'package:stylemake/features/production/presentation/views/pos/po_detail_screen.dart';
import 'package:stylemake/features/production/presentation/views/pos/po_form_screen.dart';
import 'package:stylemake/features/production/presentation/views/pos/pos_list_screen.dart';
import 'package:stylemake/features/production/presentation/views/production_home_screen.dart';
import 'package:stylemake/features/production/presentation/views/receipts/receipt_form_screen.dart';
import 'package:stylemake/features/production/presentation/views/receipts/receipts_list_screen.dart';
import 'package:stylemake/features/reports/presentation/views/production_summary_screen.dart';
import 'package:stylemake/features/reports/presentation/views/reports_home_screen.dart';
import 'package:stylemake/features/settings/presentation/views/settings_screen.dart';

/// Application router configuration using go_router
class AppRouter {
  AppRouter._();

  /// Route paths
  static const String production = '/';
  static const String fabric = '/fabric';
  static const String dispatch = '/dispatch';
  static const String masters = '/masters';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String help = '/help';

  // Style routes
  static const String stylesList = '/masters/styles';
  static const String stylesAdd = '/masters/styles/add';
  static String stylesEdit(String id) => '/masters/styles/$id/edit';

  // Vendor routes
  static const String vendorsList = '/masters/vendors';
  static const String vendorsAdd = '/masters/vendors/add';
  static String vendorsEdit(String id) => '/masters/vendors/$id/edit';

  // Customer routes
  static const String customersList = '/masters/customers';
  static const String customersAdd = '/masters/customers/add';
  static String customersEdit(String id) => '/masters/customers/$id/edit';

  // Dispatch routes
  static const String dispatchesList = '/dispatch/list';
  static const String dispatchesAdd = '/dispatch/add';
  static String dispatchesEdit(String id) => '/dispatch/$id/edit';
  static String dispatchesDetail(String id) => '/dispatch/$id/detail';

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
            path: fabric,
            name: 'fabric',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: FabricHomeScreen()),
          ),
          GoRoute(
            path: dispatch,
            name: 'dispatch',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DispatchHomeScreen()),
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
            path: settings,
            name: 'settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
          GoRoute(
            path: help,
            name: 'help',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HelpScreen()),
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
          // Customer routes
          GoRoute(
            path: customersList,
            name: 'customersList',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CustomersListScreen()),
          ),
          GoRoute(
            path: customersAdd,
            name: 'customersAdd',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CustomerFormScreen()),
          ),
          GoRoute(
            path: '/masters/customers/:id/edit',
            name: 'customersEdit',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(
                child: CustomerFormScreen(customerId: id),
              );
            },
          ),
          // Dispatch routes
          GoRoute(
            path: dispatchesList,
            name: 'dispatchesList',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DispatchesListScreen()),
          ),
          GoRoute(
            path: dispatchesAdd,
            name: 'dispatchesAdd',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DispatchFormScreen()),
          ),
          GoRoute(
            path: '/dispatch/:id/edit',
            name: 'dispatchesEdit',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(
                child: DispatchFormScreen(dispatchId: id),
              );
            },
          ),
          GoRoute(
            path: '/dispatch/:id/detail',
            name: 'dispatchesDetail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(
                child: DispatchDetailScreen(dispatchId: id),
              );
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
