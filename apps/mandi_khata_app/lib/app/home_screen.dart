import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mandi_khata_app/core/auth/app_lock/app_lock.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/auth/presentation/sign_out_flow.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/language_switcher.dart';
import 'package:mk_ui/mk_ui.dart';

/// The start screen: top bar with the account menu above the dashboard.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final membership = ref.watch(activeMembershipProvider);
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: membership?.tenantName ?? 'Mandi Khata',
            subtitle: membership?.mandiName,
            roleLabel: membership == null
                ? null
                : l10n.roleName(membership.role),
            languages: appLanguages,
            language: Localizations.localeOf(context).languageCode,
            onLanguage: (c) => ref.read(appLanguageProvider.notifier).set(c),
            actions: const [SyncStatusChip(), _AccountMenu()],
          ),
          const Expanded(child: DashboardView()),
        ],
      ),
    );
  }
}

enum _AccountAction {
  switchBusiness,
  language,
  lockNow,
  setPin,
  removePin,
  diagnostics,
  signOut,
}

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
      case _AccountAction.language:
        await MkDialog.show<void>(
          context,
          title: AppLocalizations.of(context).accountLanguage,
          content: const Center(child: AppLanguageSwitcher()),
        );
      case _AccountAction.diagnostics:
        context.go(AppRoutes.diagnostics);
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
    final isOwner =
        ref.watch(activeMembershipProvider)?.role == MemberRole.owner;
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
        item(_AccountAction.language, Icons.translate, l10n.accountLanguage),
        if (isOwner)
          item(
            _AccountAction.diagnostics,
            Icons.monitor_heart_outlined,
            l10n.accountDiagnostics,
          ),
        item(_AccountAction.signOut, Icons.logout, l10n.accountSignOut),
      ],
    );
  }
}
