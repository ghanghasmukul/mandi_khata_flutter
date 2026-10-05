import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/dashboard/domain/alerts.dart';
import 'package:mandi_khata_app/features/interest/data/interest_posting_repository.dart';
import 'package:mandi_khata_app/features/loans/data/loans_repository.dart';
import 'package:mandi_khata_app/features/loans/domain/loan.dart';
import 'package:powersync/powersync.dart';

/// What wants the owner's attention in the loans and credit: live counts
/// read from the local database (they work offline). Every query is filtered
/// by tenant.
class AlertsRepository {
  AlertsRepository(
    this._db,
    this._loans,
    this._posting, {
    this.planDefaults = const {},
  });

  final PowerSyncDatabase _db;
  final LoansRepository _loans;
  final InterestPostingRepository _posting;

  /// Values from the subscription plan (settings cascade, step 5.1).
  final Map<String, Object?> planDefaults;

  /// Open loans that are overdue, or due within
  /// [LoanRules.dueSoonDays] days. Live.
  Stream<LoanAlerts> watchLoans(String tenantId, LedgerDate today) =>
      _loans.watchAll(tenantId, const LoanFilter(), asOf: today).map((loans) {
        var overdue = 0;
        var dueSoon = 0;
        for (final s in loans) {
          switch (s.position.health) {
            case LoanHealth.overdue:
              overdue++;
            case LoanHealth.dueSoon:
              dueSoon++;
            case _:
          }
        }
        return LoanAlerts(overdue: overdue, dueSoon: dueSoon);
      });

  /// Parties who owe more than their credit limit (`business.credit_limit`
  /// resolved per party: party, group, business). Live.
  Stream<CreditAlerts> watchCredit(String tenantId) => _db
      .watch(
        "SELECT party_id, SUM(CASE side WHEN 'jama' THEN amount_paise "
        'ELSE -amount_paise END) AS bal FROM ledger_entries '
        'WHERE tenant_id = ? GROUP BY party_id HAVING bal < 0',
        parameters: [tenantId],
        triggerOnTables: const {'ledger_entries', 'settings', 'parties'},
      )
      .asyncMap((owing) async {
        if (owing.isEmpty) return CreditAlerts.none;
        return await _db.readTransaction((tx) async {
          final rows = await SettingsRepository.rowsLikeIn(
            tx,
            tenantId,
            'business.credit_limit',
          );
          // No limit anywhere: nothing can be over it.
          if (rows.every((r) => (r.value ?? 0) == 0)) return CreditAlerts.none;
          final resolver = SettingsResolver(rows, planDefaults: planDefaults);
          final groups = {
            for (final r in await tx.getAll(
              'SELECT id, party_group_id FROM parties WHERE tenant_id = ? '
              'AND deleted_at IS NULL',
              [tenantId],
            ))
              r['id']! as String: r['party_group_id'] as String?,
          };
          var count = 0;
          var excess = Money.zero;
          for (final r in owing) {
            final id = r['party_id']! as String;
            if (!groups.containsKey(id)) continue;
            final limit = resolver
                .resolve(
                  'business.credit_limit',
                  partyId: id,
                  partyGroupId: groups[id],
                )
                .asInt;
            final over = CreditLimit.excess(Money(r['bal']! as int), limit);
            if (over != null) {
              count++;
              excess += over;
            }
          }
          return CreditAlerts(count: count, excess: excess);
        });
      });

  /// Interest of the last quarter (up to its boundary day) not yet posted.
  /// Heavy (the engine runs for every account), so refreshed at most every
  /// two seconds and only asked for by members who can post.
  Stream<UnpostedInterest> watchUnposted(String tenantId, LedgerDate today) {
    final boundary = PostingSchedule.suggestedAsOf('quarterly', today);
    return _db
        .watch(
          'SELECT COUNT(*) AS n FROM interest_postings WHERE tenant_id = ?',
          parameters: [tenantId],
          triggerOnTables: const {
            'interest_postings',
            'ledger_entries',
            'loans',
            'settings',
          },
          throttle: const Duration(seconds: 2),
        )
        .asyncMap((_) async {
          final found = await _posting.candidates(tenantId, boundary);
          final open = [
            for (final c in found)
              if (!c.alreadyPosted) c,
          ];
          return UnpostedInterest(
            asOf: boundary,
            accounts: open.length,
            amount: Money(open.fold(0, (sum, c) => sum + c.amount.paise)),
          );
        });
  }
}
