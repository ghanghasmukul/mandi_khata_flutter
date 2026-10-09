import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/subscription/subscription_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/subscription/presentation/billing_routes.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The text of a lifecycle state, for the banner and the billing screen.
String lifecycleText(
  AppLocalizations l10n,
  LifecycleState s,
  String languageCode,
) {
  String date(DateTime? d) => d == null
      ? ''
      : (DateFormat.yMMMd(
          languageCode,
        )..useNativeDigits = false).format(d.toLocal());
  return switch (s.reason) {
    LifecycleReason.none => '',
    LifecycleReason.trialRunning => l10n.lcTrialDays(s.daysLeft ?? 0),
    LifecycleReason.trialEnded => l10n.lcTrialEnded,
    LifecycleReason.renewalOverdue => l10n.lcGrace(date(s.endsAt)),
    LifecycleReason.graceEnded => l10n.lcGraceEnded,
    LifecycleReason.lockedByVendor => l10n.lcLockedByVendor,
    LifecycleReason.cancelled => l10n.lcCancelled(s.daysLeft ?? 0),
    LifecycleReason.cancelledExpired => l10n.lcExportOnly,
    LifecycleReason.confirmWithServer => l10n.lcConfirm(s.daysLeft ?? 0),
    LifecycleReason.syncRequired => l10n.lcSyncRequired,
  };
}

/// A strip under the top of every business screen when the subscription
/// needs attention: trial ending, renewal overdue, read-only, or a device
/// that must reach the server.
class LifecycleBanner extends ConsumerWidget {
  const LifecycleBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lifecycleProvider);
    if (!state.needsBanner) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final member = ref.watch(activeMembershipProvider);
    final severe = !state.canWrite;
    final warn =
        state.reason == LifecycleReason.renewalOverdue ||
        state.reason == LifecycleReason.confirmWithServer;
    final color = severe
        ? tokens.udhaar
        : warn
        ? MkColors.gold
        : MkColors.brand;
    final canOpenBilling =
        member?.canIgnoringLock(Permission.adminManage) ?? false;
    return Material(
      color: color.withValues(alpha: 0.14),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MkSpacing.lg,
          vertical: MkSpacing.sm,
        ),
        child: Wrap(
          key: const ValueKey('lifecycle-banner'),
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: MkSpacing.md,
          children: [
            Icon(
              severe ? Icons.lock_outline : Icons.info_outline,
              size: 18,
              color: color,
            ),
            Text(
              lifecycleText(
                l10n,
                state,
                Localizations.localeOf(context).languageCode,
              ),
              style: TextStyle(color: tokens.textBody),
            ),
            if (canOpenBilling)
              TextButton(
                key: const ValueKey('lifecycle-billing'),
                onPressed: () => context.go(BillingRoutes.billing),
                child: Text(l10n.navBilling),
              ),
          ],
        ),
      ),
    );
  }
}
