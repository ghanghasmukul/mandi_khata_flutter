import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

const farmer = PartyAccount('farmer');
const buyer = PartyAccount('buyer');
const cash = BookAccount('cash');
const sbi = BookAccount('sbi');
const rent = ChartAccount('rent');
const sales = SystemJournalAccount(SystemAccount.sales);
const purchase = SystemJournalAccount(SystemAccount.purchase);

VoucherLineInput dr(
  JournalAccount a,
  VoucherAccountKind k,
  int rupees, {
  bool active = true,
}) => VoucherLineInput(
  account: a,
  kind: k,
  side: DrCr.dr,
  amount: Money.rupees(rupees),
  isActive: active,
);

VoucherLineInput cr(JournalAccount a, VoucherAccountKind k, int rupees) =>
    VoucherLineInput(
      account: a,
      kind: k,
      side: DrCr.cr,
      amount: Money.rupees(rupees),
    );

const VoucherAccountKind p = VoucherAccountKind.party;
const VoucherAccountKind c = VoucherAccountKind.cash;
const VoucherAccountKind b = VoucherAccountKind.bank;
const VoucherAccountKind o = VoucherAccountKind.other;
const VoucherAccountKind s = VoucherAccountKind.sales;
const VoucherAccountKind pu = VoucherAccountKind.purchase;

