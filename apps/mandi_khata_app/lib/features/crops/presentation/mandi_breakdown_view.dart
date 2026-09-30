import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Gross, every charge with who pays it, net to the farmer and the buyer's
/// total. Used for the crop example and the lot entry screen.
class MandiBreakdownView extends StatelessWidget {
  const MandiBreakdownView({required this.breakdown, super.key});

  final MandiBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final muted = TextStyle(fontSize: 12, color: tokens.textMuted);
    final b = breakdown;

    Widget row(
      String label,
      Money amount, {
      String? note,
      bool strong = false,
      bool deduct = false,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: label,
                style: strong
                    ? const TextStyle(fontWeight: FontWeight.w600)
                    : null,
                children: [
                  if (note != null) TextSpan(text: '  $note', style: muted),
                ],
              ),
            ),
          ),
          MkMoneyText(
            deduct ? -amount : amount,
            weight: strong ? FontWeight.w700 : FontWeight.w500,
            size: strong ? 14 : 13,
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row(l10n.mandiGross, b.gross, strong: true),
        const Divider(),
        for (final line in b.lines)
          row(
            line.name ?? l10n.mandiCharge(line.charge),
            line.amount,
            note:
                line.charge == MandiCharge.commission &&
                    line.payer == ChargePayer.arhtiya
                ? l10n.mandiWaived
                : l10n.mandiPaidBy(l10n.chargePayer(line.payer)),
            deduct: line.payer == ChargePayer.farmer,
          ),
        const Divider(),
        row(l10n.mandiNetToFarmer, b.netToFarmer, strong: true),
        row(l10n.mandiBuyerTotal, b.buyerTotal),
      ],
    );
  }
}
