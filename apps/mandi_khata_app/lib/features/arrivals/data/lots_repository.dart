import 'dart:convert';

import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/numbering/number_series_service.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/accounts/data/journal_writer.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart' show SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Arrivals (lots) of one business in the local database (offline-first).
///
/// An open lot (arrived / weighed / sold) is edited freely. Posting resolves
/// the mandi rates from the settings cascade, snapshots them into the lot
/// and writes the lot, the farmer's jama, the buyer's udhaar and every
/// audit row in ONE local transaction, which the connector uploads
/// all-or-nothing. A posted lot is only ever reversed. All maths comes from
/// khata_core.
class LotsRepository {
  LotsRepository(this._db, {this.planDefaults = const {}});

  final PowerSyncDatabase _db;

  /// Values from the subscription plan (settings cascade, step 5.1).
  final Map<String, Object?> planDefaults;

  // Joins match on id and tenant: the lot row is already tenant-filtered.
  static const _select =
      'SELECT l.*, f.name AS farmer_name, f.code AS farmer_code, '
      'f.village AS farmer_village, b.name AS buyer_name, '
      'c.code AS crop_code, c.name_en AS crop_name_en, '
      'c.name_hi AS crop_name_hi, c.name_pa AS crop_name_pa '
      'FROM lots l '
      'LEFT JOIN parties f ON f.id = l.farmer_id AND f.tenant_id = l.tenant_id '
      'LEFT JOIN parties b ON b.id = l.buyer_party_id '
      'AND b.tenant_id = l.tenant_id '
      'LEFT JOIN crops c ON c.id = l.crop_id AND c.tenant_id = l.tenant_id ';

  static const _tables = {'lots', 'parties', 'crops'};

  /// Lots of [tenantId] matching [filter], newest first. Live.
  Stream<List<Lot>> watchAll(String tenantId, LotFilter filter) {
    final text = filter.query.trim().toLowerCase();
    final like = '%${_escape(text)}%';
    return _db
        .watch(
          '$_select WHERE l.tenant_id = ? '
          'AND (? IS NULL OR l.entry_date >= ?) '
          'AND (? IS NULL OR l.entry_date <= ?) '
          'AND (? IS NULL OR l.crop_id = ?) '
          'AND (? IS NULL OR l.status = ?) '
          "AND (? = '' "
          r"OR lower(f.name) LIKE ? ESCAPE '\' "
          r"OR lower(f.code) LIKE ? ESCAPE '\' "
          r"OR lower(l.lot_no) LIKE ? ESCAPE '\') "
          'ORDER BY l.entry_date DESC, l.created_at DESC, l.id DESC',
          parameters: [
            tenantId,
            filter.from?.toString(),
            filter.from?.toString(),
            filter.to?.toString(),
            filter.to?.toString(),
            filter.cropId,
            filter.cropId,
            filter.status?.name,
            filter.status?.name,
            text,
            like,
            like,
            like,
          ],
          triggerOnTables: _tables,
        )
        .map((rows) => [for (final r in rows) Lot.fromRow(r)]);
  }

  /// One lot, or null. Live.
  Stream<Lot?> watchOne(String tenantId, String id) => _db
      .watch(
        '$_select WHERE l.tenant_id = ? AND l.id = ?',
        parameters: [tenantId, id],
        triggerOnTables: _tables,
      )
      .map((rows) => rows.isEmpty ? null : Lot.fromRow(rows.first));

  /// The ledger entries a lot posted (and their reversals). Live.
  Stream<List<LedgerEntry>> watchEntries(String tenantId, String lotId) => _db
      .watch(
        'SELECT e.* FROM ledger_entries e WHERE e.tenant_id = ? AND '
        '(e.ref_id = ? OR e.reverses_id IN (SELECT id FROM ledger_entries '
        'WHERE tenant_id = ? AND ref_id = ?)) '
        'ORDER BY e.created_at, e.id',
        parameters: [tenantId, lotId, tenantId, lotId],
        triggerOnTables: const {'ledger_entries'},
      )
      .map((rows) => [for (final r in rows) LedgerRepository.fromRow(r)]);

  /// The number the next new lot on this device will get (form hint).
  Future<String> previewNextLotNo(WriteContext ctx) =>
      _db.readTransaction((tx) => NumberSeriesService.peek(tx, ctx, _series));

  static const DocumentSeries _series = DocumentSeries.lot;

  /// The mandi rates for a lot of [cropCode] from [farmerId], as the
  /// cascade resolves them now (business → farmer's group → farmer → lot).
  static Future<MandiConfig> resolveConfig(
    SqliteWriteContext tx,
    String tenantId, {
    required String cropCode,
    required String farmerId,
    required String? partyGroupId,
    required String lotId,
    Map<String, Object?> planDefaults = const {},
  }) async {
    final rows = await SettingsRepository.rowsIn(tx, tenantId, (
      partyId: farmerId,
      partyGroupId: partyGroupId,
      documentId: lotId,
    ));
    return MandiConfig.resolve(
      SettingsResolver(rows, planDefaults: planDefaults),
      cropCode: cropCode,
      partyId: farmerId,
      partyGroupId: partyGroupId,
      lotId: lotId,
    );
  }

