import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'party_options.g.dart';

/// A party to pick in the settings scope selector.
typedef PartyOption = ({String id, String name, String? village});

/// Active parties of the active business, by name. The full parties
/// repository arrives with the parties screen (step 0.8).
@riverpod
Stream<List<PartyOption>> partyOptions(Ref ref) async* {
  final tenantId = ref.watch(activeTenantProvider);
  if (tenantId == null) {
    yield const [];
    return;
  }
  final db = await ref.watch(powerSyncDatabaseProvider.future);
  yield* db
      .watch(
        'SELECT id, name, village FROM parties '
        'WHERE tenant_id = ? AND deleted_at IS NULL '
        'ORDER BY name COLLATE NOCASE',
        parameters: [tenantId],
        triggerOnTables: const {'parties'},
      )
      .map(
        (rows) => [
          for (final r in rows)
            (
              id: r['id'] as String,
              name: r['name'] as String,
              village: r['village'] as String?,
            ),
        ],
      );
}
