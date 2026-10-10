import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/numbering/number_series_service.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/parties/data/parties_repository.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// How an import ended.
sealed class OpeningImportResult {
  const OpeningImportResult();
}

final class OpeningImported extends OpeningImportResult {
  const OpeningImported({
    required this.batchId,
    required this.newParties,
    required this.entries,
    required this.totalUdhaar,
    required this.totalJama,
  });

  final String batchId;
  final int newParties;
  final int entries;
  final Money totalUdhaar;
  final Money totalJama;
}

/// This exact file (same rows, same date) was imported before.
final class OpeningAlreadyImported extends OpeningImportResult {
  const OpeningAlreadyImported();
}

/// Every valid row is already in the books: nothing to post.
final class OpeningNothingToImport extends OpeningImportResult {
  const OpeningNothingToImport();
}

final class OpeningNotPermitted extends OpeningImportResult {
  const OpeningNotPermitted(this.permission);

  final Permission permission;
}

/// The opening date is in the future.
final class OpeningBadDate extends OpeningImportResult {
  const OpeningBadDate();
}

/// Something changed since the preview (a party got an opening balance or a
/// code from another device, a party was deleted…). Nothing was written;
/// preview again.
final class OpeningStale extends OpeningImportResult {
  const OpeningStale(this.rowNumber);

  final int rowNumber;
}

/// Reads and posts opening balances in the local database (offline-first).
///
/// The whole import is ONE local write transaction (parties, roles, ledger
/// entries and audit rows), so the connector uploads it all-or-nothing and a
/// failure leaves nothing half-imported.
///
/// Safe against double import:
/// * a party that already has an (unreversed) opening balance is refused at
///   preview time and re-checked inside the transaction;
/// * the same file and date has the same batch id, remembered as the
///   `ref_id` of its entries: importing it again is refused;
/// * party and entry ids are deterministic (UUID v5), so the same import
///   made offline on two devices lands on the same rows instead of twice.
class OpeningBalancesRepository {
  OpeningBalancesRepository(this._db);

  final PowerSyncDatabase _db;

  static const _idNamespace = '9a4e7c10-6b2d-4e53-8f19-3c5d0a7e2b68';

  /// The party id a row gets when the import creates it: derived from the
  /// code, or the name / village / mobile, never random.
  static String newPartyId(String tenantId, OpeningRow row) {
    final key = row.code != null
        ? 'code:${row.code}'
        : 'name:${OpeningBalanceImport.normaliseName(row.name)}|'
              '${OpeningBalanceImport.normaliseName(row.village ?? '')}|'
              '${row.mobile ?? ''}';
    return const Uuid().v5(_idNamespace, '$tenantId|party|$key');
  }

  static String entryId(String tenantId, String partyId, LedgerDate asOn) =>
      const Uuid().v5(_idNamespace, '$tenantId|entry|$partyId|$asOn');

  /// Same file + same date = same batch.
  static String batchId(
    String tenantId,
    OpeningPreview preview,
    LedgerDate asOn,
  ) => const Uuid().v5(
    _idNamespace,
    '$tenantId|batch|$asOn|${preview.fingerprint}',
  );

  /// Every active party of [tenantId], with whether it already has an
  /// opening balance, for matching.
  Future<List<ExistingParty>> existingParties(String tenantId) async {
    final rows = await _db.getAll(
      'SELECT p.id, p.code, p.name, p.village, p.mobile, '
      'EXISTS (SELECT 1 FROM ledger_entries e '
      'WHERE e.tenant_id = p.tenant_id AND e.party_id = p.id '
      "AND e.ref_type = 'opening_balance' AND e.reverses_id IS NULL "
      'AND NOT EXISTS (SELECT 1 FROM ledger_entries r '
      'WHERE r.tenant_id = e.tenant_id AND r.reverses_id = e.id)) '
      'AS has_opening '
      'FROM parties p WHERE p.tenant_id = ? AND p.deleted_at IS NULL',
      [tenantId],
    );
    return [
      for (final r in rows)
        ExistingParty(
          id: r['id']! as String,
          code: r['code']! as String,
          name: r['name']! as String,
          village: r['village'] as String?,
          mobile: r['mobile'] as String?,
          hasOpeningBalance: r['has_opening'] == 1,
        ),
    ];
  }

  /// Whether a batch with this id has posted entries (the same file was
  /// already imported).
  Future<bool> batchImported(String tenantId, String batchId) async =>
      await _db.getOptional(
        'SELECT 1 FROM ledger_entries WHERE tenant_id = ? AND ref_id = ? '
        'LIMIT 1',
        [tenantId, batchId],
      ) !=
      null;

