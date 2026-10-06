import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';

/// A line the person entered: an account of the chart, Dr / Cr, amount.
@immutable
class VoucherDraftLine {
  const VoucherDraftLine({
    required this.account,
    required this.side,
    required this.amount,
  });

  final ChartEntry account;
  final DrCr side;
  final Money amount;

  VoucherLineInput get input => VoucherLineInput(
    account: account.account,
    kind: account.kind,
    side: side,
    amount: amount,
    isActive: account.isActive,
  );
}

/// A voucher to post.
@immutable
class VoucherDraft {
  const VoucherDraft({
    required this.type,
    required this.date,
    required this.lines,
    this.narration,
  });

  final VoucherType type;
  final LedgerDate date;
  final List<VoucherDraftLine> lines;
  final String? narration;

  List<VoucherLineInput> get inputs => [for (final l in lines) l.input];
}

sealed class VoucherSaveResult {
  const VoucherSaveResult();
}

final class VoucherSaved extends VoucherSaveResult {
  const VoucherSaved(this.id, this.voucherNo);

  final String id;
  final String voucherNo;
}

final class VoucherInvalid extends VoucherSaveResult {
  const VoucherInvalid(this.problems);

  final List<VoucherProblem> problems;
}

final class VoucherNotPermitted extends VoucherSaveResult {
  const VoucherNotPermitted(
    this.permission, {
    this.backdateDays,
    this.lockedYear = false,
  });

  final Permission permission;
  final int? backdateDays;

  /// The date is in a closed financial year.
  final bool lockedYear;
}

/// The voucher (or a party / account on it) does not exist here.
final class VoucherNotFound extends VoucherSaveResult {
  const VoucherNotFound();
}

/// Already reversed.
final class VoucherLocked extends VoucherSaveResult {
  const VoucherLocked();
}

/// A posted voucher.
@immutable
class Voucher {
  const Voucher({
    required this.id,
    required this.type,
    required this.voucherNo,
    required this.date,
    required this.total,
    required this.isReversed,
    this.narration,
  });

  factory Voucher.fromRow(Map<String, Object?> r) => Voucher(
    id: r['id']! as String,
    type: VoucherType.parse(r['voucher_type']! as String),
    voucherNo: r['voucher_no']! as String,
    date: LedgerDate.parse(r['entry_date']! as String),
    total: Money(r['total_paise']! as int),
    isReversed: r['status'] == 'reversed',
    narration: r['narration'] as String?,
  );

  final String id;
  final VoucherType type;
  final String voucherNo;
  final LedgerDate date;
  final Money total;
  final bool isReversed;
  final String? narration;
}

/// One journal entry of the accounts day book: a voucher or the entry of a
/// document (lot, payment…).
@immutable
class JournalDayRow {
  const JournalDayRow({
    required this.id,
    required this.sourceKey,
    required this.sourceType,
    required this.date,
    required this.total,
    required this.isReversed,
    this.narration,
    this.voucher,
    this.reversesId,
  });

  final String id;
  final String sourceKey;
  final String sourceType;
  final LedgerDate date;
  final Money total;
  final String? narration;

  /// Set when the entry is a voucher's.
  final Voucher? voucher;

  /// Whether a later entry reverses this one.
  final bool isReversed;

  /// Set when this entry is itself a reversal.
  final String? reversesId;

  bool get isReversal => reversesId != null;
}

/// One line of a journal entry, with its account resolved.
@immutable
class JournalLineView {
  const JournalLineView({
    required this.accountId,
    required this.debit,
    required this.credit,
    this.account,
    this.memo,
  });

  final String accountId;
  final ChartEntry? account;
  final Money debit;
  final Money credit;
  final String? memo;
}
