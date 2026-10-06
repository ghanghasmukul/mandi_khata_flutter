import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:khata_core/src/party_rules.dart';
import 'package:meta/meta.dart';

/// Whether an account group is an asset, a liability, income or an expense
/// (Capital is on the liability side).
enum AccountNature { asset, liability, income, expense }

/// Tally-like account groups (docs/domain/posting-rules.md, section 2). The
/// [code] is stable: it is part of the group's id and of the server seed.
enum AccountGroup {
  capital('capital', 'Capital Account', null, AccountNature.liability),
  currentAssets('current_assets', 'Current Assets', null, AccountNature.asset),
  sundryDebtors(
    'sundry_debtors',
    'Sundry Debtors',
    AccountGroup.currentAssets,
    AccountNature.asset,
  ),
  cashInHand(
    'cash_in_hand',
    'Cash-in-hand',
    AccountGroup.currentAssets,
    AccountNature.asset,
  ),
  bankAccounts(
    'bank_accounts',
    'Bank Accounts',
    AccountGroup.currentAssets,
    AccountNature.asset,
  ),
  stockInHand(
    'stock_in_hand',
    'Stock-in-hand',
    AccountGroup.currentAssets,
    AccountNature.asset,
  ),
  loansAndAdvances(
    'loans_and_advances',
    'Loans & Advances (Asset)',
    AccountGroup.currentAssets,
    AccountNature.asset,
  ),
  currentLiabilities(
    'current_liabilities',
    'Current Liabilities',
    null,
    AccountNature.liability,
  ),
  sundryCreditors(
    'sundry_creditors',
    'Sundry Creditors',
    AccountGroup.currentLiabilities,
    AccountNature.liability,
  ),
  dutiesAndTaxes(
    'duties_and_taxes',
    'Duties & Taxes',
    AccountGroup.currentLiabilities,
    AccountNature.liability,
  ),
  directIncome('direct_income', 'Direct Income', null, AccountNature.income),
  indirectIncome(
    'indirect_income',
    'Indirect Income',
    null,
    AccountNature.income,
  ),
  directExpenses(
    'direct_expenses',
    'Direct Expenses',
    null,
    AccountNature.expense,
  ),
  indirectExpenses(
    'indirect_expenses',
    'Indirect Expenses',
    null,
    AccountNature.expense,
  );

  const AccountGroup(this.code, this.name, this.parent, this.nature);

  final String code;
  final String name;
  final AccountGroup? parent;
  final AccountNature nature;

  /// The group a party's account is created in (posting-rules Q2): Sundry
  /// Debtors when the party is a customer or buyer (also when it is more),
  /// else Sundry Creditors. The balance sheet shows a debit balance as an
  /// asset whatever the group.
  static AccountGroup forPartyRoles(Set<PartyRole> roles) =>
      roles.contains(PartyRole.customer) || roles.contains(PartyRole.buyer)
      ? sundryDebtors
      : sundryCreditors;
}

/// Accounts every business has (`accounts.is_system`). The [code] is stable
/// and part of the account's id and of the server seed.
enum SystemAccount {
  commissionIncome(
    'commission_income',
    'Commission Income',
    AccountGroup.directIncome,
  ),
  palledariReceipts(
    'palledari_receipts',
    'Palledari Receipts',
    AccountGroup.directIncome,
  ),
  bardanaReceipts(
    'bardana_receipts',
    'Bardana Receipts',
    AccountGroup.directIncome,
  ),
  tulaiReceipts('tulai_receipts', 'Tulai Receipts', AccountGroup.directIncome),
  interestIncome(
    'interest_income',
    'Interest Income',
    AccountGroup.indirectIncome,
  ),
  mandiFeePayable(
    'mandi_fee_payable',
    'Mandi Fee Payable',
    AccountGroup.dutiesAndTaxes,
  ),
  cessPayable('cess_payable', 'Cess Payable', AccountGroup.dutiesAndTaxes),
  mandiFeeOwnCost(
    'mandi_fee_own_cost',
    'Mandi Fee (own cost)',
    AccountGroup.directExpenses,
  ),
  cessOwnCost('cess_own_cost', 'Cess (own cost)', AccountGroup.directExpenses),
  interestWaived(
    'interest_waived',
    'Interest Waived',
    AccountGroup.indirectExpenses,
  ),
  lotSaleClearing(
    'lot_sale_clearing',
    'Lot Sale Clearing',
    AccountGroup.currentAssets,
  ),
  khataAdjustments(
    'khata_adjustments',
    'Khata Adjustments',
    AccountGroup.currentLiabilities,
  ),
  openingBalanceEquity(
    'opening_balance_equity',
    'Opening Balance Equity',
    AccountGroup.capital,
  );

  const SystemAccount(this.code, this.name, this.group);

  final String code;
  final String name;
  final AccountGroup group;
}

