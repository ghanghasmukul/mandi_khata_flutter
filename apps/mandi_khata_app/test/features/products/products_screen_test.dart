import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/products/domain/stock.dart';
import 'package:mandi_khata_app/features/products/presentation/products_providers.dart';
import 'package:mandi_khata_app/features/products/presentation/products_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

class _Tenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

Map<String, Object?> _product(String id, String name, int reorder) => {
  'id': id,
  'sku': 'S-$id',
  'name': name,
  'unit': 'bag',
  'gst_rate': 5.0,
  'reorder_level_milli': reorder,
  'prices': '{"retail": 30000, "farmer": 27000}',
  'is_active': 1,
};

void main() {
  final today = LedgerDate.fromDateTime(DateTime.now());
  final rows = StockProjection.build(
    productRows: [_product('p1', 'Urea 50kg', 5000), _product('p2', 'DAP', 0)],
    batchRows: [
      {
        'id': 'b1',
        'product_id': 'p1',
        'batch_no': 'B-7',
        'cost_paise': 24000,
        'qty_milli': 3000,
        'created_at': '2027-01-01T00:00:00Z',
      },
    ],
    movementSumRows: [
      {'product_id': 'p1', 'batch_id': 'b1', 'q': 3000},
    ],
  );
  final summary = StockProjection.summary(rows, today: today, warnDays: 60);

  Future<void> pump(
    WidgetTester tester, {
    MemberRole role = MemberRole.owner,
    Map<String, Object?> custom = const {},
  }) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const ProductsScreen())],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeTenantProvider.overrideWith(_Tenant.new),
          activeMembershipProvider.overrideWithValue(
            Membership(
              tenantId: 't1',
              tenantName: 'Gupta',
              role: role,
              customPermissions: custom,
            ),
          ),
          syncIndicatorProvider.overrideWithValue(null),
          expiryWarnDaysProvider.overrideWithValue(60),
          priceTiersProvider.overrideWithValue(const ['farmer', 'retail']),
          productListProvider.overrideWith((ref, filter) => Stream.value(rows)),
          stockSummaryProvider.overrideWith((ref) => Stream.value(summary)),
          productCategoriesProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp.router(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('owner sees tiles, batches, cost, margin and value', (t) async {
    await pump(t);
    expect(find.text('Products & stock'), findsOneWidget);
    expect(find.text('Urea 50kg'), findsOneWidget);
    expect(find.text('DAP'), findsOneWidget);
    // Stock value at cost: 3 bags x Rs 240 = Rs 720.
    expect(find.text('₹720'), findsWidgets);
    expect(find.textContaining('B-7: 3'), findsOneWidget);
    // Margin on the first tier with a price: (270-240)/270 = 11.11%.
    expect(find.text('11.11%'), findsOneWidget);
    expect(find.text('COST'), findsOneWidget);
    // Urea is low (3 <= 5), DAP is out.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('prod-tile-low')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('prod-tile-out')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('without shop.view_profit cost, margin and value are hidden', (
    t,
  ) async {
    await pump(
      t,
      role: MemberRole.munshi,
      custom: const {'products.manage': true},
    );
    expect(find.text('Urea 50kg'), findsOneWidget);
    expect(find.text('COST'), findsNothing);
    expect(find.text('MARGIN'), findsNothing);
    expect(find.text('VALUE'), findsNothing);
    expect(find.byKey(const ValueKey('prod-tile-value')), findsNothing);
    expect(find.text('₹720'), findsNothing);
    expect(find.text('11.11%'), findsNothing);
  });

  testWidgets('a member without products.manage gets no access', (t) async {
    await pump(t, role: MemberRole.munshi);
    expect(find.text('You do not have access to products.'), findsOneWidget);
    expect(find.text('Urea 50kg'), findsNothing);
  });
}
