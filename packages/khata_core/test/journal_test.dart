import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

final defaults = MandiConfig.resolve(SettingsResolver(const []));
final day = LedgerDate(2026, 10, 5);

SettingRow tenant(String key, Object? value) =>
    SettingRow(scope: SettingScope.tenant, key: key, value: value);

MandiConfig config(List<SettingRow> rows) =>
    MandiConfig.resolve(SettingsResolver(rows));

LotPostingPlan plan(
  MandiConfig c, {
  String? buyerId = 'buyer',
  int bags = 18,
  int qtlMilli = 8640,
  int rateRupees = 2425,
}) {
  final r = LotRules.planPosting(
    farmerId: 'farmer',
    bags: bags,
    qtlMilli: qtlMilli,
    rate: Money.rupees(rateRupees),
    config: c,
    buyerId: buyerId,
  );
  expect(r.problems, isEmpty);
  return r.plan!;
}

/// (account key, debit paise, credit paise) per line.
List<(String, int, int)> shape(JournalEntryDraft e) => [
  for (final l in e.lines) (l.account.key, l.debit.paise, l.credit.paise),
];

int net(JournalEntryDraft e, JournalAccount a) => e.lines
    .where((l) => l.account == a)
    .fold(0, (s, l) => s + l.debit.paise - l.credit.paise);

JournalAccount sys(SystemAccount a) => SystemJournalAccount(a);

