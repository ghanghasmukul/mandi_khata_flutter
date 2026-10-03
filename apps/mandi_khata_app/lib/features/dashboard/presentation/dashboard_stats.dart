import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/dashboard/domain/dashboard.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Today's four numbers: lots in (+ weight), arhat earned, paid out, receipts.
class DashboardStats extends ConsumerWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final day = ref.watch(daySummaryProvider).value ?? DaySummary.empty;
    final tiles = [
      MkStatTile(
        label: l10n.dashStatLots,
        value: '${day.lots}',
        sub: l10n.dashStatQtl(Quintals.format(day.qtlMilli)),
      ),
      MkStatTile(
        label: l10n.dashStatEarned,
        value: day.arhatEarned.short(),
        sub: l10n.dashStatEarnedSub,
        valueColor: MkColors.jama,
      ),
      MkStatTile(
        label: l10n.dashStatPaid,
        value: day.paidOut.short(),
        sub: l10n.dashStatPaidSub,
        valueColor: MkColors.udhaar,
      ),
      MkStatTile(
        label: l10n.dashStatReceipts,
        value: day.receipts.short(),
        sub: l10n.dashStatReceiptsSub,
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final columns = box.maxWidth >= 900 ? 4 : 2;
        const gap = MkSpacing.md;
        // A first frame can be 0 wide; never ask for a negative width.
        final width = ((box.maxWidth - gap * (columns - 1)) / columns).clamp(
          0.0,
          double.infinity,
        );
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final t in tiles) SizedBox(width: width, child: t)],
        );
      },
    );
  }
}
