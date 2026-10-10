import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/imports/data/import_batches_repository.dart';
import 'package:mandi_khata_app/features/imports/presentation/imports_providers.dart';
import 'package:mandi_khata_app/features/opening_balances/presentation/opening_balances_screen.dart';
import 'package:mandi_khata_app/features/products/presentation/products_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class ImportRoutes {
  static const hub = '/imports';
  static const products = '/imports/products';
}

/// Everything you can bring in from another system, and the list of past
/// imports with a rollback for the owner (step 6.5).
class ImportsHubScreen extends ConsumerWidget {
  const ImportsHubScreen({super.key});

  Future<void> _rollback(
    BuildContext context,
    WidgetRef ref,
    ImportBatch b,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.importRollbackTitle),
        content: Text(l10n.importRollbackBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            key: const ValueKey('rollback-confirm'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(l10n.importRollback),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final r = await ref.read(importActionsProvider).rollback(b.id);
    if (!context.mounted) return;
    MkToast.show(context, switch (r) {
      RolledBack() => l10n.importRolledBack(
        r.entries,
        r.parties + r.products,
        r.kept,
      ),
      RollbackRefused(:final reason) => switch (reason) {
        RollbackRefusal.notOwner => l10n.backupOwnerOnly,
        RollbackRefusal.notFound => l10n.importRollbackNotFound,
        RollbackRefusal.alreadyRolledBack => l10n.importRollbackDone,
        RollbackRefusal.lockedYear => l10n.importRollbackLocked,
      },
    }, tone: r is RolledBack ? MkToastTone.success : MkToastTone.error);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isOwner =
        ref.watch(activeMembershipProvider)?.role == MemberRole.owner;
    final batches = ref.watch(importBatchesProvider).value ?? const [];

    Widget link(String key, IconData icon, String title, String route) =>
        MkCard(
          padding: EdgeInsets.zero,
          onTap: () => context.go(route),
          child: ListTile(
            key: ValueKey(key),
            leading: Icon(icon),
            title: Text(title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(route),
          ),
        );

    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.importHubTitle,
            actions: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.arrow_back),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(MkSpacing.lg),
              children: [
                link(
                  'import-balances',
                  Icons.account_balance_wallet_outlined,
                  l10n.importHubBalances,
                  OpeningBalanceRoutes.import,
                ),
                const SizedBox(height: MkSpacing.sm),
                link(
                  'import-products',
                  Icons.inventory_2_outlined,
                  l10n.importHubProducts,
                  ImportRoutes.products,
                ),
                const SizedBox(height: MkSpacing.sm),
                link(
                  'import-stock',
                  Icons.warehouse_outlined,
                  l10n.importHubStock,
                  ProductRoutes.import,
                ),
                const SizedBox(height: MkSpacing.xl),
                Text(
                  l10n.importPast,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: MkSpacing.sm),
                if (batches.isEmpty) Text(l10n.importPastEmpty),
                for (final b in batches)
                  MkCard(
                    key: ValueKey('batch-${b.id}'),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(switch (b.kind) {
                                ImportKind.openingBalances =>
                                  b.source == 'tally'
                                      ? l10n.importKindTally
                                      : l10n.importHubBalances,
                                ImportKind.products => l10n.importHubProducts,
                              }, style: Theme.of(context).textTheme.titleSmall),
                              Text(
                                [
                                  l10n.importRows(b.rows),
                                  ?b.fileName,
                                  if (b.importedAt != null)
                                    AppFormat.dateTime(context, b.importedAt!),
                                ].join(' · '),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (b.rolledBack)
                                Text(
                                  l10n.importRolledBackTag,
                                  key: ValueKey('rolled-${b.id}'),
                                ),
                            ],
                          ),
                        ),
                        if (isOwner && !b.rolledBack)
                          TextButton.icon(
                            key: ValueKey('rollback-${b.id}'),
                            onPressed: () => _rollback(context, ref, b),
                            icon: const Icon(Icons.undo),
                            label: Text(l10n.importRollback),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