void main() {
  group('JournalBuilder', () {
    test('builds a balanced entry', () {
      final e =
          (JournalBuilder()
                ..debit(const PartyAccount('p'), const Money(500))
                ..credit(sys(SystemAccount.interestIncome), const Money(500)))
              .build(sourceKey: 'x:1', date: day);
      expect(e.total, const Money(500));
      expect(e.isReversal, isFalse);
    });

    test('refuses an unbalanced entry', () {
      final b = JournalBuilder()
        ..debit(const PartyAccount('p'), const Money(500))
        ..credit(sys(SystemAccount.interestIncome), const Money(499));
      expect(
        () => b.build(sourceKey: 'x:1', date: day),
        throwsA(isA<JournalError>()),
      );
    });

    test('refuses fewer than two lines, a zero line and no source', () {
      expect(
        () => (JournalBuilder()..debit(const PartyAccount('p'), const Money(1)))
            .build(sourceKey: 'x', date: day),
        throwsA(isA<JournalError>()),
      );
      expect(
        () => JournalBuilder().debit(const PartyAccount('p'), Money.zero),
        throwsA(isA<JournalError>()),
      );
      final ok = JournalBuilder()
        ..debit(const PartyAccount('p'), const Money(1))
        ..credit(sys(SystemAccount.interestIncome), const Money(1));
      expect(
        () => ok.build(sourceKey: '', date: day),
        throwsA(isA<JournalError>()),
      );
    });

    test('a reversal swaps debit and credit, keeps the amounts, is final', () {
      final e = PostingRules.payment(
        paymentId: 'pay1',
        date: day,
        direction: PaymentDirection.toParty,
        partyId: 'f',
        bankAccountId: 'cash',
        amount: const Money.rupees(5000),
      );
      final r = e.reversal(LedgerDate(2026, 10, 7));
      expect(r.sourceKey, 'reversal:payment:pay1');
      expect(r.reversesKey, 'payment:pay1');
      expect(r.date, LedgerDate(2026, 10, 7));
      expect(shape(r), [('party:f', 0, 500000), ('book:cash', 500000, 0)]);
      expect(() => r.reversal(day), throwsStateError);
    });
  });

  group('party account group (posting-rules Q2)', () {
    test('customer or buyer means debtors, also when the party is more', () {
      expect(
        AccountGroup.forPartyRoles({PartyRole.customer}),
        AccountGroup.sundryDebtors,
      );
      expect(
        AccountGroup.forPartyRoles({PartyRole.farmer, PartyRole.buyer}),
        AccountGroup.sundryDebtors,
      );
      expect(
        AccountGroup.forPartyRoles({PartyRole.farmer}),
        AccountGroup.sundryCreditors,
      );
      expect(
        AccountGroup.forPartyRoles({PartyRole.supplier, PartyRole.vendor}),
        AccountGroup.sundryCreditors,
      );
      expect(
        AccountGroup.forPartyRoles(const {}),
        AccountGroup.sundryCreditors,
      );
    });

    test('codes are unique, the groups form a two-level tree', () {
      final codes = {for (final g in AccountGroup.values) g.code};
      expect(codes, hasLength(AccountGroup.values.length));
      expect({for (final a in SystemAccount.values) a.code}, hasLength(13));
      for (final g in AccountGroup.values) {
        expect(g.parent?.parent, isNull);
        if (g.parent != null) expect(g.parent!.nature, g.nature);
      }
    });
  });

  group('lot (posting-rules section 5)', () {
    test('Lot 1: Wheat, everything borne by the farmer, buyer picked', () {
      final e = PostingRules.lot(
        lotId: 'L1',
        date: day,
        plan: plan(defaults),
        lotNo: 'L-A4-0001',
      );
      expect(e.sourceKey, 'lot:L1');
      expect(shape(e), [
        ('party:buyer', 2095200, 0),
        ('party:farmer', 0, 1983276),
        ('system:commission_income', 0, 52380),
        ('system:palledari_receipts', 0, 21600),
        ('system:bardana_receipts', 0, 14400),
        ('system:tulai_receipts', 0, 2592),
        ('system:mandi_fee_payable', 0, 20952),
      ]);
      expect(e.total, const Money(2095200));
    });

    test('Lot 2: the buyer bears the palledari', () {
      final c = config([
        tenant('mandi.charges_borne_by', {'palledari': 'buyer'}),
      ]);
      final e = PostingRules.lot(lotId: 'L2', date: day, plan: plan(c));
      expect(shape(e), [
        ('party:buyer', 2116800, 0),
        ('party:farmer', 0, 2004876),
        ('system:commission_income', 0, 52380),
        ('system:palledari_receipts', 0, 21600),
        ('system:bardana_receipts', 0, 14400),
        ('system:tulai_receipts', 0, 2592),
        ('system:mandi_fee_payable', 0, 20952),
      ]);
    });

    test('no buyer: the debit side is Lot Sale Clearing', () {
      final e = PostingRules.lot(
        lotId: 'L3',
        date: day,
        plan: plan(defaults, buyerId: null),
      );
      expect(shape(e).first, ('system:lot_sale_clearing', 2095200, 0));
      expect(e.total, const Money(2095200));
    });

    test('a mandi fee the arhtiya bears is its own cost; waived commission '
        'and other arhtiya-borne charges write no line', () {
      final c = config([
        tenant('mandi.charges_borne_by', {
          'commission': 'arhtiya',
          'mandi_fee': 'arhtiya',
          'palledari': 'arhtiya',
        }),
      ]);
      final e = PostingRules.lot(lotId: 'L4', date: day, plan: plan(c));
      final p = plan(c);
      expect(p.breakdown.commissionEarned, Money.zero);
      expect(shape(e), [
        ('party:buyer', 2095200, 0),
        // net = gross − bardana 144.00 − tulai 25.92
        ('party:farmer', 0, 2095200 - 14400 - 2592),
        ('system:bardana_receipts', 0, 14400),
        ('system:tulai_receipts', 0, 2592),
        ('system:mandi_fee_own_cost', 20952, 0),
        ('system:mandi_fee_payable', 0, 20952),
      ]);
    });

    test('each cess is its own line named in the memo', () {
      final c = config([
        tenant('mandi.cess', [
          {'name': 'RDF', 'pct': '2'},
          {'name': 'Market', 'pct': '0.5'},
        ]),
      ]);
      final e = PostingRules.lot(lotId: 'L5', date: day, plan: plan(c));
      final cess = e.lines.where(
        (l) => l.account == sys(SystemAccount.cessPayable),
      );
      expect(
        [for (final l in cess) (l.memo, l.credit.paise)],
        [('RDF', 41904), ('Market', 10476)],
      );
    });

    test(
      'every combination of payers balances and keeps the khata amounts',
      () {
        const payers = ['farmer', 'buyer', 'arhtiya'];
        final charges = MandiCharge.values.map((c) => c.key).toList();
        var checked = 0;
        for (final commission in payers) {
          for (final palledari in payers) {
            for (final mandi in payers) {
              for (final cess in payers) {
                final c = config([
                  tenant('mandi.cess', [
                    {'name': 'RDF', 'pct': '2'},
                  ]),
                  tenant('mandi.charges_borne_by', {
                    charges[0]: commission,
                    'palledari': palledari,
                    'mandi_fee': mandi,
                    'cess': cess,
                  }),
                ]);
                final p = plan(c);
                final e = PostingRules.lot(lotId: 'x', date: day, plan: p);
                final debit = e.lines.fold(0, (s, l) => s + l.debit.paise);
                final credit = e.lines.fold(0, (s, l) => s + l.credit.paise);
                expect(debit, credit);
                // The party sides equal the khata entries of the lot.
                expect(
                  net(e, const PartyAccount('farmer')),
                  -p.farmer.amount.paise,
                );
                expect(
                  net(e, const PartyAccount('buyer')),
                  p.buyer!.amount.paise,
                );
                checked++;
              }
            }
          }
        }
        expect(checked, 81);
      },
    );
  });

  group('payments, loans, interest, waiver, manual and opening entries', () {
    test('payment out: Dr party, Cr cash', () {
      final e = PostingRules.payment(
        paymentId: 'p1',
        date: day,
        direction: PaymentDirection.toParty,
        partyId: 'f',
        bankAccountId: 'cash',
        amount: const Money.rupees(5000),
      );
      expect(shape(e), [('party:f', 500000, 0), ('book:cash', 0, 500000)]);
    });

    test('receipt: Dr bank, Cr party (also a cash loan repayment)', () {
      final e = PostingRules.payment(
        paymentId: 'p2',
        date: day,
        direction: PaymentDirection.fromParty,
        partyId: 'f',
        bankAccountId: 'sbi',
        amount: const Money.rupees(1200),
      );
      expect(shape(e), [('book:sbi', 120000, 0), ('party:f', 0, 120000)]);
    });

    test('interest: Dr party, Cr Interest Income; waiver the other way', () {
      final i = PostingRules.interest(
        postingId: 'ip',
        date: day,
        partyId: 'f',
        amount: const Money(493151),
      );
      expect(shape(i), [
        ('party:f', 493151, 0),
        ('system:interest_income', 0, 493151),
      ]);
      final w = PostingRules.waiver(
        postingId: 'wp',
        date: day,
        partyId: 'f',
        amount: const Money(93151),
      );
      expect(shape(w), [
        ('system:interest_waived', 93151, 0),
        ('party:f', 0, 93151),
      ]);
      expect(w.sourceKey, 'waiver:wp');
    });

    test('manual khata entry uses Khata Adjustments, opening balance uses '
        'Opening Balance Equity, on either side', () {
      for (final side in Side.values) {
        final m = PostingRules.manualEntry(
          entryId: 'e',
          date: day,
          side: side,
          partyId: 'f',
          amount: const Money(100),
        );
        final o = PostingRules.openingBalance(
          entryId: 'e',
          date: day,
          side: side,
          partyId: 'f',
          amount: const Money(100),
        );
        // Party account debit means udhaar.
        final sign = side == Side.udhaar ? 1 : -1;
        expect(net(m, const PartyAccount('f')), sign * 100);
        expect(net(o, const PartyAccount('f')), sign * 100);
        expect(net(m, sys(SystemAccount.khataAdjustments)), -sign * 100);
        expect(net(o, sys(SystemAccount.openingBalanceEquity)), -sign * 100);
      }
    });

    test('a party account is debited exactly when the khata is udhaar', () {
      // Principle 5: party account Dr − Cr = −(jama − udhaar).
      final disbursal = PostingRules.payment(
        paymentId: 'l',
        date: day,
        direction: PaymentDirection.toParty,
        partyId: 'f',
        bankAccountId: 'sbi',
        amount: const Money.rupees(50000),
      );
      expect(net(disbursal, const PartyAccount('f')), 5000000);
    });
  });
}
