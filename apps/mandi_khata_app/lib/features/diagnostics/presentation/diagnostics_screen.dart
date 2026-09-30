import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/db/database_providers.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/core/sync/sync_error_actions.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'diagnostics_screen.g.dart';

/// Size of the local database file in bytes (works on web too).
@riverpod
Future<int> databaseSize(Ref ref) async {
  final db = await ref.watch(powerSyncDatabaseProvider.future);
  final row = await db.get(
    'SELECT (SELECT page_count FROM pragma_page_count()) * '
    '(SELECT page_size FROM pragma_page_size()) AS bytes',
  );
  return row['bytes']! as int;
}

@riverpod
Future<SyncErrorActions> syncErrorActions(Ref ref) async =>
    SyncErrorActions(await ref.watch(powerSyncDatabaseProvider.future));

/// `1536` → `1.5 KB`. Western digits whatever the language.
String formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return unit == 0
      ? '$bytes B'
      : '${value.toStringAsFixed(value < 10 ? 1 : 0)} ${units[unit]}';
}

/// Owner-only health page: database size, upload queue, last sync and the
/// changes the server rejected, with retry / discard.
class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final member = ref.watch(activeMembershipProvider);
    final isOwner = member?.role == MemberRole.owner;
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.diagnosticsTitle,
            subtitle: member?.tenantName,
            actions: [
              const SyncStatusChip(),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => context.go(GateRoutes.home),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Expanded(
            child: !isOwner
                ? Center(child: Text(l10n.diagnosticsOwnerOnly))
                : Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: ListView(
                        padding: const EdgeInsets.all(MkSpacing.lg),
                        children: const [
                          _StatusCard(),
                          SizedBox(height: MkSpacing.lg),
                          _RejectedCard(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends ConsumerWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(syncStatusProvider).value;
    final queued = ref.watch(uploadQueueCountProvider).value;
    final size = ref.watch(databaseSizeProvider).value;
    final device = ref.watch(activeDeviceProvider);
    final lastSync = status?.lastSyncedAt;

    Widget line(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: MkSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: MkText.mono()),
        ],
      ),
    );

    return MkCard(
      title: l10n.diagnosticsDatabase,
      trailing: IconButton(
        tooltip: l10n.diagnosticsRefresh,
        onPressed: () => ref.invalidate(databaseSizeProvider),
        icon: const Icon(Icons.refresh),
      ),
      child: Column(
        children: [
          line(l10n.diagnosticsDeviceCode, device?.code ?? '—'),
          line(
            l10n.diagnosticsConnection,
            status?.connected ?? false
                ? l10n.diagnosticsOnline
                : l10n.diagnosticsOffline,
          ),
          line(
            l10n.diagnosticsLastSync,
            lastSync == null
                ? l10n.diagnosticsNever
                : AppFormat.dateTime(context, lastSync),
          ),
          line(l10n.diagnosticsQueued, queued?.toString() ?? '—'),
          line(l10n.diagnosticsDbSize, size == null ? '—' : formatBytes(size)),
        ],
      ),
    );
  }
}

class _RejectedCard extends ConsumerWidget {
  const _RejectedCard();

  Future<void> _retry(BuildContext context, WidgetRef ref, String id) async {
    final l10n = AppLocalizations.of(context);
    final actions = await ref.read(syncErrorActionsProvider.future);
    final result = await actions.retry(id);
    if (!context.mounted) return;
    MkToast.show(
      context,
      result == RetryResult.requeued
          ? l10n.diagnosticsRequeued
          : l10n.diagnosticsNotRetryable,
      tone: result == RetryResult.requeued
          ? MkToastTone.success
          : MkToastTone.error,
    );
  }

  Future<void> _discard(WidgetRef ref, String id) async {
    final actions = await ref.read(syncErrorActionsProvider.future);
    await actions.discard(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final errors = ref.watch(syncErrorsProvider).value ?? const [];
    return MkCard(
      title: l10n.diagnosticsRejected,
      child: errors.isEmpty
          ? Text(l10n.diagnosticsNoRejected)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final e in errors)
                  Padding(
                    padding: const EdgeInsets.only(bottom: MkSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            e.table,
                            e.op,
                            e.code ?? '—',
                            if (e.at != null)
                              AppFormat.dateTime(context, e.at!),
                          ].join(' · '),
                          style: MkText.mono(
                            size: 11.5,
                            color: tokens.textMuted,
                          ),
                        ),
                        Text(e.message),
                        Wrap(
                          spacing: MkSpacing.sm,
                          children: [
                            MkButton(
                              label: l10n.diagnosticsRetry,
                              icon: Icons.replay,
                              variant: MkButtonVariant.secondary,
                              onPressed: () => _retry(context, ref, e.id),
                            ),
                            MkButton(
                              label: l10n.diagnosticsDiscard,
                              icon: Icons.delete_outline,
                              variant: MkButtonVariant.ghost,
                              onPressed: () => _discard(ref, e.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
