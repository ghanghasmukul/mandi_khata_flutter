import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/audit/data/audit_repository.dart';
import 'package:mandi_khata_app/features/audit/domain/audit_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audit_providers.g.dart';

@Riverpod(keepAlive: true)
Future<AuditRepository> auditRepository(Ref ref) async =>
    AuditRepository(await ref.watch(powerSyncDatabaseProvider.future));

/// Audit entries of the active business for [filter], newest first, at most
/// [limit]. Live.
@riverpod
Stream<List<AuditEntry>> auditEntries(
  Ref ref,
  AuditFilter filter,
  int limit,
) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(auditRepositoryProvider.future);
  yield* repo.watch(tenantId, filter, limit: limit);
}

/// People who wrote to the log, for the user filter.
@riverpod
Stream<List<({String id, String name})>> auditWriters(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final repo = await ref.watch(auditRepositoryProvider.future);
  yield* repo.watchWriters(tenantId);
}
