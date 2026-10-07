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
import 'package:mandi_khata_app/features/reports/presentation/reports_screen.dart';
import 'package:mandi_khata_app/features/team/presentation/team_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Where the sidebar, the rail and the phone's "More" sheet can go.
/// The route doubles as the id; a screen belongs to the destination whose
/// route is the longest prefix of its location.
const settingsRoute = '/settings';

/// One entry of the navigation, before it is translated.
class NavDestination {
  const NavDestination(this.route, this.icon, this.label, {this.permissions});

  final String route;
  final IconData icon;
  final String Function(AppLocalizations) label;

  /// Shown when the member has any one of these; null = everyone.
  final List<Permission>? permissions;
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
}) => [
  for (final g in navGroups)
    if (_visible(g, can).isNotEmpty)
      MkNavSection(
        id: g.id,
        title: g.title(l10n),
        items: [
          for (final d in _visible(g, can))
            MkNavItem(
              id: d.route,
              icon: d.icon,
              label: d.label(l10n),
              badge: badges[d.route],
            ),
        ],
      ),
];

List<NavDestination> _visible(NavGroup g, bool Function(Permission) can) => [
  for (final d in g.items)
    if (d.permissions == null || d.permissions!.any(can)) d,
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
