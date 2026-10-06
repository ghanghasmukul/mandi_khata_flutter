import 'package:khata_core/src/financial_year.dart';
import 'package:khata_core/src/journal.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:meta/meta.dart';

/// A group of the chart, as the statements need it.
@immutable
final class StatementGroup {
  const StatementGroup({
    required this.id,
    required this.name,
    required this.nature,
    this.code,
    this.parentId,
  });

  final String id;
  final String name;
  final AccountNature nature;

  /// The built-in group's code; null for a group the business added.
  final String? code;
  final String? parentId;
}

/// One account with its Σ debit and Σ credit over the dates asked for.
@immutable
final class StatementAccount {
  const StatementAccount({
    required this.id,
    required this.name,
    required this.groupId,
    required this.debit,
    required this.credit,
  });

  final String id;
  final String name;
  final String groupId;
  final Money debit;
  final Money credit;

  /// Debit − credit: positive = debit balance.
  Money get net => debit - credit;
}

/// The chart the statements walk: groups by id, the root of each group.
@immutable
final class StatementChart {
  StatementChart(Iterable<StatementGroup> groups)
    : groups = {for (final g in groups) g.id: g};

  final Map<String, StatementGroup> groups;

  /// The top-level group [groupId] is under (itself when top-level); null
  /// for an unknown group.
  StatementGroup? rootOf(String groupId) {
    var g = groups[groupId];
    final seen = <String>{};
    while (g != null && g.parentId != null && seen.add(g.id)) {
      final parent = groups[g.parentId];
      if (parent == null) break;
      g = parent;
    }
    return g;
  }

  AccountNature natureOf(String groupId) =>
      groups[groupId]?.nature ?? AccountNature.asset;

  /// Groups from the top down to [groupId].
  List<StatementGroup> pathOf(String groupId) {
    final out = <StatementGroup>[];
    var g = groups[groupId];
    final seen = <String>{};
    while (g != null && seen.add(g.id)) {
      out.insert(0, g);
      g = g.parentId == null ? null : groups[g.parentId];
    }
    return out;
  }
}

// ---------------------------------------------------------------------------
// Trial balance
// ---------------------------------------------------------------------------

/// One line of a trial balance: an account, or a group's total.
@immutable
final class TrialBalanceLine {
  const TrialBalanceLine({
    required this.id,
    required this.name,
    required this.depth,
    required this.isGroup,
    required this.debit,
    required this.credit,
  });

  final String id;
  final String name;

  /// 0 for a top-level group; accounts sit one below their group.
  final int depth;
  final bool isGroup;

  /// Closing debit balance (zero when the balance is a credit).
  final Money debit;

  /// Closing credit balance (zero when the balance is a debit).
  final Money credit;
}

/// Closing balances of every account (docs/domain/posting-rules.md, 11.5).
@immutable
final class TrialBalance {
  const TrialBalance({
    required this.lines,
    required this.debit,
    required this.credit,
  });