void main() {
  group('VoucherType', () {
    test('db names and series', () {
      expect(VoucherType.parse('contra'), VoucherType.contra);
      expect(VoucherType.payment.series.code, 'PY');
      expect(
        VoucherType.journal.series.settingKey,
        'business.number_series.journal_voucher',
      );
      expect(() => VoucherType.parse('x'), throwsFormatException);
    });
  });

  group('difference', () {
    test('Dr minus Cr; zero when balanced', () {
      expect(
        VoucherRules.difference([dr(farmer, p, 500)]),
        const Money.rupees(500),
      );
      expect(
        VoucherRules.difference([dr(farmer, p, 500), cr(cash, c, 300)]),
        const Money.rupees(200),
      );
      expect(
        VoucherRules.difference([dr(farmer, p, 500), cr(cash, c, 600)]),
        const Money.rupees(-100),
      );
      expect(VoucherRules.difference([]), Money.zero);
    });
  });

  group('validate: every type', () {
    test('a balanced payment to a party passes', () {
      expect(
        VoucherRules.validate(VoucherType.payment, [
          dr(farmer, p, 5000),
          cr(cash, c, 5000),
        ]),
        isEmpty,
      );
    });

    test('payment may split over cash and bank and pay several accounts', () {
      expect(
        VoucherRules.validate(VoucherType.payment, [
          dr(farmer, p, 3000),
          dr(rent, o, 2000),
          cr(cash, c, 1000),
          cr(sbi, b, 4000),
        ]),
        isEmpty,
      );
    });

    test('payment needs a cash / bank credit and no cash / bank debit', () {
      expect(
        VoucherRules.validate(VoucherType.payment, [
          dr(farmer, p, 100),
          cr(rent, o, 100),
        ]),
        [VoucherProblem.paymentNeedsBookCredit],
      );
      expect(
        VoucherRules.validate(VoucherType.payment, [
          dr(sbi, b, 100),
          cr(cash, c, 100),
        ]),
        [VoucherProblem.paymentNeedsBookCredit],
      );
    });

    test('receipt needs a cash / bank debit and no cash / bank credit', () {
      expect(
        VoucherRules.validate(VoucherType.receipt, [
          dr(cash, c, 100),
          cr(buyer, p, 100),
        ]),
        isEmpty,
      );
      expect(
        VoucherRules.validate(VoucherType.receipt, [
          dr(farmer, p, 100),
          cr(buyer, p, 100),
        ]),
        [VoucherProblem.receiptNeedsBookDebit],
      );
      expect(
        VoucherRules.validate(VoucherType.receipt, [
          dr(cash, c, 100),
          cr(sbi, b, 100),
        ]),
        [VoucherProblem.receiptNeedsBookDebit],
      );
    });

    test('contra is cash / bank on both sides only', () {
      expect(
        VoucherRules.validate(VoucherType.contra, [
          dr(sbi, b, 10000),
          cr(cash, c, 10000),
        ]),
        isEmpty,
      );
      expect(
        VoucherRules.validate(VoucherType.contra, [
          dr(sbi, b, 100),
          cr(buyer, p, 100),
        ]),
        [VoucherProblem.contraNeedsBooksOnly],
      );
    });

    test('sales credits a Sales account; purchase debits a Purchase one', () {
      expect(
        VoucherRules.validate(VoucherType.sales, [
          dr(buyer, p, 900),
          cr(sales, s, 900),
        ]),
        isEmpty,
      );
      expect(
        VoucherRules.validate(VoucherType.sales, [
          dr(buyer, p, 900),
          cr(rent, o, 900),
        ]),
        [VoucherProblem.salesNeedsSalesCredit],
      );
      expect(
        VoucherRules.validate(VoucherType.purchase, [
          dr(purchase, pu, 900),
          cr(farmer, p, 900),
        ]),
        isEmpty,
      );
      expect(
        VoucherRules.validate(VoucherType.purchase, [
          dr(rent, o, 900),
          cr(farmer, p, 900),
        ]),
        [VoucherProblem.purchaseNeedsPurchaseDebit],
      );
    });

    test('a cash sale (Dr cash) is a valid sales voucher', () {
      expect(
        VoucherRules.validate(VoucherType.sales, [
          dr(cash, c, 900),
          cr(sales, s, 900),
        ]),
        isEmpty,
      );
    });

    test('journal refuses cash / bank unless the app generates it', () {
      expect(
        VoucherRules.validate(VoucherType.journal, [
          dr(farmer, p, 100),
          cr(buyer, p, 100),
        ]),
        isEmpty,
      );
      final withCash = [dr(cash, c, 100), cr(rent, o, 100)];
      expect(VoucherRules.validate(VoucherType.journal, withCash), [
        VoucherProblem.journalNoBooks,
      ]);
      expect(
        VoucherRules.validate(
          VoucherType.journal,
          withCash,
          allowBooksInJournal: true,
        ),
        isEmpty,
      );
    });
  });

  group('validate: common rules', () {
    test('two lines at least', () {
      expect(
        VoucherRules.validate(VoucherType.journal, [dr(farmer, p, 1)]),
        containsAll([VoucherProblem.tooFewLines, VoucherProblem.unbalanced]),
      );
    });

    test('unbalanced', () {
      expect(
        VoucherRules.validate(VoucherType.journal, [
          dr(farmer, p, 100),
          cr(buyer, p, 99),
        ]),
        [VoucherProblem.unbalanced],
      );
    });

    test('zero amount', () {
      expect(
        VoucherRules.validate(VoucherType.journal, [
          dr(farmer, p, 0),
          cr(buyer, p, 0),
        ]),
        [VoucherProblem.amountNotPositive],
      );
    });

    test('same account twice on one side; both sides is allowed', () {
      expect(
        VoucherRules.validate(VoucherType.journal, [
          dr(farmer, p, 50),
          dr(farmer, p, 50),
          cr(buyer, p, 100),
        ]),
        [VoucherProblem.duplicateAccount],
      );
      expect(
        VoucherRules.validate(VoucherType.journal, [
          dr(farmer, p, 100),
          cr(farmer, p, 40),
          cr(buyer, p, 60),
        ]),
        isEmpty,
      );
    });

    test('Dr X and Cr X of the same amount is junk', () {
      expect(
        VoucherRules.validate(VoucherType.contra, [
          dr(cash, c, 100),
          cr(cash, c, 100),
        ]),
        contains(VoucherProblem.duplicateAccount),
      );
    });

    test('switched-off account', () {
      expect(
        VoucherRules.validate(VoucherType.journal, [
          dr(rent, o, 100, active: false),
          cr(buyer, p, 100),
        ]),
        [VoucherProblem.inactiveAccount],
      );
    });
  });

  group('journal', () {
    test('one line per input, keyed by the voucher', () {
      final e = VoucherRules.journal(
        voucherId: 'v1',
        date: LedgerDate(2027, 4, 1),
        lines: [dr(farmer, p, 3000), dr(rent, o, 2000), cr(cash, c, 5000)],
        narration: 'PY-W1-0001',
      );
      expect(e.sourceKey, 'voucher:v1');
      expect(e.narration, 'PY-W1-0001');
      expect(e.total, const Money.rupees(5000));
      expect(
        [for (final l in e.lines) l.toString()],
        [
          'Dr party:farmer 300000',
          'Dr account:rent 200000',
          'Cr book:cash 500000',
        ],
      );
    });

    test('throws when unbalanced', () {
      expect(
        () => VoucherRules.journal(
          voucherId: 'v1',
          date: LedgerDate(2027, 4, 1),
          lines: [dr(farmer, p, 1), cr(cash, c, 2)],
        ),
        throwsA(isA<JournalError>()),
      );
    });
  });

  group('line helpers', () {
    test('khata side and money direction', () {
      expect(dr(farmer, p, 1).khataSide, Side.udhaar);
      expect(cr(farmer, p, 1).khataSide, Side.jama);
      expect(dr(cash, c, 1).isMoneyIn, isTrue);
      expect(cr(cash, c, 1).isMoneyIn, isFalse);
      expect(DrCr.dr.opposite, DrCr.cr);
      expect(DrCr.cr.opposite, DrCr.dr);
    });
  });

  group('suggested kinds', () {
    test('per type and side', () {
      expect(VoucherDefaults.suggestedKinds(VoucherType.payment, DrCr.cr), {
        c,
        b,
      });
      expect(
        VoucherDefaults.suggestedKinds(VoucherType.payment, DrCr.dr),
        isEmpty,
      );
      expect(VoucherDefaults.suggestedKinds(VoucherType.receipt, DrCr.dr), {
        c,
        b,
      });
      expect(VoucherDefaults.suggestedKinds(VoucherType.contra, DrCr.dr), {
        c,
        b,
      });
      expect(VoucherDefaults.suggestedKinds(VoucherType.sales, DrCr.cr), {s});
      expect(VoucherDefaults.suggestedKinds(VoucherType.purchase, DrCr.dr), {
        pu,
      });
      expect(
        VoucherDefaults.suggestedKinds(VoucherType.journal, DrCr.dr),
        isEmpty,
      );
    });
  });

  group('cash count difference', () {
    test('excess: Dr Cash, Cr Cash Short / Excess', () {
      final lines = VoucherRules.cashDifference(
        cashBankAccountId: 'cash',
        counted: const Money.rupees(10050),
        book: const Money.rupees(10000),
      )!;
      expect(lines.map((l) => (l.account.key, l.side, l.amount.paise)), [
        ('book:cash', DrCr.dr, 5000),
        ('system:cash_short_excess', DrCr.cr, 5000),
      ]);
      expect(
        VoucherRules.validate(
          VoucherType.journal,
          lines,
          allowBooksInJournal: true,
        ),
        isEmpty,
      );
    });

    test('short: Dr Cash Short / Excess, Cr Cash', () {
      final lines = VoucherRules.cashDifference(
        cashBankAccountId: 'cash',
        counted: const Money.rupees(9980),
        book: const Money.rupees(10000),
      )!;
      expect(lines.map((l) => (l.account.key, l.side, l.amount.paise)), [
        ('system:cash_short_excess', DrCr.dr, 2000),
        ('book:cash', DrCr.cr, 2000),
      ]);
    });

    test('nothing to post when equal', () {
      expect(
        VoucherRules.cashDifference(
          cashBankAccountId: 'cash',
          counted: const Money.rupees(5),
          book: const Money.rupees(5),
        ),
        isNull,
      );
    });
  });

  group('chart additions', () {
    test('groups and accounts by code; nesting', () {
      expect(
        AccountGroup.fromCode('sales_accounts'),
        AccountGroup.salesAccounts,
      );
      expect(AccountGroup.fromCode('nope'), isNull);
      expect(
        SystemAccount.fromCode('cash_short_excess'),
        SystemAccount.cashShortExcess,
      );
      expect(SystemAccount.fromCode('nope'), isNull);
      expect(
        AccountGroup.sundryDebtors.isWithin(AccountGroup.currentAssets),
        isTrue,
      );
      expect(
        AccountGroup.sundryDebtors.isWithin(AccountGroup.sundryDebtors),
        isTrue,
      );
      expect(
        AccountGroup.capital.isWithin(AccountGroup.currentAssets),
        isFalse,
      );
      expect(const ChartAccount('x').key, 'account:x');
    });

    test('voucher entries need entries.reverse', () {
      expect(
        LedgerPosting.requiredPermission(RefType.voucher),
        Permission.entriesReverse,
      );
      expect(RefType.parse('voucher'), RefType.voucher);
    });
  });
}
