import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/products/presentation/products_providers.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/dues_models.dart';
import 'package:mandi_khata_app/features/shop_reports/domain/gst_models.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_dues_screen.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_gst_screen.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_profit_screen.dart';
import 'package:mandi_khata_app/features/shop_reports/presentation/shop_reports_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

Future<void> pump(
  WidgetTester tester,
  Widget screen, {
  MemberRole role = MemberRole.owner,
  bool shopOn = true,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(1400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        shopModuleEnabledProvider.overrideWithValue(shopOn),
        activeMembershipProvider.overrideWithValue(
          Membership(tenantId: 't1', tenantName: 'Gupta Arhat', role: role),
        ),
        ...overrides,
      ],
      child: MaterialApp(
        theme: MkTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SupplierPayable supplier() => SupplierPayable(
  partyId: 's1',
  name: 'Agro Supplies',
  code: 'S-1',
  outstanding: const Money(300000),
  oldestDue: LedgerDate(2026, 9, 1),
  daysOverdue: 39,
  openBills: const [],
  khataBalance: const Money(-300000),
);

CustomerReceivable customer(String id, Money receivable) => CustomerReceivable(
  partyId: id,
  name: 'Cust $id',
  code: null,
  shopSales: const Money(400000),
  shopReturns: Money.zero,
  receivable: receivable,
  khataBalance: const Money(-600000),
  lastSale: null,
);

void main() {
  testWidgets('dues: payables show overdue, Pay is offered', (tester) async {
    await pump(
      tester,
      const ShopDuesScreen(),
      overrides: [
        supplierPayablesProvider.overrideWith(
          (ref, today) => Stream.value([supplier()]),
        ),
        customerReceivablesProvider.overrideWith(
          (ref) => Stream.value(const []),
        ),
      ],
    );
    expect(find.text('Agro Supplies'), findsOneWidget);
    expect(find.text('39 days overdue'), findsOneWidget);
    expect(find.byKey(const ValueKey('pay-s1')), findsOneWidget);
    expect(find.byKey(const ValueKey('dues-note')), findsOneWidget);
    expect(find.textContaining('₹3,000'), findsWidgets);
  });

  testWidgets('dues: Collect is disabled when the party owes nothing net', (
    tester,
  ) async {
    await pump(
      tester,
      const ShopDuesScreen(),
      overrides: [
        supplierPayablesProvider.overrideWith((ref, today) => Stream.value([])),
        customerReceivablesProvider.overrideWith(
          (ref) => Stream.value([
            customer('c0', Money.zero),
            customer('c1', const Money(250000)),
          ]),
        ),
      ],
    );
    await tester.tap(find.text('Customer receivables'));
    await tester.pumpAndSettle();
    final off = tester.widget<MkButton>(
      find.byKey(const ValueKey('collect-c0')),
    );
    final on = tester.widget<MkButton>(
      find.byKey(const ValueKey('collect-c1')),
    );
    expect(off.onPressed, isNull);
    expect(on.onPressed, isNotNull);
    // The screen total is the sum of the capped receivables only.
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('dues-total'))).data,
      contains('₹2,500'),
    );
  });

  testWidgets('module off hides the report', (tester) async {
    await pump(tester, const ShopDuesScreen(), shopOn: false);
    expect(find.byKey(const ValueKey('shop-module-off')), findsOneWidget);
  });

  testWidgets('profit is locked without shop.view_profit', (tester) async {
    await pump(tester, const ShopProfitScreen(), role: MemberRole.munshi);
    expect(find.byKey(const ValueKey('profit-locked')), findsOneWidget);
  });

  testWidgets('profit table for the owner', (tester) async {
    await pump(
      tester,
      const ShopProfitScreen(),
      overrides: [
        profitRecordsProvider.overrideWith(
          (ref, args) => Stream.value([
            SaleLineRecord(
              productId: 'p1',
              productName: 'Urea',
              date: LedgerDate(2026, 10, 1),
              qtyMilli: 1000,
              revenue: const Money(50000),
              cogs: const Money(40000),
            ),
          ]),
        ),
      ],
    );
    expect(find.text('Urea'), findsOneWidget);
    expect(find.text('20%'), findsWidgets);
  });

  testWidgets('GST shows the banner when GSTIN and state are missing', (
    tester,
  ) async {
    final report = Gstr1Report.build(
      invoices: const [],
      tenantGstin: '',
      tenantStateCode: '',
      year: 2026,
      month: 10,
    );
    await pump(
      tester,
      const ShopGstScreen(),
      overrides: [
        gstMonthProvider.overrideWith(
          (ref, args) => Stream.value(
            GstMonthData(
              report: report,
              invoices: const [],
              summary: GstSummary.of(const []),
              flags: const [
                GstProductFlag(
                  productId: 'p9',
                  sku: 'DAP',
                  name: 'DAP',
                  hsn: null,
                  rateBp: 500,
                  issues: [GstIssue.missingHsn],
                ),
              ],
              tenantGstin: '',
              tenantStateCode: '',
            ),
          ),
        ),
      ],
    );
    expect(find.byKey(const ValueKey('gst-missing-banner')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('gst-tab-issues')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('flag-p9')), findsOneWidget);
  });
}
