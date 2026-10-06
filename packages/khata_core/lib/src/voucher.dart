import 'package:khata_core/src/document_number.dart';
import 'package:khata_core/src/journal.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:meta/meta.dart';

/// Tally-style voucher types (docs/domain/posting-rules.md, section 11.2).
enum VoucherType {
  contra('contra', DocumentSeries.contraVoucher),
  payment('payment', DocumentSeries.paymentVoucher),
  receipt('receipt', DocumentSeries.receiptVoucher),
  sales('sales', DocumentSeries.salesVoucher),
  purchase('purchase', DocumentSeries.purchaseVoucher),
  journal('journal', DocumentSeries.journalVoucher);

  const VoucherType(this.dbName, this.series);

  final String dbName;
  final DocumentSeries series;

  static VoucherType parse(String value) => values.firstWhere(
    (t) => t.dbName == value,
    orElse: () => throw FormatException('Unknown voucher type', value),
  );
}

/// What kind of account a voucher line is on; decides the voucher rules and
/// what else the line writes (a khata entry, a book line).
enum VoucherAccountKind {
  /// A party's account: the line also posts to the party's khata.
  party,

  /// The Cash account: the line also writes a cash book line.
  cash,

  /// A bank account: the line also writes a bank book line.
  bank,

  /// An account in Sales Accounts.
  sales,

  /// An account in Purchase Accounts.
  purchase,

  /// Anything else (income, expense, capital, duties…).
  other;

  bool get isBook => this == cash || this == bank;
}

/// Debit or credit.
enum DrCr {
  dr,
  cr;

  DrCr get opposite => this == dr ? cr : dr;
}

/// One line the person typed: an account, Dr or Cr, an amount.
@immutable
final class VoucherLineInput {
  const VoucherLineInput({
    required this.account,
    required this.kind,
    required this.side,
    required this.amount,
    this.isActive = true,
  });

  final JournalAccount account;
  final VoucherAccountKind kind;
  final DrCr side;
  final Money amount;

  /// A switched-off account cannot take new lines.
  final bool isActive;

  /// The party's khata side for a party line: Dr = udhaar, Cr = jama.
  Side get khataSide => side == DrCr.dr ? Side.udhaar : Side.jama;

  /// Whether a book line is money in (Dr) or out (Cr).
  bool get isMoneyIn => side == DrCr.dr;
}

/// Why a voucher cannot be saved.
enum VoucherProblem {
  /// Fewer than two lines with an account and an amount.
  tooFewLines,

  /// A line has no amount above zero.
  amountNotPositive,

  /// Σ Dr ≠ Σ Cr.
  unbalanced,

  /// The same account twice on the same side.
  duplicateAccount,

  /// An account that is switched off.
  inactiveAccount,

  /// Contra: a line that is not cash / bank, or no Dr or no Cr.
  contraNeedsBooksOnly,

  /// Payment: no cash / bank credited, or a cash / bank debited.
  paymentNeedsBookCredit,

  /// Receipt: no cash / bank debited, or a cash / bank credited.
  receiptNeedsBookDebit,

  /// Sales: no Sales Accounts account credited.
  salesNeedsSalesCredit,

  /// Purchase: no Purchase Accounts account debited.
  purchaseNeedsPurchaseDebit,

  /// Journal: a cash / bank line (use a payment, receipt or contra).
  journalNoBooks,
}

/// What a new voucher of each type suggests (posting-rules 11.2): the
/// first line is a Dr and the second a Cr; the account search lists these
/// kinds first.
abstract final class VoucherDefaults {
  /// Which kinds of account the second line is expected to be, for the
  /// account search to list first (cash / bank on a payment's credit side).
  static Set<VoucherAccountKind> suggestedKinds(VoucherType type, DrCr side) =>
      switch ((type, side)) {
        (VoucherType.contra, _) => const {
          VoucherAccountKind.cash,
          VoucherAccountKind.bank,
        },
        (VoucherType.payment, DrCr.cr) || (VoucherType.receipt, DrCr.dr) =>
          const {VoucherAccountKind.cash, VoucherAccountKind.bank},
        (VoucherType.sales, DrCr.cr) => const {VoucherAccountKind.sales},
        (VoucherType.purchase, DrCr.dr) => const {VoucherAccountKind.purchase},
        _ => const {},
      };
}