  /// Creates a lot ([id] null) or saves an open one. With [post] (the
  /// default) a lot that has its weight and rate is posted in the same
  /// transaction; posting problems (e.g. a buyer is needed) are returned and
  /// nothing is written. Without [post] it is kept open ("hold").
  Future<LotSaveResult> save(
    WriteContext ctx,
    LotDraft draft, {
    required bool Function(Permission) can,
    String? id,
    bool post = true,
    DateTime? now,
  }) async {
    if (!can(Permission.arrivalsManage)) {
      return const LotNotPermitted(Permission.arrivalsManage);
    }
    final problems = draft.validate();
    if (problems.isNotEmpty) return LotInvalid(problems);
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();

    return await _db.writeTransaction((tx) async {
      Map<String, Object?>? existing;
      if (id != null) {
        existing = await tx.getOptional(
          'SELECT * FROM lots WHERE tenant_id = ? AND id = ?',
          [ctx.tenantId, id],
        );
        if (existing == null) return const LotNotFound();
        final status = LotStatus.parse(existing['status']! as String);
        if (!status.isOpen) return LotLocked(status);
      }
      final lotId = id ?? const Uuid().v4();

      final farmer = await _party(tx, ctx.tenantId, draft.farmerId);
      if (farmer == null) return const LotNotFound();
      if (draft.buyerId != null &&
          await _party(tx, ctx.tenantId, draft.buyerId!) == null) {
        return const LotNotFound();
      }
      final crop = await tx.getOptional(
        'SELECT code, is_active FROM crops WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, draft.cropId],
      );
      // A crop switched off keeps its old lots, but takes no new ones.
      if (crop == null ||
          (crop['is_active'] == 0 && existing?['crop_id'] != draft.cropId)) {
        return const LotNotFound();
      }

      final columns = draft.columns();
      final toPost = post && draft.qtlMilli != null && draft.rate != null;
      LotPostingPlan? plan;
      if (toPost) {
        // Posting writes khata entries: the back-date window applies.
        final refused = await LedgerRepository.checkDate(
          tx,
          ctx,
          RefType.arrival,
          draft.entryDate,
          can: can,
          now: when,
          planDefaults: planDefaults,
        );
        if (refused != null) {
          return LotNotPermitted(
            refused.permission,
            backdateDays: refused.backdateDays,
          );
        }
        final config = await resolveConfig(
          tx,
          ctx.tenantId,
          cropCode: crop['code']! as String,
          farmerId: draft.farmerId,
          partyGroupId: farmer['party_group_id'] as String?,
          lotId: lotId,
          planDefaults: planDefaults,
        );
        final r = LotRules.planPosting(
          farmerId: draft.farmerId,
          buyerId: draft.buyerId,
          bags: draft.bags,
          qtlMilli: draft.qtlMilli,
          rate: draft.rate,
          config: config,
        );
        if (r.plan == null) return LotInvalid(r.problems);
        plan = r.plan;
        final b = plan!.breakdown;
        columns.addAll({
          'charges_snapshot': jsonEncode(config.toJson()),
          'gross': b.gross.paise,
          'commission': b.commissionEarned.paise,
          'net_to_farmer': b.netToFarmer.paise,
          'buyer_total': b.buyerTotal.paise,
          'posted_at': at,
        });
      }
      columns['status'] = toPost
          ? LotStatus.posted.name
          : LotStatus.draftFor(qtlMilli: draft.qtlMilli, rate: draft.rate).name;

      final String lotNo;
      if (existing == null) {
        lotNo = await NumberSeriesService.next(tx, ctx, _series, now: when);
        await tx.execute(
          'INSERT INTO lots (id, tenant_id, lot_no, '
          '${columns.keys.join(', ')}, '
          'device_id, created_by, created_at, updated_at) '
          'VALUES (${List.filled(columns.length + 7, '?').join(', ')})',
          [
            lotId,
            ctx.tenantId,
            lotNo,
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
          table: 'lots',
          rowId: lotId,
          action: AuditAction.insert,
          after: {'lot_no': lotNo, ..._auditable(columns)},
          at: when,
        );
      } else {
        lotNo = existing['lot_no']! as String;
        final changed = {
          for (final MapEntry(:key, :value) in columns.entries)
            if (existing[key] != value) key: value,
        };
        if (changed.isNotEmpty) {
          await tx.execute(
            'UPDATE lots SET '
            '${changed.keys.map((k) => '$k = ?').join(', ')}, updated_at = ? '
            'WHERE tenant_id = ? AND id = ?',
            [...changed.values, at, ctx.tenantId, lotId],
          );
          await AuditWriter.record(
            tx,
            ctx,
            table: 'lots',
            rowId: lotId,
            action: AuditAction.update,
            before: _auditable({for (final k in changed.keys) k: existing[k]}),
            after: _auditable(changed),
            at: when,
          );
        }
      }

      if (plan != null) {
        for (final line in plan.lines) {
          await LedgerRepository.post(
            tx,
            ctx,
            LedgerDraft(
              partyId: line.partyId,
              side: line.side,
              amount: line.amount,
              refType: RefType.arrival,
              refId: lotId,
              entryDate: draft.entryDate,
              narration: lotNo,
            ),
            now: when,
          );
        }
        await JournalWriter.post(
          tx,
          ctx,
          PostingRules.lot(
            lotId: lotId,
            date: draft.entryDate,
            plan: plan,
            lotNo: lotNo,
          ),
          now: when,
        );
      }
      return LotSaved(
        lotId,
        lotNo,
        LotStatus.parse(columns['status']! as String),
      );
    });
  }

  /// Reverses a posted lot (needs `entries.reverse`): every ledger entry it
  /// posted is reversed, dated like the original, and the lot is marked
  /// reversed — one transaction.
  Future<LotSaveResult> reverse(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.entriesReverse)) {
      return const LotNotPermitted(Permission.entriesReverse);
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final lot = await tx.getOptional(
        'SELECT lot_no, status FROM lots WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, id],
      );
      if (lot == null) return const LotNotFound();
      final status = LotStatus.parse(lot['status']! as String);
      if (status != LotStatus.posted) return LotLocked(status);
      final lotNo = lot['lot_no']! as String;

      final entries = await tx.getAll(
        'SELECT e.id FROM ledger_entries e WHERE e.tenant_id = ? '
        "AND e.ref_id = ? AND e.ref_type = 'arrival' AND NOT EXISTS ( "
        'SELECT 1 FROM ledger_entries r WHERE r.tenant_id = e.tenant_id '
        'AND r.reverses_id = e.id) ORDER BY e.created_at, e.id',
        [ctx.tenantId, id],
      );
      for (final e in entries) {
        await LedgerRepository.reverseIn(
          tx,
          ctx,
          e['id']! as String,
          narration: lotNo,
          now: when,
        );
      }
      await _setStatus(tx, ctx, id, status, LotStatus.reversed, when);
      return LotSaved(id, lotNo, LotStatus.reversed);
    });
  }

  /// Cancels an open lot that never happened (needs `arrivals.manage`).
  /// Nothing was posted, so nothing is reversed.
  Future<LotSaveResult> cancel(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.arrivalsManage)) {
      return const LotNotPermitted(Permission.arrivalsManage);
    }
    final when = now ?? DateTime.now();
    return await _db.writeTransaction((tx) async {
      final lot = await tx.getOptional(
        'SELECT lot_no, status FROM lots WHERE tenant_id = ? AND id = ?',
        [ctx.tenantId, id],
      );
      if (lot == null) return const LotNotFound();
      final status = LotStatus.parse(lot['status']! as String);
      if (!status.isOpen) return LotLocked(status);
      await _setStatus(tx, ctx, id, status, LotStatus.reversed, when);
      return LotSaved(id, lot['lot_no']! as String, LotStatus.reversed);
    });
  }

  static Future<void> _setStatus(
    SqliteWriteContext tx,
    WriteContext ctx,
    String id,
    LotStatus from,
    LotStatus to,
    DateTime when,
  ) async {
    await tx.execute(
      'UPDATE lots SET status = ?, updated_at = ? '
      'WHERE tenant_id = ? AND id = ?',
      [to.name, when.toUtc().toIso8601String(), ctx.tenantId, id],
    );
    await AuditWriter.record(
      tx,
      ctx,
      table: 'lots',
      rowId: id,
      action: from == LotStatus.posted
          ? AuditAction.reverse
          : AuditAction.update,
      before: {'status': from.name},
      after: {'status': to.name},
      at: when,
    );
  }

  static Future<Map<String, Object?>?> _party(
    SqliteWriteContext tx,
    String tenantId,
    String id,
  ) => tx.getOptional(
    'SELECT id, party_group_id FROM parties '
    'WHERE tenant_id = ? AND id = ? AND deleted_at IS NULL',
    [tenantId, id],
  );

  /// Audit values: the snapshot as JSON, not a JSON string.
  static Map<String, Object?> _auditable(Map<String, Object?> columns) => {
    for (final MapEntry(:key, :value) in columns.entries)
      key: key == 'charges_snapshot' && value is String
          ? jsonDecode(value)
          : value,
  };

  static String _escape(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
