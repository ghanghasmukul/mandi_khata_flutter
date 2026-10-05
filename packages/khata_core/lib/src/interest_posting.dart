import 'package:decimal/decimal.dart';
import 'package:khata_core/src/interest/interest_config.dart';
import 'package:khata_core/src/interest/interest_result.dart';
import 'package:khata_core/src/ledger.dart';
import 'package:khata_core/src/money.dart';
import 'package:meta/meta.dart';

/// Which account the interest is charged on.
enum PostingScope {
  /// The party's whole khata (`interest.apply_on = net_udhaar`).
  khata,

  /// One loan (`interest.apply_on = loans_only`).
  loan,
}

/// What interest posting would write: one udhaar entry
/// (`ref_type = interest`) plus its `interest_postings` row.
@immutable
class InterestPostingPlan {
  const InterestPostingPlan({
    required this.scope,
    required this.partyId,
    required this.from,
    required this.to,
    required this.ratePa,
    required this.method,
    required this.amountPaise,
    required this.periodKey,
    this.loanId,
  });

  final PostingScope scope;
  final String partyId;
  final String? loanId;

  /// First day of the period (the day the last posting ended, or the
  /// account's first entry) and the day it is posted up to (exclusive).
  final LedgerDate from;
  final LedgerDate to;

  /// The rate in force on [to] (% p.a.).
  final Decimal ratePa;
  final InterestMethod method;
  final int amountPaise;

  /// `interest:<khata|loan>:<party or loan id>:<to>`. Unique per business:
  /// posting the same account up to the same day twice is refused.
  final String periodKey;

  Money get amount => Money(amountPaise);

  /// The date of the khata entry: the last day interest ran (the period
  /// ends before [to]), so a posting up to 1 April is dated 31 March and
  /// falls in the financial year it belongs to.
  LedgerDate get entryDate => to.addDays(-1);

  /// What the posting row records, so an entry can be explained later.
  Map<String, Object?> get meta => {
    'from': from.toString(),
    'to': to.toString(),
    'rate_pa': ratePa.toString(),
    'method': method.name,
    'amount_paise': amountPaise,
  };
}

/// Posting interest to the khata (docs/domain/interest-engine.md, "Posting
/// interest to the khata"). The engine ignores posted interest (rule 8), so
/// what is still to post is the interest charged so far minus what was posted.
abstract final class InterestPosting {
  /// All interest the engine has charged up to its as-of day: still accrued,
  /// recovered, waived and capitalised by compounding. Posting or repaying it
  /// does not change this figure.
  static int charged(InterestResult result) =>
      result.accruedUnpaidPaise +
      result.interestRecoveredPaise +
      result.interestWaivedPaise +
      [
        for (final row in result.schedule)
          if (row.kind == InterestRowKind.compound) row.amountPaise,
      ].fold(0, (a, b) => a + b);

  /// Interest charged and not yet posted (never negative).
  static int unposted(InterestResult result, {required int postedPaise}) {
    final rest = charged(result) - postedPaise;
    return rest > 0 ? rest : 0;
  }

  /// Interest posted beyond what the engine charges (never negative): a
  /// repayment or entry was reversed after the interest was posted. The
  /// khata then shows too much udhaar until the extra entry is reversed.
  static int overPosted(InterestResult result, {required int postedPaise}) {
    final extra = postedPaise - charged(result);
    return extra > 0 ? extra : 0;
  }

  static String periodKey({
    required PostingScope scope,
    required String accountId,
    required LedgerDate asOf,
  }) => 'interest:${scope.name}:$accountId:$asOf';

  /// The posting for [result] up to [asOf], or null when there is nothing
  /// to post (or interest is off). [postedPaise] is the interest already
  /// posted on this account (entries not reversed), [lastPostedTo] the day
  /// the last posting ran to, [firstEventDate] where the account begins.
  /// A loan [scope] needs [loanId]; a khata scope must not have one.
  static InterestPostingPlan? plan({
    required PostingScope scope,
    required String partyId,
    required InterestResult result,
    required InterestConfig config,
    required LedgerDate firstEventDate,
    required LedgerDate asOf,
    required int postedPaise,
    String? loanId,
    LedgerDate? lastPostedTo,
  }) {
    if ((scope == PostingScope.loan) != (loanId != null)) {
      throw ArgumentError.value(
        loanId,
        'loanId',
        'a loan posting needs a loan id and a khata posting has none',
      );
    }
    if (!config.applicable) return null;
    final amount = unposted(result, postedPaise: postedPaise);
    if (amount <= 0) return null;
    return InterestPostingPlan(
      scope: scope,
      partyId: partyId,
      loanId: loanId,
      from: lastPostedTo ?? firstEventDate,
      to: asOf,
      ratePa: config.ratePa,
      method: config.method,
      amountPaise: amount,
      periodKey: periodKey(
        scope: scope,
        accountId: loanId ?? partyId,
        asOf: asOf,
      ),
    );
  }
}

