import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  group('PaymentDirection', () {
    test('paying a party is udhaar on the khata and money out of the book', () {
      expect(PaymentDirection.toParty.side, Side.udhaar);
      expect(PaymentDirection.toParty.refType, RefType.payment);
      expect(PaymentDirection.toParty.book, BookDirection.moneyOut);
    });

    test('a receipt is jama on the khata and money into the book', () {
      expect(PaymentDirection.fromParty.side, Side.jama);
      expect(PaymentDirection.fromParty.refType, RefType.receipt);
      expect(PaymentDirection.fromParty.book, BookDirection.moneyIn);
    });

    test('names round-trip', () {
      for (final d in PaymentDirection.values) {
        expect(PaymentDirection.parse(d.dbName), d);
      }
      for (final d in BookDirection.values) {
        expect(BookDirection.parse(d.dbName), d);
        expect(d.opposite.opposite, d);
      }
      for (final m in PaymentMode.values) {
        expect(PaymentMode.parse(m.name), m);
      }
      for (final s in ChequeStatus.values) {
        expect(ChequeStatus.parse(s.name), s);
      }
      expect(() => PaymentMode.parse('card'), throwsFormatException);
      expect(() => PaymentDirection.parse('x'), throwsFormatException);
      expect(() => BookDirection.parse('x'), throwsFormatException);
      expect(() => ChequeStatus.parse('x'), throwsFormatException);
    });
  });

  group('ChequeStatus.canMoveTo', () {
    test('pending clears or bounces, then it is final', () {
      expect(ChequeStatus.pending.canMoveTo(ChequeStatus.cleared), isTrue);
      expect(ChequeStatus.pending.canMoveTo(ChequeStatus.bounced), isTrue);
      expect(ChequeStatus.pending.canMoveTo(ChequeStatus.pending), isFalse);
      expect(ChequeStatus.cleared.canMoveTo(ChequeStatus.bounced), isFalse);
      expect(ChequeStatus.bounced.canMoveTo(ChequeStatus.cleared), isFalse);
    });
  });

  group('PaymentRules.validate', () {
    List<PaymentProblem> v({
      Money amount = const Money.rupees(500),
      PaymentMode mode = PaymentMode.cash,
      String? chequeNo,
      LedgerDate? chequeDate,
      bool bank = false,
    }) => PaymentRules.validate(
      amount: amount,
      mode: mode,
      chequeNo: chequeNo,
      chequeDate: chequeDate,
      hasBankAccount: bank,
    );

    test('cash needs only a positive amount', () {
      expect(v(), isEmpty);
      expect(v(amount: Money.zero), [PaymentProblem.amountNotPositive]);
      expect(v(amount: const Money(-1)), [PaymentProblem.amountNotPositive]);
    });

    test('bank and UPI need a bank account', () {
      expect(v(mode: PaymentMode.bank), [PaymentProblem.bankAccountMissing]);
      expect(v(mode: PaymentMode.upi), [PaymentProblem.bankAccountMissing]);
      expect(v(mode: PaymentMode.bank, bank: true), isEmpty);
      expect(v(mode: PaymentMode.upi, bank: true), isEmpty);
    });

    test('a cheque needs account, number and date', () {
      expect(v(mode: PaymentMode.cheque), [
        PaymentProblem.bankAccountMissing,
        PaymentProblem.chequeNoMissing,
        PaymentProblem.chequeDateMissing,
      ]);
      expect(
        v(mode: PaymentMode.cheque, bank: true, chequeNo: '  '),
        contains(PaymentProblem.chequeNoMissing),
      );
      expect(
        v(
          mode: PaymentMode.cheque,
          bank: true,
          chequeNo: '004512',
          chequeDate: LedgerDate(2026, 10, 3),
        ),
        isEmpty,
      );
    });

    test('cheque details on another mode are refused', () {
      expect(v(chequeNo: '12'), [PaymentProblem.chequeDetailsNotAllowed]);
    });
  });

  group('PaymentRules balances', () {
    test('paying a farmer we owe ₹10,000 ₹4,000 leaves ₹6,000 jama', () {
      // Balance is Σ jama − Σ udhaar: positive = we owe.
      final after = PaymentRules.balanceAfter(
        const Money.rupees(10000),
        PaymentDirection.toParty,
        const Money.rupees(4000),
      );
      expect(after, const Money.rupees(6000));
    });

    test('paying more than we owe flips the khata to udhaar', () {
      final after = PaymentRules.balanceAfter(
        const Money.rupees(1000),
        PaymentDirection.toParty,
        const Money.rupees(1500),
      );
      expect(after, const Money.rupees(-500));
    });

    test('a buyer who owes ₹25,000 pays ₹25,000 and is settled', () {
      final after = PaymentRules.balanceAfter(
        const Money.rupees(-25000),
        PaymentDirection.fromParty,
        const Money.rupees(25000),
      );
      expect(after, Money.zero);
    });

    test('full baki is what is due in that direction', () {
      expect(
        PaymentRules.fullBaki(
          const Money.rupees(10000),
          PaymentDirection.toParty,
        ),
        const Money.rupees(10000),
      );
      expect(
        PaymentRules.fullBaki(
          const Money.rupees(-2500),
          PaymentDirection.fromParty,
        ),
        const Money.rupees(2500),
      );
      expect(
        PaymentRules.fullBaki(
          const Money.rupees(-2500),
          PaymentDirection.toParty,
        ),
        isNull,
      );
      expect(
        PaymentRules.fullBaki(Money.zero, PaymentDirection.fromParty),
        isNull,
      );
    });
  });

  group('PaymentRules permissions', () {
    const limit = Money.rupees(50000);

    test('limit 0 means no limit', () {
      expect(
        PaymentRules.exceedsLimit(
          PaymentDirection.toParty,
          const Money.rupees(9999999),
          Money.zero,
        ),
        isFalse,
      );
    });

    test('only payments above the limit are over it', () {
      expect(
        PaymentRules.exceedsLimit(PaymentDirection.toParty, limit, limit),
        isFalse,
      );
      expect(
        PaymentRules.exceedsLimit(
          PaymentDirection.toParty,
          const Money(5000001),
          limit,
        ),
        isTrue,
      );
    });

    test('receipts are never limited', () {
      expect(
        PaymentRules.exceedsLimit(
          PaymentDirection.fromParty,
          const Money.rupees(900000),
          limit,
        ),
        isFalse,
      );
    });

    test('required permissions', () {
      expect(
        PaymentRules.requiredPermissions(
          direction: PaymentDirection.toParty,
          mode: PaymentMode.cash,
          amount: const Money.rupees(100),
          limit: limit,
        ),
        [Permission.paymentsCreate],
      );
      expect(
        PaymentRules.requiredPermissions(
          direction: PaymentDirection.toParty,
          mode: PaymentMode.cheque,
          amount: const Money.rupees(60000),
          limit: limit,
        ),
        [
          Permission.paymentsCreate,
          Permission.financeView,
          Permission.entriesReverse,
        ],
      );
    });

    test('a bounce needs entries.reverse, clearing payments.create', () {
      expect(
        PaymentRules.cheque(ChequeStatus.bounced),
        Permission.entriesReverse,
      );
      expect(
        PaymentRules.cheque(ChequeStatus.cleared),
        Permission.paymentsCreate,
      );
    });
  });
}