  /// Group headings with their totals, each followed by its sub-groups and
  /// (when [withAccounts]) its accounts; accounts with no balance are left
  /// out. Totals are Σ debit balances and Σ credit balances of accounts.
  factory TrialBalance.build(
    StatementChart chart,
    Iterable<StatementAccount> accounts, {
    bool withAccounts = true,
  }) {
    final byGroup = <String, List<StatementAccount>>{};
    for (final a in accounts) {
      if (a.net.isZero) continue;
      byGroup.putIfAbsent(a.groupId, () => []).add(a);
    }
    for (final list in byGroup.values) {
      list.sort((x, y) => x.name.compareTo(y.name));
    }
    Money netOf(String groupId) {
      var n = Money.zero;
      for (final a in byGroup[groupId] ?? const <StatementAccount>[]) {
        n += a.net;
      }
      for (final g in chart.groups.values) {
        if (g.parentId == groupId) n += netOf(g.id);
      }
      return n;
    }

    final lines = <TrialBalanceLine>[];
    void visit(StatementGroup g, int depth) {
      final net = netOf(g.id);
      final hasAny = _hasAccounts(chart, byGroup, g.id);
      if (!hasAny) return;
      lines.add(
        TrialBalanceLine(
          id: g.id,
          name: g.name,
          depth: depth,
          isGroup: true,
          debit: net.isPositive ? net : Money.zero,
          credit: net.isNegative ? -net : Money.zero,
        ),
      );
      final children =
          chart.groups.values.where((c) => c.parentId == g.id).toList()
            ..sort(_groupOrder);
      for (final c in children) {
        visit(c, depth + 1);
      }
      if (withAccounts) {
        for (final a in byGroup[g.id] ?? const <StatementAccount>[]) {
          lines.add(
            TrialBalanceLine(
              id: a.id,
              name: a.name,
              depth: depth + 1,
              isGroup: false,
              debit: a.net.isPositive ? a.net : Money.zero,
              credit: a.net.isNegative ? -a.net : Money.zero,
            ),
          );
        }
      }
    }

    final roots = chart.groups.values.where((g) => g.parentId == null).toList()
      ..sort(_groupOrder);
    for (final r in roots) {
      visit(r, 0);
    }
    // Accounts whose group is unknown (not synced yet) still count.
    final unknown = [
      for (final MapEntry(key: id, value: list) in byGroup.entries)
        if (!chart.groups.containsKey(id)) ...list,
    ];
    for (final a in unknown) {
      lines.add(
        TrialBalanceLine(
          id: a.id,
          name: a.name,
          depth: 0,
          isGroup: false,
          debit: a.net.isPositive ? a.net : Money.zero,
          credit: a.net.isNegative ? -a.net : Money.zero,
        ),
      );
    }

    var debit = Money.zero;
    var credit = Money.zero;
    for (final list in byGroup.values) {
      for (final a in list) {
        if (a.net.isPositive) {
          debit += a.net;
        } else {
          credit -= a.net;
        }
      }
    }
    return TrialBalance(lines: lines, debit: debit, credit: credit);
  }

  final List<TrialBalanceLine> lines;
  final Money debit;
  final Money credit;

  /// Σ debit balances = Σ credit balances.
  bool get isBalanced => debit == credit;

  static bool _hasAccounts(
    StatementChart chart,
    Map<String, List<StatementAccount>> byGroup,
    String groupId,
  ) {
    if ((byGroup[groupId] ?? const []).isNotEmpty) return true;
    return chart.groups.values.any(
      (c) => c.parentId == groupId && _hasAccounts(chart, byGroup, c.id),
    );
  }
}

int _groupOrder(StatementGroup a, StatementGroup b) {
  final ai = a.code == null ? null : AccountGroup.fromCode(a.code!)?.index;
  final bi = b.code == null ? null : AccountGroup.fromCode(b.code!)?.index;
  final x = ai ?? 1000;
  final y = bi ?? 1000;
  return x != y ? x.compareTo(y) : a.name.compareTo(b.name);
}

// ---------------------------------------------------------------------------
// Profit and loss
// ---------------------------------------------------------------------------

/// Where an income or expense account goes in a profit and loss.
enum ProfitSection {
  sales,
  directIncome,
  purchases,
  directExpenses,
  indirectIncome,
  indirectExpenses;

  bool get isIncome =>
      this == sales || this == directIncome || this == indirectIncome;
}

/// One account's amount in a section (income: credit − debit; expense:
/// debit − credit).
@immutable
final class ProfitLine {
  const ProfitLine(this.accountId, this.name, this.amount);

  final String accountId;
  final String name;
  final Money amount;
}

/// Profit and loss for a period (posting-rules 11.5).
@immutable
final class ProfitAndLoss {
  const ProfitAndLoss(this.sections);

  /// [accounts] carry the period's totals, without year-close entries.
  /// An income / expense group the business added goes to indirect income /
  /// expenses unless it sits under a built-in group.
  factory ProfitAndLoss.build(
    StatementChart chart,
    Iterable<StatementAccount> accounts,
  ) {
    final sections = {for (final s in ProfitSection.values) s: <ProfitLine>[]};
    for (final a in accounts) {
      final section = sectionOf(chart, a.groupId);
      if (section == null) continue;
      final amount = section.isIncome ? -a.net : a.net;
      if (amount.isZero) continue;
      sections[section]!.add(ProfitLine(a.id, a.name, amount));
    }
    for (final list in sections.values) {
      list.sort((x, y) => x.name.compareTo(y.name));
    }
    return ProfitAndLoss({
      for (final MapEntry(:key, :value) in sections.entries)
        key: List.unmodifiable(value),
    });
  }

  final Map<ProfitSection, List<ProfitLine>> sections;