/// One account that has interest to settle: the party's khata or one loan.
@immutable
class SettlementSource {
  const SettlementSource({
    required this.scope,
    required this.unpostedPaise,
    this.loanId,
  });

  static const khataKey = 'khata';

  final PostingScope scope;
  final String? loanId;

  /// Interest charged up to the settlement day and not yet posted.
  final int unpostedPaise;

  /// Key of this source in the waiver map: `khata` or `loan:<id>`.
  String get key => scope == PostingScope.khata ? khataKey : 'loan:$loanId';
}

enum SettlementDirection {
  /// The party owes us.
  receivable,

  /// We owe the party.
  payable,
  settled,
}

enum SettlementProblem {
  /// A waiver is negative.
  waiverNegative,

  /// A waiver is more than the interest charged on that account.
  waiverExceedsInterest,

  /// A waiver needs a reason.
  reasonRequired,

  /// A waiver names an account that has no interest to settle.
  unknownSource,
}

/// "Hisaab karo": what a party owes (or is owed) once the interest up to a
/// day is added and an optional waiver taken off.
@immutable
class Settlement {
  const Settlement._({
    required this.balance,
    required this.unposted,
    required this.waiver,
  });

  /// [waivers] maps [SettlementSource.key] to paise.
  factory Settlement.compute({
    required Money balance,
    required List<SettlementSource> sources,
    Map<String, int> waivers = const {},
  }) => Settlement._(
    balance: balance,
    unposted: Money(sources.fold(0, (sum, s) => sum + s.unpostedPaise)),
    waiver: Money(waivers.values.fold(0, (sum, v) => sum + v)),
  );

  /// The khata balance now (jama positive, udhaar negative), including
  /// interest already posted.
  final Money balance;

  /// Interest charged and not yet posted, over every source.
  final Money unposted;

  /// Interest the owner waives (a discount), never more than [unposted].
  final Money waiver;

  /// Interest still to be paid: [unposted] less [waiver].
  Money get interestDue => unposted - waiver;

  /// Signed settlement figure (jama positive): the balance with the
  /// interest due taken off.
  Money get finalBalance => balance - interestDue;

  SettlementDirection get direction => finalBalance.isZero
      ? SettlementDirection.settled
      : finalBalance.isNegative
      ? SettlementDirection.receivable
      : SettlementDirection.payable;

  static List<SettlementProblem> validate({
    required List<SettlementSource> sources,
    required Map<String, int> waivers,
    required String reason,
  }) {
    final byKey = {for (final s in sources) s.key: s};
    final problems = <SettlementProblem>{};
    var any = false;
    for (final MapEntry(:key, value: paise) in waivers.entries) {
      if (paise == 0) continue;
      final source = byKey[key];
      if (source == null) {
        problems.add(SettlementProblem.unknownSource);
      } else if (paise < 0) {
        problems.add(SettlementProblem.waiverNegative);
      } else if (paise > source.unpostedPaise) {
        problems.add(SettlementProblem.waiverExceedsInterest);
      } else {
        any = true;
      }
    }
    if (any && reason.trim().isEmpty) {
      problems.add(SettlementProblem.reasonRequired);
    }
    return problems.toList();
  }
}

/// When interest is due to be posted (`interest.post_frequency`). v1 posts
/// only when the owner asks (nothing runs by itself, and there is no server
/// cron): this suggests the day to post up to, which the bulk run proposes.
abstract final class PostingSchedule {
  /// The latest period boundary on or before [today], so the posting covers
  /// every day up to the end of the previous period. `on_demand` (and any
  /// unknown value) is [today].
  static LedgerDate suggestedAsOf(String frequency, LedgerDate today) =>
      switch (frequency) {
        'monthly' => LedgerDate(today.year, today.month, 1),
        'quarterly' => LedgerDate(
          today.year,
          const [1, 1, 1, 4, 4, 4, 7, 7, 7, 10, 10, 10][today.month - 1],
          1,
        ),
        'fy_close' => LedgerDate(
          today.month >= 4 ? today.year : today.year - 1,
          4,
          1,
        ),
        _ => today,
      };
}
