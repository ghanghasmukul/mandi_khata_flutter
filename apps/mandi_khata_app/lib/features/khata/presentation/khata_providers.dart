import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/khata/data/ledger_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'khata_providers.g.dart';

@Riverpod(keepAlive: true)
Future<LedgerRepository> ledgerRepository(Ref ref) async =>
    LedgerRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// A party's khata statement in the active business for [from]..[to]
/// (either open).
@riverpod
Stream<Statement> partyStatement(
  Ref ref,
  String partyId, {
  LedgerDate? from,
  LedgerDate? to,
}) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const Statement(
      opening: Money.zero,
      rows: [],
      totalUdhaar: Money.zero,
      totalJama: Money.zero,
    );
    return;
  }
  final repo = await ref.watch(ledgerRepositoryProvider.future);
  yield* repo.watchStatement(tenantId, partyId, from: from, to: to);
}

/// Balance of every party with entries in the active business.
@riverpod
Stream<Map<String, Money>> partyBalances(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const {};
    return;
  }
  final repo = await ref.watch(ledgerRepositoryProvider.future);
  yield* repo.watchBalances(tenantId);
}
