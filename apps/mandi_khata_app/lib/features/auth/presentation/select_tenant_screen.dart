import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/device_registrar.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/auth/presentation/sign_out_flow.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Picks the business to work in. Memberships come from the local database,
/// so after the first sync this works offline. With a single business it is
/// picked automatically.
class SelectTenantScreen extends ConsumerStatefulWidget {
  const SelectTenantScreen({super.key});

  @override
  ConsumerState<SelectTenantScreen> createState() => _SelectTenantScreenState();
}

class _SelectTenantScreenState extends ConsumerState<SelectTenantScreen> {
  String? _busyTenant;
  String? _error;
  bool _autoPicked = false;

  Future<void> _select(Membership m) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busyTenant = m.tenantId;
      _error = null;
    });
    try {
      await ref.read(activeTenantProvider.notifier).select(m.tenantId);
    } on DeviceRegistrationException catch (e) {
      if (mounted) {
        setState(
          () => _error = e.offline
              ? l10n.deviceSetupOffline(m.tenantName)
              : l10n.deviceSetupFailed(m.tenantName),
        );
      }
    } finally {
      if (mounted) setState(() => _busyTenant = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final memberships = ref.watch(myMembershipsProvider).value;
    final synced = ref.watch(hasSyncedProvider);

    if (memberships != null && memberships.length == 1 && !_autoPicked) {
      _autoPicked = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _select(memberships.single),
      );
    }

    final Widget body;
    if (memberships == null || (memberships.isEmpty && !synced)) {
      body = syncConfigured
          ? _Message(
              text: l10n.tenantPickerLoading,
              leading: const CircularProgressIndicator(),
            )
          : _Message(text: l10n.tenantPickerNoSync);
    } else if (memberships.isEmpty) {
      body = MkEmptyState(
        icon: Icons.storefront_outlined,
        title: l10n.tenantPickerEmptyTitle,
        message: l10n.tenantPickerEmptyBody,
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final m in memberships)
            Padding(
              padding: const EdgeInsets.only(bottom: MkSpacing.sm),
              child: _TenantTile(
                membership: m,
                busy: _busyTenant == m.tenantId,
                onTap: _busyTenant == null ? () => _select(m) : null,
              ),
            ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      );
    }

    return AuthLayout(
      title: l10n.tenantPickerTitle,
      subtitle: l10n.tenantPickerSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          body,
          const SizedBox(height: MkSpacing.xl),
          Center(
            child: MkButton(
              label: l10n.accountSignOut,
              icon: Icons.logout,
              variant: MkButtonVariant.ghost,
              onPressed: () => confirmAndSignOut(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _TenantTile extends StatelessWidget {
  const _TenantTile({
    required this.membership,
    required this.busy,
    required this.onTap,
  });

  final Membership membership;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return MkCard(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            const Icon(Icons.storefront_outlined),
            const SizedBox(width: MkSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    membership.tenantName,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (membership.mandiName != null)
                    Text(
                      membership.mandiName!,
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(width: MkSpacing.sm),
            if (busy)
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              MkRoleChip(label: l10n.roleName(membership.role)),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.leading});

  final String text;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(height: MkSpacing.lg),
        ],
        Text(text, textAlign: TextAlign.center),
      ],
    );
  }
}
