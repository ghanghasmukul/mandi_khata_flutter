import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/loans/data/loans_repository.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:powersync/powersync.dart';
import 'package:sqlite_async/sqlite_async.dart'
    show SqliteReadContext, SqliteWriteContext;
import 'package:uuid/uuid.dart';

/// Posts interest to the khata and settles accounts (hisaab), in the local
/// database (offline-first).
///
/// What is owed is never stored: the engine (khata_core) runs over the khata
/// or the loan's entries. Posting turns what is charged and not yet posted
/// into ONE udhaar entry (`ref_type = interest`) plus its `interest_postings`
/// row and audit rows, written in one local transaction and uploaded
/// all-or-nothing. The row's `period_key` and the deterministic ids make a
/// re-run, or the same run on two devices, post an account up to a day once.
///
/// A loan is always posted on its own snapshot terms. A party whose interest
/// runs on the whole khata (`net_udhaar`) is also posted on the khata, which
/// leaves the loan entries out (khata_core `KhataInterest.events`): the same
/// money is never charged twice.
class InterestPostingRepository {
  InterestPostingRepository(this._db, {this.planDefaults = const {}});

  final PowerSyncDatabase _db;

  /// Values from the subscription plan (settings cascade, step 5.1).
  final Map<String, Object?> planDefaults;

  /// Namespace of the deterministic posting / entry ids.
  static const _idNamespace = 'c1a0e5b7-6f2d-4c8e-9a41-7d3b52e08f19';

  static String postingIdFor(String tenantId, String periodKey) =>
      const Uuid().v5(_idNamespace, '$tenantId|$periodKey|posting');

  static String entryIdFor(String tenantId, String periodKey) =>
      const Uuid().v5(_idNamespace, '$tenantId|$periodKey|entry');

  static const _tables = {'interest_postings', 'ledger_entries'};

  /// Postings of one party (khata and loans), newest period first. Live.
  Stream<List<PostingRow>> watchParty(String tenantId, String partyId) => _db
      .watch(
        _postingsSql('AND ip.party_id = ? '),
        parameters: [tenantId, partyId],
        triggerOnTables: _tables,
      )
      .map(
        (rows) => [
          for (final r in rows)
            PostingRow.fromRow(r, reversed: (r['reversed']! as int) == 1),
        ],
      );

  /// A posting is reversed when its interest entry has a reversal.
  static String _postingsSql(String extra) =>
      'SELECT ip.*, EXISTS (SELECT 1 FROM ledger_entries e '
      'WHERE e.tenant_id = ip.tenant_id AND e.ref_id = ip.id '
      "AND e.ref_type IN ('interest', 'journal') "
      'AND EXISTS (SELECT 1 FROM ledger_entries r '
      'WHERE r.tenant_id = e.tenant_id AND r.reverses_id = e.id)) '
      'AS reversed '
      'FROM interest_postings ip WHERE ip.tenant_id = ? $extra'
      'ORDER BY ip.period_to DESC, ip.created_at DESC, ip.id';

  /// Every account with interest to post as of [asOf] (one party only when
  /// [partyId] is given), by party name. Accounts with nothing to post, and
  /// parties without interest, are left out.
  Future<List<PostingCandidate>> candidates(
    String tenantId,
    LedgerDate asOf, {
    String? partyId,
  }) => _db.readTransaction(
    (tx) => _candidatesIn(tx, tenantId, asOf, partyId: partyId),
  );

