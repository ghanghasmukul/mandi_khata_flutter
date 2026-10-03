import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/auth/presentation/sign_out_flow.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Shown instead of the app once the owner has revoked this device.
class DeviceRevokedScreen extends ConsumerWidget {
  const DeviceRevokedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AuthLayout(
      title: l10n.deviceRevokedTitle,
      subtitle: l10n.deviceRevokedBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MkButton(
            key: const ValueKey('device-setup-again'),
            label: l10n.deviceRevokedSetupAgain,
            icon: Icons.phonelink_setup,
            onPressed: () =>
                ref.read(activeTenantProvider.notifier).forgetDevice(),
          ),
          const SizedBox(height: MkSpacing.sm),
          MkButton(
            label: l10n.accountSignOut,
            icon: Icons.logout,
            variant: MkButtonVariant.ghost,
            onPressed: () => confirmAndSignOut(context, ref),
          ),
        ],
      ),
    );
  }
}
