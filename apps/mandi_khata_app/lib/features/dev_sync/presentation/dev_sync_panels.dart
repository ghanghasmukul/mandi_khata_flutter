// Developer-only panels for the sync lab; text is not localised on purpose.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:powersync/powersync.dart' show PowerSyncDatabase;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SyncControlsPanel extends ConsumerWidget {
  const SyncControlsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value;
    final queued = ref.watch(uploadQueueCountProvider).value ?? 0;
    final controller = ref.read(syncControllerProvider.notifier);
    final mono = MkText.mono(size: 12);
    return MkCard(
      title: 'Sync',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: MkSpacing.sm,
        children: [
          Text(
            'connected: ${status?.connected} · connecting: '
            '${status?.connecting} · queued: $queued',
            style: mono,
          ),
          Text(
            'last synced: ${status?.lastSyncedAt?.toLocal() ?? '—'}',
            style: mono,
          ),
          if (status?.anyError != null)
            Text('error: ${status!.anyError}', style: mono),
          Wrap(
            spacing: MkSpacing.md,
            children: [
              MkButton(
                label: 'Go offline',
                variant: MkButtonVariant.secondary,
                onPressed: controller.pause,
              ),
              MkButton(label: 'Go online', onPressed: controller.resume),
            ],
          ),
        ],
      ),
    );
  }
}

/// Memberships and parties as the local database sees them.
class LocalDataPanel extends ConsumerWidget {
  const LocalDataPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(powerSyncDatabaseProvider).value;
    if (db == null) return const SizedBox.shrink();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return StreamBuilder<List<Map<String, Object?>>>(
      stream: db
          .watch(
            'SELECT m.tenant_id, t.name, m.role FROM tenant_members m '
            'LEFT JOIN tenants t ON t.id = m.tenant_id '
            'WHERE m.user_id = ? AND m.is_active = 1',
            parameters: [userId],
          )
          .map(_rows),
      builder: (context, snapshot) {
        final memberships = snapshot.data ?? const [];
        if (memberships.isEmpty) {
          return const MkCard(
            child: MkEmptyState(
              title: 'No businesses on this device yet',
              message: 'Sign in, go online and wait for the first sync.',
            ),
          );
        }
        final tenantId = memberships.first['tenant_id']! as String;
        return MkCard(
          title:
              '${memberships.first['name']} · '
              '${memberships.first['role']}',
          trailing: MkButton(
            label: 'Add test party',
            icon: Icons.add,
            onPressed: () => _addTestParty(db, tenantId, userId!),
          ),
          child: _PartyList(db: db, tenantId: tenantId),
        );
      },
    );
  }

  /// Party + role + audit row in one local transaction, like the real
  /// repository will (step 0.8).
  Future<void> _addTestParty(
    PowerSyncDatabase db,
    String tenantId,
    String userId,
  ) async {
    const uuid = Uuid();
    final partyId = uuid.v4();
    final code = 'T-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final now = DateTime.now().toUtc().toIso8601String();
    await db.writeTransaction((tx) async {
      await tx.execute(
        'INSERT INTO parties (id, tenant_id, code, name, village, created_by, '
        'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          partyId,
          tenantId,
          code,
          'Test farmer $code',
          'Sync lab',
          userId,
          now,
          now,
        ],
      );
      await tx.execute(
        'INSERT INTO party_roles (id, tenant_id, party_id, role, created_by, '
        'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [uuid.v4(), tenantId, partyId, 'farmer', userId, now, now],
      );
      await tx.execute(
        'INSERT INTO audit_log (id, tenant_id, table_name, row_id, action, '
        'after, user_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          uuid.v4(),
          tenantId,
          'parties',
          partyId,
          'insert',
          jsonEncode({'code': code}),
          userId,
          now,
        ],
      );
    });
  }
}

class _PartyList extends StatelessWidget {
  const _PartyList({required this.db, required this.tenantId});

  final PowerSyncDatabase db;
  final String tenantId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, Object?>>>(
      stream: db
          .watch(
            'SELECT code, name, village FROM parties '
            'WHERE tenant_id = ? AND deleted_at IS NULL '
            'ORDER BY created_at DESC LIMIT 15',
            parameters: [tenantId],
          )
          .map(_rows),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('${r['code']}  ${r['name']} · ${r['village']}'),
              ),
          ],
        );
      },
    );
  }
}

List<Map<String, Object?>> _rows(Iterable<Map<String, Object?>> result) => [
  for (final row in result) Map.of(row),
];