  Future<List<PostingCandidate>> _candidatesIn(
    SqliteReadContext tx,
    String tenantId,
    LedgerDate asOf, {
    String? partyId,
  }) async {
    final partyRows = await tx.getAll(
      'SELECT p.*, (SELECT group_concat(r.role) FROM party_roles r '
      'WHERE r.party_id = p.id AND r.deleted_at IS NULL) AS roles '
      'FROM parties p WHERE p.tenant_id = ? AND p.deleted_at IS NULL '
      '${partyId == null ? '' : 'AND p.id = ? '}ORDER BY lower(p.name), p.id',
      [tenantId, ?partyId],
    );
    if (partyRows.isEmpty) return const [];
    final resolver = SettingsResolver(
      await SettingsRepository.interestRowsIn(tx, tenantId),
      planDefaults: planDefaults,
    );
    final entryRows = await tx.getAll(
      'SELECT * FROM ledger_entries WHERE tenant_id = ? '
      '${partyId == null ? '' : 'AND party_id = ? '}',
      [tenantId, ?partyId],
    );
    final entries = <String, List<LedgerEntry>>{};
    for (final r in entryRows) {
      final e = LedgerRepository.fromRow(r);
      entries.putIfAbsent(e.partyId, () => []).add(e);
    }
    final postingRows = await tx.getAll(
      _postingsSql(partyId == null ? '' : 'AND ip.party_id = ? '),
      [tenantId, ?partyId],
    );
    final postings = <String, List<PostingRow>>{};
    final keys = <String, bool>{};
    for (final r in postingRows) {
      final reversed = (r['reversed']! as int) == 1;
      final row = PostingRow.fromRow(r, reversed: reversed);
      postings.putIfAbsent(row.partyId, () => []).add(row);
      if (!row.isWaiver && !reversed) keys[r['period_key']! as String] = true;
    }
    final loans = await LoansRepository.openDetailsIn(
      tx,
      tenantId,
      partyId: partyId,
    );
    final loansByParty = <String, List<LoanDetail>>{};
    for (final d in loans) {
      loansByParty.putIfAbsent(d.loan.partyId, () => []).add(d);
    }

    final out = <PostingCandidate>[];
    for (final r in partyRows) {
      final party = Party.fromRow(r);
      final config = InterestConfig.fromSettings(
        resolver,
        partyId: party.id,
        partyGroupId: party.partyGroupId,
        partyRoles: party.roles,
      );
      final mine = postings[party.id] ?? const <PostingRow>[];

      PostingCandidate? candidate({
        required InterestResult result,
        required InterestConfig config,
        required LedgerDate first,
        required PostedSummary posted,
        String? loanId,
        String? loanNo,
      }) {
        final plan = InterestPosting.plan(
          scope: loanId == null ? PostingScope.khata : PostingScope.loan,
          partyId: party.id,
          loanId: loanId,
          result: result,
          config: config,
          firstEventDate: first,
          lastPostedTo: posted.lastPostedTo,
          asOf: asOf,
          postedPaise: posted.postedPaise,
        );
        if (plan == null) return null;
        return PostingCandidate(
          partyName: party.name,
          partyCode: party.code,
          plan: plan,
          principal: Money(result.principalPaise),
          loanNo: loanNo,
          alreadyPosted: keys.containsKey(plan.periodKey),
        );
      }

      if (KhataInterest.mode(config) == KhataInterestMode.khata) {
        final posted = PostedSummary.of(mine);
        final all = entries[party.id] ?? const <LedgerEntry>[];
        final loanWaivers = PostedSummary.loanWaiverIds(mine);
        final events = KhataInterest.events(
          all,
          waiverIds: posted.waiverIds,
          loanWaiverIds: loanWaivers,
        ).where((e) => !e.isPostedInterest);
        if (events.isNotEmpty) {
          final first = events
              .map((e) => e.date)
              .reduce((a, b) => a < b ? a : b);
          final result = KhataInterest.calculate(
            entries: all,
            config: config,
            asOf: asOf,
            waiverIds: posted.waiverIds,
            loanWaiverIds: loanWaivers,
          );
          final c = candidate(
            result: result,
            config: config,
            first: first,
            posted: posted,
          );
          if (c != null) out.add(c);
        }
      }
      // A loan is always its own account, on its own snapshot terms.
      for (final d in loansByParty[party.id] ?? const <LoanDetail>[]) {
        final result = calculate(
          events: d.events,
          config: d.loan.config,
          asOf: asOf,
          rateChanges: d.engineRateChanges,
        );
        final c = candidate(
          result: result,
          config: d.loan.config,
          first: d.loan.issueDate,
          posted: PostedSummary.of(mine, loanId: d.loan.id),
          loanId: d.loan.id,
          loanNo: d.loan.loanNo,
        );
        if (c != null) out.add(c);
      }
    }
    return out;
  }

  /// Posts [plans] (needs `loans.manage`) in batches of [batchSize], each
  /// batch one local transaction. Plans already posted are skipped, so the
  /// run can be repeated safely. [batchId] groups the rows of one run.
  Future<PostingResult> post(
    WriteContext ctx,
    List<InterestPostingPlan> plans, {
    required bool Function(Permission) can,
    int batchSize = 25,
    String? batchId,
    DateTime? now,
  }) async {
    if (!can(Permission.loansManage)) {
      return const PostingNotPermitted(Permission.loansManage);
    }
    final when = now ?? DateTime.now();
    final today = LedgerDate.fromDateTime(when);
    if (plans.any((p) => p.to > today)) return const PostingInFuture();
    final run = batchId ?? const Uuid().v4();
    final posted = <InterestPostingPlan>[];
    final skipped = <SkippedPosting>[];
    for (var i = 0; i < plans.length; i += batchSize) {
      final batch = plans.skip(i).take(batchSize);
      await _db.writeTransaction((tx) async {
        // What the engine charges NOW, per account (party and day): the
        // preview may be stale (an entry synced or was added meanwhile).
        final fresh = <String, List<PostingCandidate>>{};
        for (final plan in batch) {
          final accounts = fresh[_freshKey(plan)] ??= await _candidatesIn(
            tx,
            ctx.tenantId,
            plan.to,
            partyId: plan.partyId,
          );
          final current = accounts.where(
            (c) => c.plan.periodKey == plan.periodKey,
          );
          if (current.isEmpty ||
              current.first.plan.amountPaise != plan.amountPaise ||
              current.first.plan.from != plan.from) {
            skipped.add(
              SkippedPosting(
                plan,
                await _precheck(tx, ctx.tenantId, plan) ?? PostingSkip.changed,
              ),
            );
            continue;
          }
          final skip = await _postIn(
            tx,
            ctx,
            plan,
            can: can,
            now: when,
            batchId: run,
          );
          if (skip == null) {
            posted.add(plan);
          } else {
            skipped.add(SkippedPosting(plan, skip));
          }
        }
      });
    }
    return InterestPosted(posted: posted, skipped: skipped);
  }