/// The rules of a voucher and the journal entry it makes.
abstract final class VoucherRules {
  /// Σ Dr − Σ Cr of [lines] (zero when balanced); what the screen shows as
  /// the running difference.
  static Money difference(Iterable<VoucherLineInput> lines) => lines.fold(
    Money.zero,
    (s, l) => l.side == DrCr.dr ? s + l.amount : s - l.amount,
  );

  /// Every rule [lines] break for a voucher of [type]; empty = can be saved.
  /// [allowBooksInJournal] is for journal vouchers the app generates (the
  /// cash count difference), never for one the person types.
  static List<VoucherProblem> validate(
    VoucherType type,
    List<VoucherLineInput> lines, {
    bool allowBooksInJournal = false,
  }) {
    final problems = <VoucherProblem>[];
    void add(VoucherProblem p) {
      if (!problems.contains(p)) problems.add(p);
    }

    if (lines.length < 2) add(VoucherProblem.tooFewLines);
    if (lines.any((l) => !l.amount.isPositive)) {
      add(VoucherProblem.amountNotPositive);
    }
    if (!difference(lines).isZero) add(VoucherProblem.unbalanced);
    final seen = <(JournalAccount, DrCr)>{};
    for (final l in lines) {
      if (!seen.add((l.account, l.side))) add(VoucherProblem.duplicateAccount);
      if (!l.isActive) add(VoucherProblem.inactiveAccount);
    }

    bool any(DrCr side, bool Function(VoucherAccountKind) test) =>
        lines.any((l) => l.side == side && test(l.kind));
    bool isBook(VoucherAccountKind k) => k.isBook;

    switch (type) {
      case VoucherType.contra:
        if (lines.any((l) => !l.kind.isBook) ||
            !any(DrCr.dr, isBook) ||
            !any(DrCr.cr, isBook)) {
          add(VoucherProblem.contraNeedsBooksOnly);
        }
      case VoucherType.payment:
        if (!any(DrCr.cr, isBook) || any(DrCr.dr, isBook)) {
          add(VoucherProblem.paymentNeedsBookCredit);
        }
      case VoucherType.receipt:
        if (!any(DrCr.dr, isBook) || any(DrCr.cr, isBook)) {
          add(VoucherProblem.receiptNeedsBookDebit);
        }
      case VoucherType.sales:
        if (!any(DrCr.cr, (k) => k == VoucherAccountKind.sales)) {
          add(VoucherProblem.salesNeedsSalesCredit);
        }
      case VoucherType.purchase:
        if (!any(DrCr.dr, (k) => k == VoucherAccountKind.purchase)) {
          add(VoucherProblem.purchaseNeedsPurchaseDebit);
        }
      case VoucherType.journal:
        if (!allowBooksInJournal && lines.any((l) => l.kind.isBook)) {
          add(VoucherProblem.journalNoBooks);
        }
    }
    return problems;
  }

  /// The journal entry of voucher [voucherId]. Throws [JournalError] when
  /// [lines] do not balance; call [validate] first.
  static JournalEntryDraft journal({
    required String voucherId,
    required LedgerDate date,
    required List<VoucherLineInput> lines,
    String? narration,
  }) {
    final b = JournalBuilder();
    for (final l in lines) {
      if (l.side == DrCr.dr) {
        b.debit(l.account, l.amount);
      } else {
        b.credit(l.account, l.amount);
      }
    }
    return b.build(
      sourceKey: 'voucher:$voucherId',
      date: date,
      narration: narration,
    );
  }

  /// The difference a cash count found, posted as a journal voucher:
  /// excess (counted more than the book) = Dr Cash / Cr Cash Short / Excess;
  /// short = the other way round. Null when nothing differs.
  static List<VoucherLineInput>? cashDifference({
    required String cashBankAccountId,
    required Money counted,
    required Money book,
  }) {
    final diff = counted - book;
    if (diff.isZero) return null;
    final cash = BookAccount(cashBankAccountId);
    const shortExcess = SystemJournalAccount(SystemAccount.cashShortExcess);
    final excess = diff.isPositive;
    return [
      VoucherLineInput(
        account: excess ? cash : shortExcess,
        kind: excess ? VoucherAccountKind.cash : VoucherAccountKind.other,
        side: DrCr.dr,
        amount: diff.abs(),
      ),
      VoucherLineInput(
        account: excess ? shortExcess : cash,
        kind: excess ? VoucherAccountKind.other : VoucherAccountKind.cash,
        side: DrCr.cr,
        amount: diff.abs(),
      ),
    ];
  }
}
