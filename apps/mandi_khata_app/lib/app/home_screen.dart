import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mandi_khata_app/core/auth/app_lock/app_lock.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/auth/presentation/sign_out_flow.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Placeholder start screen until the dashboard (step 1.6) exists: shows the
/// active business, this device's code and the account menu.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final membership = ref.watch(activeMembershipProvider);
    final device = ref.watch(activeDeviceProvider);
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: membership?.tenantName ?? 'Mandi Khata',
            subtitle: membership?.mandiName,
            roleLabel: membership == null
                ? null
                : l10n.roleName(membership.role),
            actions: const [SyncStatusChip(), _AccountMenu()],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.homePlaceholder, style: theme.textTheme.bodyLarge),
                  if (device != null) ...[
                    const SizedBox(height: MkSpacing.sm),
                    Text(
                      l10n.homeDeviceCode(device.code),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  // Developer-only entry points; the routes do not exist in
                  // release builds.
                  if (!kReleaseMode) ...[
                    const SizedBox(height: MkSpacing.xxl),
                    MkButton(
                      label: 'Design gallery',
                      variant: MkButtonVariant.secondary,
                      icon: Icons.palette_outlined,
                      onPressed: () => context.go(AppRoutes.gallery),
                    ),
                    const SizedBox(height: MkSpacing.sm),
                    MkButton(
                      label: 'Sync lab',
                      variant: MkButtonVariant.secondary,
                      icon: Icons.sync,
                      onPressed: () => context.go(AppRoutes.sync),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _AccountAction { switchBusiness, lockNow, setPin, removePin, signOut }

class _AccountMenu extends ConsumerWidget {
  const _AccountMenu();

  Future<void> _onSelected(
    BuildContext context,
    WidgetRef ref,
    _AccountAction action,
  ) async {
    switch (action) {
      case _AccountAction.switchBusiness:
        await ref.read(activeTenantProvider.notifier).clear();
      case _AccountAction.lockNow:
        ref.read(appLockProvider.notifier).lockNow();
      case _AccountAction.setPin:
        context.go(AppRoutes.setPin);
      case _AccountAction.removePin:
        await ref.read(appLockProvider.notifier).removePin();
      case _AccountAction.signOut:
        await confirmAndSignOut(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lock = ref.watch(appLockProvider);
    PopupMenuItem<_AccountAction> item(
      _AccountAction value,
      IconData icon,
      String label,
    ) => PopupMenuItem(
      value: value,
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        contentPadding: EdgeInsets.zero,
      ),
    );

    return PopupMenuButton<_AccountAction>(
      tooltip: l10n.accountMenu,
      icon: const Icon(Icons.account_circle_outlined),
      onSelected: (a) => _onSelected(context, ref, a),
      itemBuilder: (_) => [
        item(
          _AccountAction.switchBusiness,
          Icons.swap_horiz,
          l10n.accountSwitchBusiness,
        ),
        if (lock.supported) ...[
          if (lock.hasPin)
            item(
              _AccountAction.lockNow,
              Icons.lock_outline,
              l10n.accountLockNow,
            ),
          item(
            _AccountAction.setPin,
            Icons.pin_outlined,
            lock.hasPin ? l10n.accountChangePin : l10n.accountSetPin,
          ),
          if (lock.hasPin)
            item(
              _AccountAction.removePin,
              Icons.lock_open_outlined,
              l10n.accountRemovePin,
            ),
        ],
        item(_AccountAction.signOut, Icons.logout, l10n.accountSignOut),
      ],
    );
  }
}