/// Which account a journal line is on. The app turns it into the account's
/// deterministic id; this package never sees ids or a database.
@immutable
sealed class JournalAccount {
  const JournalAccount();

  /// A stable text key, equal for equal accounts.
  String get key;

  @override
  bool operator ==(Object other) => other is JournalAccount && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => key;
}

/// A party's account (mirrors the party's khata).
final class PartyAccount extends JournalAccount {
  const PartyAccount(this.partyId);

  final String partyId;

  @override
  String get key => 'party:$partyId';
}

/// The account of a cash / bank book (`bank_accounts`; Cash is one of them).
final class BookAccount extends JournalAccount {
  const BookAccount(this.bankAccountId);

  final String bankAccountId;

  @override
  String get key => 'book:$bankAccountId';
}

/// One of the [SystemAccount]s.
final class SystemJournalAccount extends JournalAccount {
  const SystemJournalAccount(this.account);

  final SystemAccount account;

  @override
  String get key => 'system:${account.code}';
}

/// One line of a journal entry: a debit or a credit, never both.
@immutable
final class JournalLine {
  const JournalLine._(this.account, this.debit, this.credit, this.memo);

  final JournalAccount account;
  final Money debit;
  final Money credit;

  /// Extra text, e.g. the name of a cess.
  final String? memo;

  bool get isDebit => debit.isPositive;

  Money get amount => isDebit ? debit : credit;

  JournalLine get mirrored => JournalLine._(account, credit, debit, memo);

  @override
  bool operator ==(Object other) =>
      other is JournalLine &&
      other.account == account &&
      other.debit == debit &&
      other.credit == credit &&
      other.memo == memo;

  @override
  int get hashCode => Object.hash(account, debit, credit, memo);

  @override
  String toString() =>
      '${isDebit ? 'Dr' : 'Cr'} $account ${amount.paise} ${memo ?? ''}'.trim();
}

/// A journal entry that has been checked: at least two lines, every line
/// positive, Σ debit = Σ credit.
@immutable
final class JournalEntryDraft {
  const JournalEntryDraft._({
    required this.sourceKey,
    required this.date,
    required this.lines,
    this.narration,
    this.reversesKey,
  });

  /// Names the document behind the entry, e.g. `lot:<id>`. Unique per
  /// business; the entry's id is derived from it.
  final String sourceKey;
  final LedgerDate date;
  final List<JournalLine> lines;
  final String? narration;

  /// The [sourceKey] of the entry this one reverses (a reversal's own key is
  /// `reversal:<that key>`).
  final String? reversesKey;

  bool get isReversal => reversesKey != null;

  Money get total => lines.fold(Money.zero, (a, l) => a + l.debit);

  /// The reversal of this entry: the same lines with debit and credit
  /// swapped, dated [on] (the date of the khata reversal).
  JournalEntryDraft reversal(LedgerDate on, {String? narration}) {
    if (isReversal) {
      throw StateError('A reversal is never reversed; post a new entry');
    }
    return JournalEntryDraft._(
      sourceKey: 'reversal:$sourceKey',
      date: on,
      lines: [for (final l in lines) l.mirrored],
      narration: narration ?? this.narration,
      reversesKey: sourceKey,
    );
  }
}

/// Thrown when a journal entry does not balance or is malformed.
class JournalError extends Error {
  JournalError(this.message);

  final String message;

  @override
  String toString() => 'JournalError: $message';
}

/// Builds a [JournalEntryDraft] and checks the one rule of double entry.
class JournalBuilder {
  final _lines = <JournalLine>[];

  void debit(JournalAccount account, Money amount, {String? memo}) =>
      _add(JournalLine._(account, amount, Money.zero, memo));

  void credit(JournalAccount account, Money amount, {String? memo}) =>
      _add(JournalLine._(account, Money.zero, amount, memo));

  void _add(JournalLine line) {
    if (!line.amount.isPositive) {
      throw JournalError('A journal line must be above zero: $line');
    }
    _lines.add(line);
  }

  /// Throws [JournalError] unless there are at least two lines and
  /// Σ debit = Σ credit.
  JournalEntryDraft build({
    required String sourceKey,
    required LedgerDate date,
    String? narration,
  }) {
    if (sourceKey.isEmpty) throw JournalError('A journal entry needs a source');
    if (_lines.length < 2) {
      throw JournalError('A journal entry needs at least two lines');
    }
    final debit = _lines.fold(Money.zero, (a, l) => a + l.debit);
    final credit = _lines.fold(Money.zero, (a, l) => a + l.credit);
    if (debit != credit) {
      throw JournalError(
        'Unbalanced: debit ${debit.paise} ≠ credit ${credit.paise} '
        'for $sourceKey',
      );
    }
    return JournalEntryDraft._(
      sourceKey: sourceKey,
      date: date,
      lines: List.unmodifiable(_lines),
      narration: narration,
    );
  }
}
