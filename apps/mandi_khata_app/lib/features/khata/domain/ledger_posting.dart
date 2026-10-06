import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';

/// A new entry to post to a party's khata. The id, device, user and time
/// are added when it is posted.
@immutable
class LedgerDraft {
  const LedgerDraft({
    required this.partyId,
    required this.side,
    required this.amount,
    required this.refType,
    this.entryDate,
    this.refId,
    this.narration,
  });

  final String partyId;
  final Side side;
  final Money amount;
  final RefType refType;

  /// Business date; today when null.
  final LedgerDate? entryDate;
  final String? refId;
  final String? narration;
}

sealed class LedgerPostResult {
  const LedgerPostResult();
}

/// Posted. [entries] are what was written, in order (one entry, or a
/// reversal, or a reversal and its replacement).
final class LedgerPosted extends LedgerPostResult {
  const LedgerPosted(this.entries);

  final List<LedgerEntry> entries;
}

final class LedgerNotPermitted extends LedgerPostResult {
  const LedgerNotPermitted(
    this.permission, {
    this.backdateDays,
    this.lockedYear = false,
  });

  final Permission permission;

  /// Set when the entry's date is outside the back-date window
  /// (`business.backdate_days`); the window in days.
  final int? backdateDays;

  /// The date is in a closed financial year (only the owner, with a
  /// reason, may write there).
  final bool lockedYear;
}

/// The party or entry does not exist in this business (or is deleted).
final class LedgerNotFound extends LedgerPostResult {
  const LedgerNotFound();
}

enum LedgerProblem {
  /// Amount zero or negative.
  amountNotPositive,

  /// Reversals are posted with `reverse`, never as a plain entry.
  useReverse,

  /// A reversal cannot be reversed or corrected; post a new entry.
  isReversal,

  /// This entry was already reversed.
  alreadyReversed,

  /// A correction must change something.
  nothingChanged,
}

final class LedgerInvalid extends LedgerPostResult {
  const LedgerInvalid(this.problem);

  final LedgerProblem problem;
}
