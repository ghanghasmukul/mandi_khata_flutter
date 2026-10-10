import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';

/// One feature switch an admin can give or take away from a user.
class FeatureDef {
  const FeatureDef(this.permission, this.label, this.help);

  final Permission permission;
  final String label;
  final String help;

  String get key => permission.key;
}

/// A titled group of switches.
class FeatureGroup {
  const FeatureGroup(this.title, this.icon, this.features);

  final String title;
  final IconData icon;
  final List<FeatureDef> features;
}

/// Every permission the app and the database understand, in groups an admin
/// reads in plain words. The keys are `khata_core` [Permission]s: the SAME
/// ones RLS checks, so a switch here is enforced on the server.
const featureGroups = <FeatureGroup>[
  FeatureGroup('Mandi work', Icons.agriculture_outlined, [
    FeatureDef(
      Permission.partiesManage,
      'Parties',
      'Add and edit farmers, buyers, customers and their documents.',
    ),
    FeatureDef(
      Permission.arrivalsManage,
      'Arrivals and lots',
      'Record arrivals, weighment and lot sales.',
    ),
    FeatureDef(
      Permission.paymentsCreate,
      'Payments and expenses',
      'Take and make payments, record expenses, use the cash book.',
    ),
  ]),
  FeatureGroup('Money and books', Icons.account_balance_outlined, [
    FeatureDef(
      Permission.entriesReverse,
      'Correct entries',
      'Reverse or correct posted entries, vouchers, imports, back-dating.',
    ),
    FeatureDef(
      Permission.loansManage,
      'Loans and interest',
      'Issue loans (karza), change rates, post interest.',
    ),
    FeatureDef(
      Permission.financeView,
      'Accounts and bank',
      'See bank accounts, journal, reports, profit and the export to Tally.',
    ),
  ]),
  FeatureGroup('Input shop', Icons.storefront_outlined, [
    FeatureDef(
      Permission.productsManage,
      'Products',
      'Add and edit products, prices and categories.',
    ),
    FeatureDef(
      Permission.purchasesCreate,
      'Purchases',
      'Record supplier bills and purchase returns.',
    ),
    FeatureDef(
      Permission.salesCreate,
      'Sell at the counter',
      'Use the POS and issue invoices.',
    ),
    FeatureDef(
      Permission.salesReturn,
      'Sales returns',
      'Take back goods and issue credit.',
    ),
    FeatureDef(
      Permission.stockAdjust,
      'Stock adjustments',
      'Count stock, write off, change batches.',
    ),
    FeatureDef(
      Permission.shopViewProfit,
      'Shop profit and cost',
      'See cost prices and profit reports.',
    ),
  ]),
  FeatureGroup('Business control', Icons.admin_panel_settings_outlined, [
    FeatureDef(
      Permission.settingsManage,
      'Business settings',
      'Change rates, charges and other settings of the business.',
    ),
    FeatureDef(
      Permission.masterDelete,
      'Delete master data',
      'Delete parties, products and documents.',
    ),
    FeatureDef(Permission.auditView, 'Audit log', 'Read who changed what.'),
    FeatureDef(
      Permission.adminManage,
      'Users, billing and export',
      'Manage staff, plan, backups and data export.',
    ),
  ]),
];

/// Roles an admin can give, with a one-line meaning.
const roleHelp = <MemberRole, String>{
  MemberRole.owner: 'Everything in the business. Cannot be limited.',
  MemberRole.accountant: 'Books, payments, shop work; no business control.',
  MemberRole.munshi: 'Day-to-day mandi work at the gate.',
  MemberRole.custom: 'Starts with nothing; you switch on what they need.',
};

/// How a switch stands for a user.
enum Access {
  /// Follows the role.
  byRole,
  allow,
  deny;

  static Access of(Map<String, Object?> custom, String key) {
    final v = custom[key];
    return v is bool ? (v ? allow : deny) : byRole;
  }
}

/// What the user can really do: the override if any, else the role default.
bool effective(MemberRole role, Map<String, Object?> custom, Permission p) =>
    hasPermission(role, custom, p);
