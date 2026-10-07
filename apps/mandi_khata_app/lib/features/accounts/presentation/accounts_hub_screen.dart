import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_labels.dart';
import 'package:mandi_khata_app/features/accounts/presentation/accounts_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One link of the accounts hub, shown when the member has [permission].
class AccountsHubTile {
  const AccountsHubTile({
    required this.key,
    required this.icon,
    required this.label,
    required this.route,
    required this.permission,
  });

  final String key;
  final IconData icon;
  final String Function(AppLocalizations) label;
  final String route;
  final Permission permission;
}

/// The hub's sections: (title, tiles).
final List<(String Function(AppLocalizations), List<AccountsHubTile>)>
hubSections = [
  (
    (l) => l.acctHubSectionEntry,
    [
      for (final (key, type) in voucherTypeKeys)
        AccountsHubTile(
          key: 'voucher-${type.dbName}',
          icon: Icons.receipt_long_outlined,
          label: (l) => '${key.keyLabel} ${l.voucherTypeName(type)}',
          route: AccountRoutes.newVoucher(type),
          permission: Permission.entriesReverse,
        ),
      AccountsHubTile(
        key: 'day-book',
        icon: Icons.menu_book_outlined,
        label: (l) => l.dayBookAccountsTitle,
        route: AccountRoutes.dayBook,
        permission: Permission.financeView,
      ),
      AccountsHubTile(
        key: 'chart',
        icon: Icons.account_tree_outlined,
        label: (l) => l.chartTitle,
        route: AccountRoutes.chart,
        permission: Permission.financeView,
      ),
    ],
  ),
  (
    (l) => l.acctHubSectionBooks,
    [
      AccountsHubTile(
        key: 'books',
        icon: Icons.fact_check_outlined,
        label: (l) => l.booksTitle,
        route: AccountRoutes.books,
        permission: Permission.entriesReverse,
      ),
    ],
  ),
];

/// The accounts hub (`/accounts`): every phase-3 screen, by permission.
/// F4–F9 open a new voucher of that type.
class AccountsHubScreen extends ConsumerWidget {
  const AccountsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final canVoucher = ref.watch(canProvider(Permission.entriesReverse));
    bool can(Permission p) => ref.watch(canProvider(p));
    return CallbackShortcuts(
      bindings: {
        if (canVoucher)
          for (final (key, type) in voucherTypeKeys)
            SingleActivator(key): () =>
                context.push(AccountRoutes.newVoucher(type)),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go(GateRoutes.home),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(title: l10n.acctHubTitle),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(MkSpacing.lg),
                  children: [
                    Text(l10n.acctHubIntro),
                    for (final (title, tiles) in hubSections)
                      if (tiles.any((t) => can(t.permission))) ...[
                        const SizedBox(height: MkSpacing.lg),
                        Text(
                          title(l10n),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: MkSpacing.sm),
                        Wrap(
                          spacing: MkSpacing.sm,
                          runSpacing: MkSpacing.sm,
                          children: [
                            for (final t in tiles)
                              if (can(t.permission))
                                ActionChip(
                                  key: ValueKey('hub-${t.key}'),
                                  avatar: Icon(t.icon, size: 18),
                                  label: Text(t.label(l10n)),
                                  onPressed: () => context.push(t.route),
                                ),
                          ],
                        ),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
