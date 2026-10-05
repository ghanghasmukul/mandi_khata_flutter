import 'package:khata_core/src/interest/interest_config.dart';
import 'package:khata_core/src/interest/interest_engine.dart' as engine;
import 'package:khata_core/src/interest/interest_result.dart';
import 'package:khata_core/src/interest/ledger_event.dart';
import 'package:khata_core/src/ledger.dart';

/// What interest does on one party's khata.
enum KhataInterestMode {
  /// `net_udhaar`: the engine runs over the whole khata (loans excluded).
  khata,

  /// `loans_only`: interest runs on individual loans; the khata runs none.
  loansOnly,

  /// Interest is off for this party (`none` or `interest.enabled = false`).
  off,
}

/// Khata-level interest (docs/domain/interest-engine.md): feeds a party's
/// whole khata to the engine when `interest.apply_on = net_udhaar`.
abstract final class KhataInterest {
  /// The engine's events for [entries]: reversals and the entries they
  /// reverse are left out (they net to nothing); posted interest is kept but
  /// flagged, so the engine ignores it (rule 8). Loan entries are left out:
  /// a loan is its own interest account (docs/domain/interest-engine.md).
  ///
  /// [waiverIds] are the posting ids of the khata's waivers
  /// (`interest_postings`, kind waiver): the journal entries pointing at them
  /// are interest-only credits. [loanWaiverIds] are those of loans: their
  /// journal entries belong to the loan and are left out here.
  static List<LedgerEvent> events(
    Iterable<LedgerEntry> entries, {
    Set<String> waiverIds = const {},
    Set<String> loanWaiverIds = const {},
  }) {
    final reversed = {for (final e in entries) ?e.reversesId};
    bool isLoanEntry(LedgerEntry e) =>
        e.refType == RefType.loanDisbursal ||
        e.refType == RefType.loanRepayment ||
        (e.refId != null && loanWaiverIds.contains(e.refId));
    return [
      for (final e in entries)
        if (!e.isReversal && !reversed.contains(e.id) && !isLoanEntry(e))
          LedgerEvent(
            id: e.id,
            date: e.entryDate,
            side: e.side,
            amountPaise: e.amount.paise,
            createdAt: e.createdAt,
            note: e.narration,
            isPostedInterest: e.refType == RefType.interest,
            interestOnly: e.refId != null && waiverIds.contains(e.refId),
          ),
    ];
  }

  static KhataInterestMode mode(InterestConfig config) {
    if (!config.applicable) return KhataInterestMode.off;
    return config.applyOn == ApplyOn.loansOnly
        ? KhataInterestMode.loansOnly
        : KhataInterestMode.khata;
  }

  /// The party's khata interest on [asOf]. In [KhataInterestMode.loansOnly]
  /// no khata engine runs, so the result is empty.
  static InterestResult calculate({
    required Iterable<LedgerEntry> entries,
    required InterestConfig config,
    required LedgerDate asOf,
    Set<String> waiverIds = const {},
    Set<String> loanWaiverIds = const {},
  }) {
    if (mode(config) == KhataInterestMode.loansOnly) {
      return InterestResult.empty;
    }
    return engine.calculate(
      events: events(
        entries,
        waiverIds: waiverIds,
        loanWaiverIds: loanWaiverIds,
      ),
      config: config,
      asOf: asOf,
    );
  }
}
