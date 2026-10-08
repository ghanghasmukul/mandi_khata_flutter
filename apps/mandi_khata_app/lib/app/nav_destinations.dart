import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_screen.dart';
import 'package:mandi_khata_app/features/audit/presentation/audit_screen.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_screen.dart';
import 'package:mandi_khata_app/features/khata/presentation/day_book_screen.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_screen.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_screen.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_screen.dart'
    show PosRoutes;
import 'package:mandi_khata_app/features/products/presentation/products_routes.dart';
import 'package:mandi_khata_app/features/purchases/presentation/purchases_labels.dart';
import 'package:mandi_khata_app/features/reports/presentation/reports_screen.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_routes.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/sales_screen.dart'
    show SalesRoutes;
import 'package:mandi_khata_app/features/team/presentation/team_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Where the sidebar, the rail and the phone's "More" sheet can go.
/// The route doubles as the id; a screen belongs to the destination whose
/// route is the longest prefix of its location.
const settingsRoute = '/settings';

/// One entry of the navigation, before it is translated.
class NavDestination {
  const NavDestination(
    this.route,
    this.icon,
    this.label, {
    this.permissions,
    this.module,
  });

  final String route;
  final IconData icon;
  final String Function(AppLocalizations) label;

  /// Shown when the member has any one of these; null = everyone.
  final List<Permission>? permissions;

  /// The `app.modules.<name>` switch this entry belongs to; null = always.
  final String? module;
}

class NavGroup {
  const NavGroup(this.id, this.title, this.items);

  final String id;
  final String Function(AppLocalizations) title;
  final List<NavDestination> items;
}

/// The whole menu (docs: design/Mandi_Khata.html, sidebar), in order.
final List<NavGroup> navGroups = <NavGroup>[
  NavGroup('daily', (l) => l.navSectionDaily, [
    NavDestination(
      GateRoutes.home,
      Icons.dashboard_outlined,
      (l) => l.navDashboard,
    ),
    NavDestination(
      ArrivalRoutes.list,
      Icons.agriculture_outlined,
      (l) => l.arrivalsTitle,
    ),
    NavDestination(
      PartyRoutes.list,
      Icons.groups_outlined,
      (l) => l.partiesTitle,
    ),
    NavDestination(
      KhataRoutes.dayBook,
      Icons.menu_book_outlined,
      (l) => l.khataDayBookTitle,
    ),
    NavDestination(
      PaymentRoutes.list,
      Icons.payments_outlined,
      (l) => l.paymentsTitle,
    ),
    NavDestination(
      LoanRoutes.list,
      Icons.request_quote_outlined,
      (l) => l.loansTitle,
    ),
  ]),
  NavGroup('shop', (l) => l.navSectionShop, [
    NavDestination(
      PosRoutes.pos,
      Icons.point_of_sale,
      (l) => l.posTitle,
      permissions: [Permission.salesCreate],
      module: 'shop',
    ),
    NavDestination(
      SalesRoutes.list,
      Icons.receipt_long_outlined,
      (l) => l.salesTitle,
      permissions: [Permission.salesCreate, Permission.salesReturn],
      module: 'shop',
    ),
    NavDestination(
      ProductRoutes.list,
      Icons.inventory_2_outlined,
      (l) => l.prodTitle,
      permissions: [Permission.productsManage],
      module: 'shop',
    ),
    NavDestination(
      PurchaseRoutes.list,
      Icons.local_shipping_outlined,
      (l) => l.purchasesTitle,
      permissions: [Permission.purchasesCreate],
      module: 'shop',
    ),
    NavDestination(
      ShopReportRoutes.dues,
      Icons.account_balance_wallet_outlined,
      (l) => l.shrNavDues,
      permissions: [Permission.financeView, Permission.paymentsCreate],
      module: 'shop',
    ),
    NavDestination(
      ShopReportRoutes.profit,
      Icons.trending_up,
      (l) => l.shrNavProfit,
      permissions: [Permission.shopViewProfit],
      module: 'shop',
    ),
    NavDestination(
      ShopReportRoutes.gst,
      Icons.receipt_long_outlined,
      (l) => l.shrNavGst,
      permissions: [Permission.financeView],
      module: 'shop',
    ),
  ]),
  NavGroup('money', (l) => l.navSectionMoney, [
    NavDestination(
      AccountRoutes.hub,
      Icons.account_balance_outlined,
      (l) => l.acctHubTitle,
      permissions: [
        Permission.entriesReverse,
        Permission.financeView,
        Permission.paymentsCreate,
      ],
    ),
    NavDestination(
      AccountRoutes.expenses,
      Icons.shopping_bag_outlined,
      (l) => l.expensesTitle,
      permissions: [Permission.paymentsCreate],
    ),
    NavDestination(
      AccountRoutes.cashBook,
      Icons.point_of_sale_outlined,
      (l) => l.cashBookTitle,
      permissions: [Permission.paymentsCreate],
    ),
    NavDestination(
      ReportRoutes.list,
      Icons.assessment_outlined,
      (l) => l.reportsTitle,
    ),
    NavDestination(CropRoutes.list, Icons.grass_outlined, (l) => l.cropsTitle),
  ]),
  NavGroup('admin', (l) => l.navSectionAdmin, [
    NavDestination(
      TeamRoutes.list,
      Icons.manage_accounts_outlined,
      (l) => l.teamTitle,
      permissions: [Permission.adminManage],
    ),
    NavDestination(
      AuditRoutes.list,
      Icons.history,
      (l) => l.auditTitle,
      permissions: [Permission.auditView],
    ),
    NavDestination(settingsRoute, Icons.tune, (l) => l.settingsTitle),
  ]),
];

/// The destinations [can] may see, grouped, translated, with [badges] (by
/// route) on the sidebar.
List<MkNavSection> navSections(
  AppLocalizations l10n,
  bool Function(Permission) can, {
  Map<String, String> badges = const {},
  bool Function(String module) moduleOn = _allModules,
}) => [
  for (final g in navGroups)
    if (_visible(g, can, moduleOn).isNotEmpty)
      MkNavSection(
        id: g.id,
        title: g.title(l10n),
        items: [
          for (final d in _visible(g, can, moduleOn))
            MkNavItem(
              id: d.route,
              icon: d.icon,
              label: d.label(l10n),
              badge: badges[d.route],
            ),
        ],
      ),
];

bool _allModules(String module) => true;

List<NavDestination> _visible(
  NavGroup g,
  bool Function(Permission) can,
  bool Function(String) moduleOn,
) => [
  for (final d in g.items)
    if ((d.permissions == null || d.permissions!.any(can)) &&
        (d.module == null || moduleOn(d.module!)))
      d,
];

/// The id of the destination [location] belongs to: the longest route that
/// is a path prefix of it (`/accounts/expenses` beats `/accounts`; `/` only
/// matches `/` itself). Null for screens outside the menu.
String? selectedNavId(String location, Iterable<String> routes) {
  String? best;
  for (final r in routes) {
    final matches = r == '/'
        ? location == '/'
        : location == r || location.startsWith('$r/');
    if (matches && (best == null || r.length > best.length)) best = r;
  }
  return best;
}

/// The four destinations the phone's bottom bar shows before "More".
const List<String> bottomRoutes = [
  GateRoutes.home,
  ArrivalRoutes.list,
  PartyRoutes.list,
  PaymentRoutes.list,
];
