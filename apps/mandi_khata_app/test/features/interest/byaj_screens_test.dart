import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/interest/presentation/bulk_interest_screen.dart';
import 'package:mandi_khata_app/features/interest/presentation/interest_providers.dart';
import 'package:mandi_khata_app/features/interest/presentation/party_byaj_tab.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_detail_screen.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

class _FixedTenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

class _FakeWriter implements PartyInterestWriter {
  final calls = <({String partyId, Map<String, Object?> values})>[];

  @override
  Future<SettingWriteFailure?> apply(
    String partyId,
    Map<String, Object?> values, {
    required Set<String> existingKeys,
  }) async {
    calls.add((partyId: partyId, values: values));
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('$i');
}

final today = LedgerDate.fromDateTime(DateTime.now());

Party partyOf({
  Set<PartyRole> roles = const {PartyRole.farmer},
  String id = 'p1',
  String? village,
}) => Party(
  id: id,
  code: 'F-$id',
  name: 'Gurmeet $id',
  roles: roles,
  village: village,
);

SettingRow tenantRow(String key, Object? value) =>
    SettingRow(scope: SettingScope.tenant, key: key, value: value);

SettingRow partyRow(String key, Object? value, {String id = 'p1'}) =>
    SettingRow(scope: SettingScope.party, scopeId: id, key: key, value: value);

LedgerEntry udhaar(int rupees, LedgerDate date, {String id = 'e1'}) =>
    LedgerEntry(
      id: id,
      partyId: 'p1',
      entryDate: date,
      side: Side.udhaar,
      amount: Money.rupees(rupees),
      refType: RefType.journal,
      createdAt: DateTime.utc(2026, 1, 2),
    );

void main() {
  late _FakeWriter writer;

  setUp(() => writer = _FakeWriter());

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    Party? party,
    List<SettingRow> rows = const [],
    List<LedgerEntry> entries = const [],
    bool manage = true,
    List<Party> parties = const [],
    LoanDetail? loan,
  }) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = party ?? partyOf();
    final target = partyTarget(p);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeTenantProvider.overrideWith(_FixedTenant.new),
          settingRowsProvider(target).overrideWith((ref) => Stream.value(rows)),
          settingRowsProvider(
            businessTarget,
          ).overrideWith((ref) => Stream.value(rows)),
          partyEntriesProvider(
            'p1',
          ).overrideWith((ref) => Stream.value(entries)),
          partyInterestWriterProvider.overrideWithValue(writer),
          partyListProvider(
            '',
            null,
          ).overrideWith((ref) => Stream.value(parties)),
          partyProvider('p1').overrideWith((ref) => Stream.value(p)),
          if (loan != null)
            loanDetailProvider(
              'loan-1',
            ).overrideWith((ref) => Stream.value(loan)),
          canProvider(Permission.loansManage).overrideWithValue(manage),
          canProvider(Permission.paymentsCreate).overrideWithValue(manage),
          canProvider(Permission.entriesReverse).overrideWithValue(manage),
          canProvider(Permission.financeView).overrideWithValue(manage),
          syncIndicatorProvider.overrideWithValue(null),
        ],
        child: MaterialApp.router(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => Scaffold(body: home),
              ),
              GoRoute(path: '/parties', builder: (_, _) => const Text('list')),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder key(String k) => find.byKey(ValueKey(k));
  Money money(WidgetTester t, String k) => t.widget<MkMoneyText>(key(k)).amount;

  group('Byaj tab', () {
    testWidgets('khata mode: terms with their source and the live figures', (
      tester,
    ) async {
      await pump(
        tester,
        PartyByajTab(party: partyOf()),
        rows: [tenantRow('interest.rounding', 'paise')],
        entries: [udhaar(100000, today.addDays(-30))],
      );
      expect(key('byaj-khata-note'), findsOneWidget);
      expect(find.textContaining('18% a year'), findsOneWidget);
      expect(find.textContaining('App default'), findsWidgets);
      // 1,00,000 at 18% for 30 days = 1,479.45
      expect(money(tester, 'byaj-accrued'), const Money(147945));
      expect(money(tester, 'byaj-principal'), const Money.rupees(100000));
      expect(money(tester, 'byaj-payable'), const Money(10000000 + 147945));
      expect(key('loan-statement'), findsOneWidget);
    });

    testWidgets('a party override shows the party as the source', (
      tester,
    ) async {
      await pump(
        tester,
        PartyByajTab(party: partyOf()),
        rows: [partyRow('interest.rate_pa', '24')],
        entries: [udhaar(100000, today.addDays(-30))],
      );
      expect(find.text('24% a year · From the party'), findsOneWidget);
    });

    testWidgets('loans_only: says so and runs no khata engine', (tester) async {
      await pump(
        tester,
        PartyByajTab(party: partyOf()),
        rows: [tenantRow('interest.apply_on', 'loans_only')],
        entries: [udhaar(100000, today.addDays(-30))],
      );
      expect(key('byaj-loans-only'), findsOneWidget);
      expect(key('byaj-figures'), findsNothing);
      expect(key('loan-statement'), findsNothing);
    });

    testWidgets('a supplier gets no interest by default; no figures charged', (
      tester,
    ) async {
      await pump(
        tester,
        PartyByajTab(party: partyOf(roles: {PartyRole.supplier})),
        entries: [udhaar(100000, today.addDays(-30))],
      );
      expect(key('byaj-off'), findsOneWidget);
      expect(find.byKey(const ValueKey('byaj-accrued')), findsNothing);
    });

    testWidgets('only members with loans.manage can edit the terms', (
      tester,
    ) async {
      await pump(
        tester,
        PartyByajTab(party: partyOf()),
        manage: false,
        entries: [udhaar(1000, today.addDays(-3))],
      );
      expect(key('byaj-edit'), findsNothing);
    });

    testWidgets('editing saves only what differs from the business default', (
      tester,
    ) async {
      await pump(
        tester,
        PartyByajTab(party: partyOf()),
        entries: [udhaar(1000, today.addDays(-3))],
      );
      await tester.tap(key('byaj-edit'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: key('terms-grace'),
          matching: find.byType(TextField),
        ),
        '15',
      );
      await tester.tap(key('byaj-save'));
      await tester.pumpAndSettle();
      expect(writer.calls, hasLength(1));
      final v = writer.calls.single.values;
      expect(writer.calls.single.partyId, 'p1');
      expect(v['interest.grace_days'], 15);
      expect(v['interest.rate_pa'], isNull);
      expect(v['interest.method'], isNull);
    });

    testWidgets('"no interest for this party" writes only interest.enabled', (
      tester,
    ) async {
      await pump(
        tester,
        PartyByajTab(party: partyOf()),
        entries: [udhaar(1000, today.addDays(-3))],
      );
      await tester.tap(key('byaj-edit'));
      await tester.pumpAndSettle();
      await tester.tap(key('terms-enabled'));
      await tester.pumpAndSettle();
      await tester.tap(key('byaj-save'));
      await tester.pumpAndSettle();
      expect(writer.calls.single.values, {'interest.enabled': false});
    });
  });

  group('loan detail', () {
    LoanDetail loanDetail() => LoanDetail(
      loan: Loan(
        id: 'loan-1',
        loanNo: 'KZ-W1-0001',
        partyId: 'p1',
        partyName: 'Gurmeet p1',
        issueDate: today.addDays(-30),
        principal: const Money.rupees(100000),
        config: InterestConfig(
          ratePa: Decimal.fromInt(18),
          applyOn: ApplyOn.loansOnly,
        ),
        status: LoanStatus.active,
        createdAt: DateTime.utc(2026, 1, 2),
      ),
      entries: const [],
      rateChanges: const [],
    );

    testWidgets('net_udhaar: a notice says the loan is inside the khata byaj', (
      tester,
    ) async {
      await pump(
        tester,
        const LoanDetailScreen(loanId: 'loan-1'),
        loan: loanDetail(),
      );
      expect(key('loan-in-khata-note'), findsOneWidget);
    });

    testWidgets('loans_only: no notice, the loan runs its own byaj', (
      tester,
    ) async {
      await pump(
        tester,
        const LoanDetailScreen(loanId: 'loan-1'),
        loan: loanDetail(),
        rows: [tenantRow('interest.apply_on', 'loans_only')],
      );
      expect(key('loan-in-khata-note'), findsNothing);
    });
  });

  group('bulk apply', () {
    final parties = [
      partyOf(village: 'Rampura'),
      partyOf(id: 'p2', village: 'Rampura'),
      partyOf(id: 'p3', village: 'Sadhaura'),
    ];

    testWidgets('applies explicit terms to the parties of one village', (
      tester,
    ) async {
      await pump(tester, const BulkInterestScreen(), parties: parties);
      await tester.tap(key('bulk-village-Rampura'));
      await tester.pumpAndSettle();
      expect(key('bulk-party-p3'), findsNothing);
      await tester.tap(key('bulk-select-all'));
      await tester.pumpAndSettle();
      await tester.tap(key('bulk-apply'));
      await tester.pumpAndSettle();
      expect(writer.calls.map((c) => c.partyId), ['p1', 'p2']);
      expect(writer.calls.first.values['interest.rate_pa'], '18');
      expect(writer.calls.first.values['interest.enabled'], isTrue);
      expect(find.text('Interest terms set for 2 parties'), findsOneWidget);
    });

    testWidgets('nothing selected: apply is disabled', (tester) async {
      await pump(tester, const BulkInterestScreen(), parties: parties);
      expect(tester.widget<MkButton>(key('bulk-apply')).onPressed, isNull);
    });

    testWidgets('without loans.manage the screen refuses', (tester) async {
      await pump(
        tester,
        const BulkInterestScreen(),
        parties: parties,
        manage: false,
      );
      expect(key('bulk-apply'), findsNothing);
    });
  });
}