  /// The section an account of [groupId] goes in; null for asset, liability
  /// and capital accounts.
  static ProfitSection? sectionOf(StatementChart chart, String groupId) {
    final nature = chart.natureOf(groupId);
    if (nature != AccountNature.income && nature != AccountNature.expense) {
      return null;
    }
    for (final g in chart.pathOf(groupId).reversed) {
      switch (g.code) {
        case 'sales_accounts':
          return ProfitSection.sales;
        case 'direct_income':
          return ProfitSection.directIncome;
        case 'indirect_income':
          return ProfitSection.indirectIncome;
        case 'purchase_accounts':
          return ProfitSection.purchases;
        case 'direct_expenses':
          return ProfitSection.directExpenses;
        case 'indirect_expenses':
          return ProfitSection.indirectExpenses;
      }
    }
    return nature == AccountNature.income
        ? ProfitSection.indirectIncome
        : ProfitSection.indirectExpenses;
  }

  Money total(ProfitSection s) =>
      sections[s]!.fold(Money.zero, (sum, l) => sum + l.amount);

  /// Sales + direct income − purchases − direct expenses.
  Money get grossProfit =>
      total(ProfitSection.sales) +
      total(ProfitSection.directIncome) -
      total(ProfitSection.purchases) -
      total(ProfitSection.directExpenses);

  /// Gross profit + indirect income − indirect expenses (negative = loss).
  Money get netProfit =>
      grossProfit +
      total(ProfitSection.indirectIncome) -
      total(ProfitSection.indirectExpenses);
}

// ---------------------------------------------------------------------------
// Balance sheet
// ---------------------------------------------------------------------------

/// A side of the balance sheet, by top-level group.
enum BalanceSide { assets, liabilities, capital }

/// One account on the balance sheet (always a positive amount on its side).
@immutable
final class BalanceLine {
  const BalanceLine({
    required this.accountId,
    required this.name,
    required this.groupId,
    required this.amount,
    this.otherSide = false,
  });

  final String accountId;
  final String name;

  /// The group the account sits in (for the heading).
  final String groupId;
  final Money amount;

  /// The balance is of the other nature than its group (a creditor with a
  /// debit balance shown among assets).
  final bool otherSide;
}

/// Balance sheet as of a date (posting-rules 11.5).
@immutable
final class BalanceSheet {
  const BalanceSheet({required this.sides, required this.currentProfit});

  /// [accounts] carry every journal line up to the date. Income and expense
  /// balances (profit not closed yet) appear in capital as one amount,
  /// [currentProfit], so assets = liabilities + capital.
  factory BalanceSheet.build(
    StatementChart chart,
    Iterable<StatementAccount> accounts,
  ) {
    final sides = {for (final s in BalanceSide.values) s: <BalanceLine>[]};
    var profit = Money.zero;
    for (final a in accounts) {
      if (a.net.isZero) continue;
      final nature = chart.natureOf(a.groupId);
      if (nature == AccountNature.income || nature == AccountNature.expense) {
        profit -= a.net;
        continue;
      }
      final root = chart.rootOf(a.groupId);
      if (root?.code == AccountGroup.capital.code) {
        sides[BalanceSide.capital]!.add(
          BalanceLine(
            accountId: a.id,
            name: a.name,
            groupId: a.groupId,
            amount: -a.net,
          ),
        );
        continue;
      }
      final isAssetGroup = nature == AccountNature.asset;
      final debitBalance = a.net.isPositive;
      final side = debitBalance ? BalanceSide.assets : BalanceSide.liabilities;
      sides[side]!.add(
        BalanceLine(
          accountId: a.id,
          name: a.name,
          groupId: a.groupId,
          amount: a.net.abs(),
          otherSide: debitBalance != isAssetGroup,
        ),
      );
    }
    for (final list in sides.values) {
      list.sort((x, y) => x.name.compareTo(y.name));
    }
    return BalanceSheet(
      sides: {
        for (final MapEntry(:key, :value) in sides.entries)
          key: List.unmodifiable(value),
      },
      currentProfit: profit,
    );
  }

  final Map<BalanceSide, List<BalanceLine>> sides;

  /// Profit (or loss, negative) not closed into capital yet.
  final Money currentProfit;

  Money total(BalanceSide s) =>
      sides[s]!.fold(Money.zero, (sum, l) => sum + l.amount);

  Money get assets => total(BalanceSide.assets);

  /// Liabilities + capital + profit not closed.
  Money get liabilitiesAndCapital =>
      total(BalanceSide.liabilities) +
      total(BalanceSide.capital) +
      currentProfit;

