import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/pos/domain/pos_cart.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_providers.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_screen.dart';
import 'package:mandi_khata_app/features/shop_sales/domain/shop_sale.dart';
import 'package:mandi_khata_app/features/shop_sales/presentation/sales_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

import '../khata/fake_ledger_repository.dart';
import '../parties/parties_screens_test.dart' show FakePartiesRepository;
import '../payments/fake_payments_repository.dart';
import '../settings/settings_screen_test.dart' show FakeSettingsRepository;

const ctx = WriteContext(
  tenantId: 't1',
  userId: 'u1',
  deviceId: 'd1',
  deviceCode: 'W1',
);

class _FixedTenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

class _FakeWriter implements SaleWriter {
  final drafts = <SaleDraft>[];

  @override
  Future<SaleSaveResult> create(SaleDraft draft) async {
    drafts.add(draft);
    return const SaleSaved('s1', 'SI-W1-0001');
  }

  @override
  Future<SaleSaveResult> reverse(String id) => throw UnimplementedError();

  @override
  Future<ReturnSaveResult> createReturn(ReturnDraft draft) =>
      throw UnimplementedError();
}

PosProduct product(String id, String name, {int price = 105}) => PosProduct(
  id: id,
  sku: 'SKU-$id',
  barcode: '890$id',
  name: name,
  unit: 'bag',
  hsn: '3105',
  rateBp: 500,
  prices: TierPrices({'retail': Money.rupees(price)}),
  stockMilli: 50000,
);

const gurmeet = Party(
  id: 'p-gurmeet',
  code: 'F-1',
  name: 'Gurmeet Singh',
  roles: {PartyRole.farmer},
  village: 'Bhucho',
);

void main() {
  late _FakeWriter writer;
  final products = [
    product('1', 'Urea'),
    product('2', 'DAP'),
    product('3', 'Potash'),
    product('4', 'Zinc'),
    product('5', 'Hybrid Seed'),
  ];

  setUp(() => writer = _FakeWriter());

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1400, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posCatalogProvider.overrideWith((ref) => Stream.value(products)),
          heldBillsProvider.overrideWith((ref) => Stream.value(const [])),
          saleWriterProvider.overrideWithValue(writer),
          partiesRepositoryProvider.overrideWith(
            (ref) async => FakePartiesRepository()..parties.add(gurmeet),
          ),
          ledgerRepositoryProvider.overrideWith(
            (ref) async => FakeLedgerRepository(),
          ),
          bankAccountsRepositoryProvider.overrideWith(
            (ref) async => FakeBankAccountsRepository(),
          ),
          settingsRepositoryProvider.overrideWith(
            (ref) async => FakeSettingsRepository(),
          ),
          activeTenantProvider.overrideWith(_FixedTenant.new),
          writeContextProvider.overrideWithValue(ctx),
          activeMembershipProvider.overrideWithValue(
            const Membership(
              tenantId: 't1',
              tenantName: 'Gupta',
              role: MemberRole.owner,
            ),
          ),
          syncIndicatorProvider.overrideWithValue(null),
        ],
        child: MaterialApp(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PosScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder key(String k) => find.byKey(ValueKey(k));

  Future<void> typeAndEnter(WidgetTester tester, Finder f, String text) async {
    await tester.enterText(f, text);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('5-item udhaar bill with the keyboard only', (tester) async {
    await pump(tester);
    // F2 new bill: search is focused.
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pumpAndSettle();
    // Barcode (exact match) then names; "2*" prefix is a quantity.
    await typeAndEnter(tester, key('pos-search'), '8901');
    await typeAndEnter(tester, key('pos-search'), '2*dap');
    await typeAndEnter(tester, key('pos-search'), 'potash');
    await typeAndEnter(tester, key('pos-search'), 'zinc');
    await typeAndEnter(tester, key('pos-search'), 'hybrid');
    expect(find.byKey(const ValueKey('pos-cart-line-4')), findsOneWidget);
    expect(find.byKey(const ValueKey('pos-qty-1')), findsOneWidget);
    expect(
      tester.widget<Text>(key('pos-qty-1')).data,
      '2',
      reason: '2*dap added two',
    );
    // + on the selected (last) line, then - again.
    await tester.sendKeyEvent(LogicalKeyboardKey.numpadAdd);
    await tester.pump();
    expect(tester.widget<Text>(key('pos-qty-4')).data, '2');
    await tester.sendKeyEvent(LogicalKeyboardKey.numpadSubtract);
    await tester.pump();
    expect(tester.widget<Text>(key('pos-qty-4')).data, '1');

    // F4: customer. Type, Enter picks.
    await tester.sendKeyEvent(LogicalKeyboardKey.f4);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(of: key('pos-party'), matching: find.byType(TextField)),
      'gurmeet',
    );
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Gurmeet Singh'), findsWidgets);

    // F10 pay; Alt+3 all on udhaar; F10 saves.
    await tester.sendKeyEvent(LogicalKeyboardKey.f10);
    await tester.pumpAndSettle();
    expect(key('pay-save'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.f10);
    await tester.pumpAndSettle();

    expect(writer.drafts, hasLength(1));
    final d = writer.drafts.single;
    expect(d.partyId, 'p-gurmeet');
    expect(d.lines, hasLength(5));
    // 4 singles + 2 DAP = 6 units x 105.
    expect(d.lines.fold<int>(0, (a, l) => a + l.qtyMilli), 6000);
    expect(d.payment.udhaar, const Money.rupees(630));
    expect(d.payment.cash, Money.zero);
    expect(d.tier, 'farmer');
    // Saved dialog; Enter-style "new bill" closes it.
    expect(key('pos-saved-body'), findsOneWidget);
    expect(find.textContaining('SI-W1-0001'), findsOneWidget);
    await tester.tap(key('pos-next'));
    await tester.pumpAndSettle();
    expect(key('pos-cart-line-0'), findsNothing, reason: 'cart cleared');
  });

  testWidgets('udhaar without a customer is refused in the dialog', (
    tester,
  ) async {
    await pump(tester);
    await typeAndEnter(tester, key('pos-search'), 'urea');
    await tester.sendKeyEvent(LogicalKeyboardKey.f10);
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    // Alt+3 is a no-op without a party; force an udhaar amount instead.
    await tester.enterText(
      find.descendant(of: key('pay-cash-0'), matching: find.byType(TextField)),
      '0',
    );
    await tester.enterText(
      find.descendant(
        of: key('pay-udhaar-0'),
        matching: find.byType(TextField),
      ),
      '105',
    );
    await tester.tap(key('pay-save'));
    await tester.pumpAndSettle();
    expect(key('pay-error'), findsOneWidget);
    expect(writer.drafts, isEmpty);
  });

  testWidgets('phone layout: 48 px targets and the cart is usable', (
    tester,
  ) async {
    await pump(tester, size: const Size(390, 800));
    await typeAndEnter(tester, key('pos-search'), 'urea');
    expect(key('pos-cart-line-0'), findsOneWidget);
    expect(tester.getSize(key('pos-inc-0')).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(key('pos-pay')).height, greaterThanOrEqualTo(40));
    expect(tester.takeException(), isNull);
  });
}
