import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mandi_khata_app/core/auth/app_lock/app_lock.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/auth/presentation/sign_out_flow.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/language_switcher.dart';
import 'package:mk_ui/mk_ui.dart';

/// The account menu: switch business, PIN lock, language, diagnostics,
/// sign out. Opened from the top bar's avatar or the sidebar's user tile.
enum AccountAction {
  switchBusiness,
  language,
  lockNow,
  setPin,
  removePin,
  diagnostics,
  signOut,
}

class AccountMenu extends ConsumerWidget {
  const AccountMenu({super.key, this.child});

  /// A custom button (the sidebar's user tile); an avatar icon when null.
  final Widget? child;

  Future<void> _onSelected(
    BuildContext context,
    WidgetRef ref,
    AccountAction action,
  ) async {
    switch (action) {
      case AccountAction.switchBusiness:
        await ref.read(activeTenantProvider.notifier).clear();
      case AccountAction.language:
        await MkDialog.show<void>(
          context,
          title: AppLocalizations.of(context).accountLanguage,
          content: const Center(child: AppLanguageSwitcher()),
        );
      case AccountAction.diagnostics:
        context.go(AppRoutes.diagnostics);
      case AccountAction.lockNow:
        ref.read(appLockProvider.notifier).lockNow();
      case AccountAction.setPin:
        context.go(AppRoutes.setPin);
      case AccountAction.removePin:
        await ref.read(appLockProvider.notifier).removePin();
      case AccountAction.signOut:
        await confirmAndSignOut(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lock = ref.watch(appLockProvider);
    final isOwner =
        ref.watch(activeMembershipProvider)?.role == MemberRole.owner;
    PopupMenuItem<AccountAction> item(
      AccountAction value,
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

    return PopupMenuButton<AccountAction>(
      tooltip: l10n.accountMenu,
      icon: child == null ? const Icon(Icons.account_circle_outlined) : null,
      position: PopupMenuPosition.under,
      onSelected: (a) => _onSelected(context, ref, a),
      itemBuilder: (_) => [
        item(
          AccountAction.switchBusiness,
          Icons.swap_horiz,
          l10n.accountSwitchBusiness,
        ),
        if (lock.supported) ...[
          if (lock.hasPin)
            item(
              AccountAction.lockNow,
              Icons.lock_outline,
              l10n.accountLockNow,
            ),
          item(
            AccountAction.setPin,
            Icons.pin_outlined,
            lock.hasPin ? l10n.accountChangePin : l10n.accountSetPin,
          ),
          if (lock.hasPin)
            item(
              AccountAction.removePin,
              Icons.lock_open_outlined,
              l10n.accountRemovePin,
            ),
        ],
        item(AccountAction.language, Icons.translate, l10n.accountLanguage),
        if (isOwner)
          item(
            AccountAction.diagnostics,
            Icons.monitor_heart_outlined,
            l10n.accountDiagnostics,
          ),
        item(AccountAction.signOut, Icons.logout, l10n.accountSignOut),
      ],
      child: child,
    );
  }
}