  bool get isBalanced => assets == liabilitiesAndCapital;
}

// ---------------------------------------------------------------------------
// Account ledger
// ---------------------------------------------------------------------------

/// One posting on an account.
@immutable
final class AccountPosting {
  const AccountPosting({
    required this.date,
    required this.debit,
    required this.credit,
    this.text,
    this.sourceKey,
    this.order = '',
  });

  final LedgerDate date;
  final Money debit;
  final Money credit;
  final String? text;
  final String? sourceKey;

  /// Tie-break inside a day (created_at).
  final String order;
}

/// A posting with the balance after it.
@immutable
final class AccountLedgerLine {
  const AccountLedgerLine(this.posting, this.balance);

  final AccountPosting posting;

  /// Debit − credit after this line.
  final Money balance;
}

/// The ledger of one account for a period: opening, postings, closing.
@immutable
final class AccountLedger {
  const AccountLedger({required this.opening, required this.lines});

  factory AccountLedger.build(
    Iterable<AccountPosting> postings, {
    LedgerDate? from,
    LedgerDate? to,
  }) {
    var opening = Money.zero;
    final inside = <AccountPosting>[];
    for (final p in postings) {
      if (from != null && p.date < from) {
        opening += p.debit - p.credit;
      } else if (to == null || p.date <= to) {
        inside.add(p);
      }
    }
    inside.sort((a, b) {
      final d = a.date.compareTo(b.date);
      return d != 0 ? d : a.order.compareTo(b.order);
    });
    var running = opening;
    final lines = <AccountLedgerLine>[];
    for (final p in inside) {
      running += p.debit - p.credit;
      lines.add(AccountLedgerLine(p, running));
    }
    return AccountLedger(opening: opening, lines: lines);
  }

  /// Debit − credit before the period.
  final Money opening;
  final List<AccountLedgerLine> lines;

  Money get debit => lines.fold(Money.zero, (s, l) => s + l.posting.debit);

  Money get credit => lines.fold(Money.zero, (s, l) => s + l.posting.credit);

  Money get closing => opening + debit - credit;
}

// ---------------------------------------------------------------------------
// Year close
// ---------------------------------------------------------------------------

/// Year-end closing (posting-rules 11.5, decision): no khata entries; one
/// journal entry dated 31 March moves every income / expense balance of the
/// year to Profit & Loss A/c and Opening Balance Equity to Capital.
abstract final class YearClose {
  /// The source key of the closing entry of [fy].
  static String sourceKey(FinancialYear fy) => 'year_close:${fy.startYear}';

  /// The closing entry, or null when nothing needs moving.
  ///
  /// [incomeExpense] are the year's totals of income and expense accounts
  /// (without year-close entries); [openingEquity] is Opening Balance
  /// Equity's net (debit − credit) up to the year's end.
  static JournalEntryDraft? closingEntry(
    FinancialYear fy, {
    required Map<JournalAccount, Money> incomeExpense,
    required Money openingEquity,
  }) {
    final b = JournalBuilder();
    var toProfit = Money.zero;
    var lines = 0;
    final keys = incomeExpense.keys.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final account in keys) {
      final net = incomeExpense[account]!;
      if (net.isZero) continue;
      // Zero the account: a debit balance is credited, and the other way.
      if (net.isPositive) {
        b.credit(account, net);
      } else {
        b.debit(account, -net);
      }
      toProfit += net;
      lines++;
    }
    const profitAccount = SystemJournalAccount(SystemAccount.profitAndLoss);
    if (toProfit.isPositive) {
      b.debit(profitAccount, toProfit);
    } else if (toProfit.isNegative) {
      b.credit(profitAccount, -toProfit);
    }
    if (!openingEquity.isZero) {
      const obe = SystemJournalAccount(SystemAccount.openingBalanceEquity);
      const capital = SystemJournalAccount(SystemAccount.capital);
      if (openingEquity.isPositive) {
        b
          ..credit(obe, openingEquity)
          ..debit(capital, openingEquity);
      } else {
        b
          ..debit(obe, -openingEquity)
          ..credit(capital, -openingEquity);
      }
      lines++;
    }
    if (lines == 0) return null;
    return b.build(sourceKey: sourceKey(fy), date: fy.end);
  }

  /// Whether [date] falls in one of the [closed] financial years.
  static bool isLocked(LedgerDate date, Iterable<FinancialYear> closed) =>
      closed.any((fy) => fy.contains(date));
}