  static String _freshKey(InterestPostingPlan plan) =>
      '${plan.partyId}|${plan.to}';

  /// Hisaab karo for one party: posts the interest charged up to [asOf]
  /// on every account of the party and, per account, the waiver in
  /// [waivers] (key = `SettlementSource.key`, paise), all in ONE
  /// transaction. A waiver needs `entries.reverse` and a [reason].
  Future<PostingResult> settle(
    WriteContext ctx,
    String partyId,
    LedgerDate asOf, {
    required bool Function(Permission) can,
    Map<String, int> waivers = const {},
    String reason = '',
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    if (!can(Permission.loansManage)) {
      return const PostingNotPermitted(Permission.loansManage);
    }
    final waiving = waivers.values.any((v) => v != 0);
    if (waiving && !can(Permission.entriesReverse)) {
      return const PostingNotPermitted(Permission.entriesReverse);
    }
    if (asOf > LedgerDate.fromDateTime(when)) return const PostingInFuture();
    try {
      return await _db.writeTransaction((tx) async {
        final candidates = await _candidatesIn(
          tx,
          ctx.tenantId,
          asOf,
          partyId: partyId,
        );
        final problems = Settlement.validate(
          sources: [for (final c in candidates) c.source],
          waivers: waivers,
          reason: reason,
        );
        if (problems.isNotEmpty) return SettlementInvalid(problems);
        var interest = 0;
        var waived = 0;
        for (final c in candidates) {
          final skip = await _postIn(tx, ctx, c.plan, can: can, now: when);
          if (skip != null) throw _Abort(skip);
          interest += c.plan.amountPaise;
          final waiver = waivers[c.source.key] ?? 0;
          if (waiver > 0) {
            final refused = await _waiveIn(
              tx,
              ctx,
              c.plan,
              waiver,
              reason.trim(),
              asOf,
              can: can,
              now: when,
            );
            if (refused != null) throw const _Abort(PostingSkip.backdated);
            waived += waiver;
          }
        }
        return SettlementDone(interest: Money(interest), waived: Money(waived));
      });
    } on _Abort catch (stop) {
      return PostingRefused(stop.skip);
    }
  }

  /// Why [plan] cannot be posted at all (account gone, or posted up to this
  /// day or later already); null when it can.
  Future<PostingSkip?> _precheck(
    SqliteReadContext tx,
    String tenantId,
    InterestPostingPlan plan,
  ) async {
    if (!await _accountExists(tx, tenantId, plan)) return PostingSkip.notFound;
    final taken = await tx.getOptional(
      'SELECT 1 FROM interest_postings ip WHERE ip.tenant_id = ? '
      "AND ip.kind = 'interest' AND ip.party_id = ? "
      'AND ip.loan_id IS ? AND ip.period_to >= ? AND NOT EXISTS ( '
      'SELECT 1 FROM ledger_entries e WHERE e.tenant_id = ip.tenant_id '
      "AND e.ref_id = ip.id AND e.ref_type = 'interest' AND EXISTS ( "
      'SELECT 1 FROM ledger_entries r WHERE r.tenant_id = e.tenant_id '
      'AND r.reverses_id = e.id))',
      [tenantId, plan.partyId, plan.loanId, plan.to.toString()],
    );
    return taken == null ? null : PostingSkip.alreadyPosted;
  }

  /// Writes one posting; null when posted, else why it was skipped.
  Future<PostingSkip?> _postIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    InterestPostingPlan plan, {
    required bool Function(Permission) can,
    required DateTime now,
    String? batchId,
  }) async {
    final tenantId = ctx.tenantId;
    final blocked = await _precheck(tx, tenantId, plan);
    if (blocked != null) return blocked;
    final refused = await LedgerRepository.checkDate(
      tx,
      ctx,
      RefType.interest,
      plan.entryDate,
      can: can,
      now: now,
      planDefaults: planDefaults,
    );
    if (refused != null) return PostingSkip.backdated;

    final postingId = postingIdFor(tenantId, plan.periodKey);
    final values = <String, Object?>{
      'party_id': plan.partyId,
      'loan_id': plan.loanId,
      'kind': 'interest',
      'period_from': plan.from.toString(),
      'period_to': plan.to.toString(),
      'amount_paise': plan.amountPaise,
      'rate_pa': plan.ratePa.toString(),
      'method': plan.method.name,
      'period_key': plan.periodKey,
      'batch_id': batchId,
    };
    await _insertPosting(tx, ctx, postingId, values, now);
    await AuditWriter.record(
      tx,
      ctx,
      table: 'interest_postings',
      rowId: postingId,
      action: AuditAction.insert,
      after: {...values}..removeWhere((_, v) => v == null),
      at: now,
    );
    await LedgerRepository.post(
      tx,
      ctx,
      LedgerDraft(
        partyId: plan.partyId,
        side: Side.udhaar,
        amount: plan.amount,
        refType: RefType.interest,
        refId: postingId,
        entryDate: plan.entryDate,
        narration:
            'Interest ${plan.from} to ${plan.to} '
            '@ ${plan.ratePa}% p.a.',
      ),
      now: now,
      id: entryIdFor(tenantId, plan.periodKey),
    );
    return null;
  }

