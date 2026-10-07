import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/cash_book_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/chart_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/accounts/data/voucher_repository.dart';
import 'package:mandi_khata_app/features/accounts/domain/voucher.dart';
import 'package:mandi_khata_app/features/payments/data/bank_accounts_repository.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

/// A saved cash count.
@immutable
class CashCountRow {
  const CashCountRow({
    required this.id,
    required this.date,
    required this.counted,
    required this.book,
    this.voucherId,
    this.note,
  });

  final String id;
  final LedgerDate date;
  final Money counted;
  final Money book;
  final String? voucherId;
  final String? note;

  Money get difference => counted - book;
}

sealed class CashCountResult {
  const CashCountResult();
}

final class CashCountSaved extends CashCountResult {
  const CashCountSaved(this.id, {this.voucherNo});

  final String id;

  /// The journal voucher that posted the difference, when one was posted.
  final String? voucherNo;
}

final class CashCountNotPermitted extends CashCountResult {
  const CashCountNotPermitted(this.permission);

  final Permission permission;
}

/// The difference could not be posted (the voucher was refused); nothing
/// was saved.
final class CashCountVoucherRefused extends CashCountResult {
  const CashCountVoucherRefused(this.result);

  final VoucherSaveResult result;
}

/// Cash counted at day close (docs/domain/posting-rules.md, 11.3).
class CashCountRepository {
  CashCountRepository(this._db, this._vouchers);

  final PowerSyncDatabase _db;
  final VoucherRepository _vouchers;

  /// The Cash book balance at the end of [on].
  Future<Money> bookBalance(String tenantId, LedgerDate on) =>
      _db.readTransaction(
        (tx) => CashBookRepository.balance(
          tx,
          tenantId,
          BankAccountsRepository.cashIdFor(tenantId),
          on,
        ),
      );

  /// Saves a count of [on] (needs `payments.create`). When it differs from
  /// the book and [postDifference] is set (needs `entries.reverse`), the
  /// difference is posted as a journal voucher in the same transaction.
  Future<CashCountResult> save(
    WriteContext ctx,
    LedgerDate on,
    CashCount count, {
    required bool Function(Permission) can,
    required bool postDifference,
    String? note,
    DateTime? now,
  }) async {
    if (!can(Permission.paymentsCreate)) {
      return const CashCountNotPermitted(Permission.paymentsCreate);
    }
    if (postDifference && !can(Permission.entriesReverse)) {
      return const CashCountNotPermitted(Permission.entriesReverse);
    }
    final when = now ?? DateTime.now();
    final cashId = BankAccountsRepository.cashIdFor(ctx.tenantId);
    try {
      return await _db.writeTransaction<CashCountResult>((tx) async {
        final book = await CashBookRepository.balance(
          tx,
          ctx.tenantId,
          cashId,
          on,
        );
        String? voucherId;
        String? voucherNo;
        final lines = VoucherRules.cashDifference(
          cashBankAccountId: cashId,
          counted: count.total,
          book: book,
        );
        if (postDifference && lines != null) {
          final chart = await ChartRepository.load(tx, ctx.tenantId);
          final accounts = [
            for (final l in lines)
              chart.byId(JournalWriter.accountId(ctx.tenantId, l.account)),
          ];
          if (accounts.contains(null)) {
            throw const _Refused(VoucherNotFound());
          }
          final draft = VoucherDraft(
            type: VoucherType.journal,
            date: on,
            narration: note,
            lines: [
              for (final (i, l) in lines.indexed)
                VoucherDraftLine(
                  account: accounts[i]!,
                  side: l.side,
                  amount: l.amount,
                ),
            ],
          );
          final result = await _vouchers.saveIn(
            tx,
            ctx,
            draft,
            can: can,
            when: when,
            allowBooksInJournal: true,
          );
          if (result is! VoucherSaved) {
            throw _Refused(result);
          }
          voucherId = result.id;
          voucherNo = result.voucherNo;
        }
        final id = const Uuid().v4();
        final at = when.toUtc().toIso8601String();
        final columns = <String, Object?>{
          'count_date': on.toString(),
          'bank_account_id': cashId,
          'denominations': jsonEncode(count.toJson()),
          'counted_paise': count.total.paise,
          'book_paise': book.paise,
          'difference_paise': count.difference(book).paise,
          'voucher_id': voucherId,
          'note': note == null || note.trim().isEmpty ? null : note.trim(),
        };
        await tx.execute(
          'INSERT INTO cash_counts (id, tenant_id, '
          '${columns.keys.join(', ')}, '
          'device_id, created_by, created_at, updated_at) '
          'VALUES (${List.filled(columns.length + 6, '?').join(', ')})',
          [
            id,
            ctx.tenantId,
            ...columns.values,
            ctx.deviceId,
            ctx.userId,
            at,
            at,
          ],
        );
        await AuditWriter.record(
          tx,
          ctx,
          table: 'cash_counts',
          rowId: id,
          action: AuditAction.insert,
          after: {
            for (final MapEntry(:key, :value) in columns.entries) key: ?value,
          },
          at: when,
        );
        return CashCountSaved(id, voucherNo: voucherNo);
      });
    } on _Refused catch (e) {
      return CashCountVoucherRefused(e.result);
    }
  }

  /// Counts of [tenantId], newest first. Live.
  Stream<List<CashCountRow>> watch(String tenantId) => _db
      .watch(
        'SELECT * FROM cash_counts WHERE tenant_id = ? '
        'ORDER BY count_date DESC, created_at DESC LIMIT 100',
        parameters: [tenantId],
        triggerOnTables: const {'cash_counts'},
      )
      .map(
        (rows) => [
          for (final r in rows)
            CashCountRow(
              id: r['id']! as String,
              date: LedgerDate.parse(r['count_date']! as String),
              counted: Money(r['counted_paise']! as int),
              book: Money(r['book_paise']! as int),
              voucherId: r['voucher_id'] as String?,
              note: r['note'] as String?,
            ),
        ],
      );
}

/// Rolls the transaction back when the difference voucher is refused.
class _Refused implements Exception {
  const _Refused(this.result);

  final VoucherSaveResult result;
}