  /// Posts the valid rows of [preview] as of [asOn]: creates the missing
  /// parties and one `opening_balance` entry per row with an amount.
  Future<OpeningImportResult> import(
    WriteContext ctx,
    OpeningPreview preview, {
    required LedgerDate asOn,
    required bool Function(Permission) can,
    String? fileName,

    /// Where the rows came from: `file` or `tally` (shown with the batch).
    String source = 'file',
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    final today = LedgerDate.fromDateTime(when);
    if (asOn > today) return const OpeningBadDate();
    final rows = [
      for (final r in preview.valid)
        if (r.createsParty || r.postsEntry) r,
    ];
    if (rows.isEmpty) return const OpeningNothingToImport();
    if (!can(Permission.entriesReverse)) {
      return const OpeningNotPermitted(Permission.entriesReverse);
    }
    if (rows.any((r) => r.createsParty) && !can(Permission.partiesManage)) {
      return const OpeningNotPermitted(Permission.partiesManage);
    }

    final batch = batchId(ctx.tenantId, preview, asOn);
    final at = when.toUtc().toIso8601String();
    return await _db
        .writeTransaction<OpeningImportResult>((tx) async {
          if (await _batchImportedIn(tx, ctx.tenantId, batch)) {
            return const OpeningAlreadyImported();
          }
          final refused = await LedgerRepository.checkDate(
            tx,
            ctx,
            RefType.openingBalance,
            asOn,
            can: can,
            now: when,
          );
          if (refused != null) return OpeningNotPermitted(refused.permission);

          var created = 0;
          final newPartyIds = <String>[];
          var entries = 0;
          var udhaar = Money.zero;
          var jama = Money.zero;
          for (final row in rows) {
            final String partyId;
            if (row.matchedPartyId != null) {
              partyId = row.matchedPartyId!;
              // Still there, and still without an opening balance?
              final state = await tx.getOptional(
                'SELECT 1 FROM parties WHERE tenant_id = ? AND id = ? '
                'AND deleted_at IS NULL',
                [ctx.tenantId, partyId],
              );
              if (state == null ||
                  (row.postsEntry &&
                      await _hasOpening(tx, ctx.tenantId, partyId))) {
                // Throw (not return) so the whole transaction rolls back.
                throw _Stale(row.number);
              }
            } else {
              partyId = newPartyId(ctx.tenantId, row);
              final existingRow = await tx.getOptional(
                'SELECT 1 FROM parties WHERE tenant_id = ? AND id = ?',
                [ctx.tenantId, partyId],
              );
              if (existingRow != null) {
                // The same import already ran here or on another device that
                // has synced: reuse the party, post only what is missing.
                if (row.postsEntry &&
                    await _hasOpening(tx, ctx.tenantId, partyId)) {
                  throw _Stale(row.number);
                }
              } else {
                final String code;
                if (row.code != null) {
                  if (await PartiesRepository.codeTaken(
                    tx,
                    ctx.tenantId,
                    row.code!,
                  )) {
                    throw _Stale(row.number);
                  }
                  code = row.code!;
                } else {
                  code = await _nextFreeCode(tx, ctx, when);
                }
                await PartiesRepository.insertIn(
                  tx,
                  ctx,
                  PartyInput(
                    code: code,
                    name: row.name,
                    roles: {row.role},
                    fatherOrHusbandName: row.fatherName,
                    village: row.village,
                    mobile: row.mobile,
                  ).normalised(),
                  id: partyId,
                  when: when,
                );
                created++;
                newPartyIds.add(partyId);
              }
            }

            if (row.postsEntry) {
              final id = entryId(ctx.tenantId, partyId, asOn);
              final taken = await tx.getOptional(
                'SELECT 1 FROM ledger_entries WHERE id = ?',
                [id],
              );
              if (taken != null) throw _Stale(row.number);
              await LedgerRepository.post(
                tx,
                ctx,
                LedgerDraft(
                  partyId: partyId,
                  side: row.side!,
                  amount: row.amount,
                  refType: RefType.openingBalance,
                  entryDate: asOn,
                  refId: batch,
                ),
                now: when,
                id: id,
              );
              entries++;
              if (row.side == Side.udhaar) {
                udhaar += row.amount;
              } else {
                jama += row.amount;
              }
            }
          }

          await AuditWriter.record(
            tx,
            ctx,
            table: 'opening_balance_imports',
            rowId: batch,
            action: AuditAction.insert,
            after: {
              'file': fileName,
              'source': source,
              'party_ids': newPartyIds,
              'as_on': asOn.toString(),
              'rows': rows.length,
              'new_parties': created,
              'entries': entries,
              'udhaar_paise': udhaar.paise,
              'jama_paise': jama.paise,
              'imported_at': at,
            },
            at: when,
          );
          return OpeningImported(
            batchId: batch,
            newParties: created,
            entries: entries,
            totalUdhaar: udhaar,
            totalJama: jama,
          );
        })
        .onError<_Stale>((e, _) => OpeningStale(e.row));
  }

  Future<String> _nextFreeCode(
    SqliteWriteContext tx,
    WriteContext ctx,
    DateTime when,
  ) async {
    // Skip numbers someone already typed in by hand as a code.
    while (true) {
      final code = await NumberSeriesService.next(
        tx,
        ctx,
        DocumentSeries.party,
        now: when,
      );
      if (!await PartiesRepository.codeTaken(tx, ctx.tenantId, code)) {
        return code;
      }
    }
  }

  static Future<bool> _hasOpening(
    SqliteWriteContext tx,
    String tenantId,
    String partyId,
  ) async =>
      await tx.getOptional(
        'SELECT 1 FROM ledger_entries e WHERE e.tenant_id = ? '
        "AND e.party_id = ? AND e.ref_type = 'opening_balance' "
        'AND e.reverses_id IS NULL AND NOT EXISTS (SELECT 1 FROM '
        'ledger_entries r WHERE r.tenant_id = e.tenant_id '
        'AND r.reverses_id = e.id) LIMIT 1',
        [tenantId, partyId],
      ) !=
      null;

  static Future<bool> _batchImportedIn(
    SqliteWriteContext tx,
    String tenantId,
    String batch,
  ) async =>
      await tx.getOptional(
        'SELECT 1 FROM ledger_entries WHERE tenant_id = ? AND ref_id = ? '
        'LIMIT 1',
        [tenantId, batch],
      ) !=
      null;
}

class _Stale implements Exception {
  const _Stale(this.row);

  final int row;
}