  /// Writes a waiver of [paise] on the account of [plan]; null when done,
  /// else the refusal (the date needs `entries.reverse`).
  Future<LedgerNotPermitted?> _waiveIn(
    SqliteWriteContext tx,
    WriteContext ctx,
    InterestPostingPlan plan,
    int paise,
    String reason,
    LedgerDate on, {
    required bool Function(Permission) can,
    required DateTime now,
  }) async {
    final refused = await LedgerRepository.checkDate(
      tx,
      ctx,
      RefType.journal,
      on,
      can: can,
      now: now,
      planDefaults: planDefaults,
    );
    if (refused != null) return refused;
    final id = const Uuid().v4();
    final values = <String, Object?>{
      'party_id': plan.partyId,
      'loan_id': plan.loanId,
      'kind': 'waiver',
      'period_from': on.toString(),
      'period_to': on.toString(),
      'amount_paise': paise,
      'reason': reason,
      'period_key': 'waiver:$id',
    };
    await _insertPosting(tx, ctx, id, values, now);
    await AuditWriter.record(
      tx,
      ctx,
      table: 'interest_postings',
      rowId: id,
      action: AuditAction.insert,
      after: {...values}..removeWhere((_, v) => v == null),
      at: now,
    );
    await LedgerRepository.post(
      tx,
      ctx,
      LedgerDraft(
        partyId: plan.partyId,
        side: Side.jama,
        amount: Money(paise),
        refType: RefType.journal,
        refId: id,
        entryDate: on,
        narration: 'Interest waived · $reason',
      ),
      now: now,
    );
    return null;
  }

  static Future<void> _insertPosting(
    SqliteWriteContext tx,
    WriteContext ctx,
    String id,
    Map<String, Object?> values,
    DateTime now,
  ) => tx.execute(
    'INSERT INTO interest_postings (id, tenant_id, '
    '${values.keys.join(', ')}, device_id, created_by, created_at) '
    'VALUES (${List.filled(values.length + 5, '?').join(', ')})',
    [
      id,
      ctx.tenantId,
      ...values.values,
      ctx.deviceId,
      ctx.userId,
      now.toUtc().toIso8601String(),
    ],
  );

  /// The party (and loan) of [plan] exist in this business; a loan must be
  /// the party's.
  static Future<bool> _accountExists(
    SqliteReadContext tx,
    String tenantId,
    InterestPostingPlan plan,
  ) async {
    final party = await tx.getOptional(
      'SELECT 1 FROM parties WHERE tenant_id = ? AND id = ? '
      'AND deleted_at IS NULL',
      [tenantId, plan.partyId],
    );
    if (party == null) return false;
    final loanId = plan.loanId;
    if (loanId == null) return true;
    return await tx.getOptional(
          'SELECT 1 FROM loans WHERE tenant_id = ? AND id = ? '
          'AND party_id = ?',
          [tenantId, loanId, plan.partyId],
        ) !=
        null;
  }
}

/// Rolls the settlement back: a posting was refused.
class _Abort implements Exception {
  const _Abort(this.skip);

  final PostingSkip skip;
}
