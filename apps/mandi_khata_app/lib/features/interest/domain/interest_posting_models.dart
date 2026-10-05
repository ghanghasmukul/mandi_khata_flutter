import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// One row of `interest_postings` as the screens need it.
@immutable
class PostingRow {
  const PostingRow({
    required this.id,
    required this.partyId,
    required this.isWaiver,
    required this.from,
    required this.to,
    required this.amount,
    required this.createdAt,
    this.loanId,
    this.ratePa,
    this.reason,
    this.reversed = false,
  });

  factory PostingRow.fromRow(Map<String, Object?> r, {bool reversed = false}) =>
      PostingRow(
        id: r['id']! as String,
        partyId: r['party_id']! as String,
        loanId: r['loan_id'] as String?,
        isWaiver: r['kind'] == 'waiver',
        from: LedgerDate.parse(r['period_from']! as String),
        to: LedgerDate.parse(r['period_to']! as String),
        amount: Money(r['amount_paise']! as int),
        ratePa: r['rate_pa'] as String?,
        reason: r['reason'] as String?,
        createdAt: DateTime.parse(r['created_at']! as String),
        reversed: reversed,
      );

  final String id;
  final String partyId;

  /// Null: the party's whole khata.
  final String? loanId;
  final bool isWaiver;
  final LedgerDate from;
  final LedgerDate to;
  final Money amount;
  final String? ratePa;
  final String? reason;
  final DateTime createdAt;

  /// The khata entry behind it was reversed, so it no longer counts.
  final bool reversed;
}

/// What has been posted on one account (a party's khata or one loan).
@immutable
class PostedSummary {
  const PostedSummary({
    required this.postedPaise,
    required this.lastPostedTo,
    required this.waiverIds,
  });

  /// Summary of [rows] for the khata ([loanId] null) or for one loan.
  factory PostedSummary.of(Iterable<PostingRow> rows, {String? loanId}) {
    var posted = 0;
    LedgerDate? last;
    final waivers = <String>{};
    for (final r in rows) {
      if (r.loanId != loanId || r.reversed) continue;
      if (r.isWaiver) {
        waivers.add(r.id);
        continue;
      }
      posted += r.amount.paise;
      if (last == null || r.to > last) last = r.to;
    }
    return PostedSummary(
      postedPaise: posted,
      lastPostedTo: last,
      waiverIds: waivers,
    );
  }

  /// Interest posted and not reversed.
  final int postedPaise;

  /// The day the latest such posting ran to.
  final LedgerDate? lastPostedTo;

  /// Ids of the account's waiver postings (not reversed).
  final Set<String> waiverIds;
}

/// One account with interest that can be posted as of a day.
@immutable
class PostingCandidate {
  const PostingCandidate({
    required this.partyName,
    required this.partyCode,
    required this.plan,
    required this.principal,
    this.loanNo,
    this.alreadyPosted = false,
  });

  final String partyName;
  final String partyCode;
  final InterestPostingPlan plan;

  /// Outstanding principal on the day.
  final Money principal;

  /// Set for a loan.
  final String? loanNo;

  /// A posting with the same period key already exists (not reversed): this
  /// account was posted up to that day. It is not posted again.
  final bool alreadyPosted;

  String get partyId => plan.partyId;
  String? get loanId => plan.loanId;
  Money get amount => plan.amount;

  SettlementSource get source => SettlementSource(
    scope: plan.scope,
    loanId: plan.loanId,
    unpostedPaise: plan.amountPaise,
  );
}

/// Why one posting was left out of a run.
enum PostingSkip {
  /// The same account was already posted up to this day or later.
  alreadyPosted,

  /// The party or loan is gone or no longer matches.
  notFound,

  /// The date is outside the back-date window and needs `entries.reverse`.
  backdated,
}

@immutable
class SkippedPosting {
  const SkippedPosting(this.plan, this.reason);

  final InterestPostingPlan plan;
  final PostingSkip reason;
}

sealed class PostingResult {
  const PostingResult();
}

/// A posting run finished. [skipped] were left out, the rest was posted.
final class InterestPosted extends PostingResult {
  const InterestPosted({required this.posted, required this.skipped});

  final List<InterestPostingPlan> posted;
  final List<SkippedPosting> skipped;

  Money get total => Money(posted.fold(0, (sum, p) => sum + p.amountPaise));
}

final class PostingNotPermitted extends PostingResult {
  const PostingNotPermitted(this.permission, {this.backdateDays});

  final Permission permission;
  final int? backdateDays;
}

/// A settlement was rolled back because an account could not be posted.
final class PostingRefused extends PostingResult {
  const PostingRefused(this.reason);

  final PostingSkip reason;
}

/// A day after today cannot be posted.
final class PostingInFuture extends PostingResult {
  const PostingInFuture();
}

/// "Hisaab karo" posted the interest and the waiver.
final class SettlementDone extends PostingResult {
  const SettlementDone({required this.interest, required this.waived});

  final Money interest;
  final Money waived;
}

final class SettlementInvalid extends PostingResult {
  const SettlementInvalid(this.problems);

  final List<SettlementProblem> problems;
}
