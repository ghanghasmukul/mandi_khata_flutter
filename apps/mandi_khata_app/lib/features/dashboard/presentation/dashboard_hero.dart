import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_screen.dart';
import 'package:mandi_khata_app/features/dashboard/domain/dashboard.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_providers.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_entry_dialog.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/record_payment_dialog.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Dark hero card: business, date, today in one line and the two big
/// balances ("We owe farmers", "Others owe us").
class DashboardHero extends ConsumerWidget {
  const DashboardHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final membership = ref.watch(activeMembershipProvider);
    final today = ref.watch(todayProvider).value;
    final day = ref.watch(daySummaryProvider).value ?? DaySummary.empty;
    final position =
        ref.watch(moneyPositionProvider).value ?? MoneyPosition.empty;

    final summary = day.lots == 0
        ? l10n.dashHeroNoLots
        : l10n.dashHeroLots(day.lots, day.arhatEarned.short());
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MkColors.brandDark,
        borderRadius: BorderRadius.circular(MkRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MkSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                ?membership?.tenantName,
                if (today != null) AppFormat.ledgerDate(context, today),
              ].join(' · '),
              style: const TextStyle(
                color: MkColors.sidebarMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: MkSpacing.xs),
            Text(
              summary,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: MkSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _HeroTile(
                    label: l10n.dashWeOweFarmers,
                    value: position.farmersPayable.short(),
                    color: MkColors.goldSoft,
                  ),
                ),
                const SizedBox(width: MkSpacing.md),
                Expanded(
                  child: _HeroTile(
                    label: l10n.dashOthersOweUs,
                    value: position.totalReceivable.short(),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTile extends StatelessWidget {
  const _HeroTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(MkRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MkSpacing.lg,
          vertical: MkSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: MkText.caps(MkColors.sidebarMuted),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                style: MkText.mono(
                  size: 24,
                  weight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Add farmer, New arrival, Khata entry, Record payment: each shown only to
/// members who may do it.
class DashboardQuickActions extends ConsumerWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final canParty = ref.watch(canProvider(Permission.partiesManage));
    final canLot = ref.watch(canProvider(Permission.arrivalsManage));
    final canEntry = ref.watch(canProvider(Permission.entriesReverse));
    final canPay = ref.watch(canProvider(Permission.paymentsCreate));
    return Wrap(
      spacing: MkSpacing.sm,
      runSpacing: MkSpacing.sm,
      children: [
        if (canParty)
          MkButton(
            label: l10n.dashActionAddFarmer,
            icon: Icons.person_add_alt_1,
            variant: MkButtonVariant.secondary,
            onPressed: () => context.go(PartyRoutes.create),
          ),
        if (canLot)
          MkButton(
            label: l10n.lotNewTitle,
            icon: Icons.agriculture_outlined,
            onPressed: () => context.go(ArrivalRoutes.create),
          ),
        if (canEntry)
          MkButton(
            label: l10n.khataEntryTitle,
            icon: Icons.edit_note,
            variant: MkButtonVariant.secondary,
            onPressed: () => showKhataEntryDialog(context),
          ),
        if (canPay)
          MkButton(
            label: l10n.paymentRecordTitle,
            icon: Icons.add_card_outlined,
            variant: MkButtonVariant.secondary,
            onPressed: () => showRecordPaymentDialog(context),
          ),
      ],
    );
  }
}
