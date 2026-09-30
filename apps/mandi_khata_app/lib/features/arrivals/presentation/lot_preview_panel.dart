import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_providers.dart';
import 'package:mandi_khata_app/features/crops/presentation/mandi_breakdown_view.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Live calculation next to the lot form: gross, arhat, every charge, net,
/// and what posting will write to the khata — or why it cannot post yet.
class LotPreviewPanel extends StatelessWidget {
  const LotPreviewPanel({
    required this.config,
    required this.farmerId,
    required this.bags,
    required this.qtlMilli,
    required this.rate,
    super.key,
    this.buyerId,
  });

  /// Null until the crop is picked and settings are loaded.
  final MandiConfig? config;
  final String? farmerId;
  final String? buyerId;
  final int bags;
  final int? qtlMilli;
  final Money? rate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final config = this.config;
    final qtl = qtlMilli;
    final rate = this.rate;

    Widget body;
    if (config == null || qtl == null || rate == null || qtl <= 0) {
      body = Text(
        l10n.lotPreviewEmpty,
        style: TextStyle(color: tokens.textMuted),
      );
    } else {
      final breakdown = MandiCharges.calculate(
        LotInput(bags: bags < 0 ? 0 : bags, qtlMilli: qtl, rate: rate),
        config,
      );
      final r = farmerId == null
          ? null
          : LotRules.planPosting(
              farmerId: farmerId!,
              buyerId: buyerId,
              bags: bags,
              qtlMilli: qtl,
              rate: rate,
              config: config,
            );
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MandiBreakdownView(breakdown: breakdown),
          if (r != null && r.problems.isNotEmpty) ...[
            const SizedBox(height: MkSpacing.md),
            for (final p in r.problems)
              Text(
                l10n.lotProblem(p),
                key: ValueKey('preview-problem-${p.name}'),
                style: TextStyle(color: tokens.udhaar),
              ),
          ],
          if (r?.plan case final plan?) ...[
            const SizedBox(height: MkSpacing.md),
            Text(
              l10n.lotPostsTitle,
              style: TextStyle(fontSize: 12, color: tokens.textMuted),
            ),
            _PostingLine(
              label: l10n.lotPostsFarmer,
              amount: plan.farmer.amount,
              tone: MkMoneyTone.jama,
            ),
            if (plan.buyer case final buyer?)
              _PostingLine(
                label: l10n.lotPostsBuyer,
                amount: buyer.amount,
                tone: MkMoneyTone.udhaar,
              ),
          ],
        ],
      );
    }
    return MkCard(title: l10n.lotPreviewTitle, child: body);
  }
}

class _PostingLine extends StatelessWidget {
  const _PostingLine({
    required this.label,
    required this.amount,
    required this.tone,
  });

  final String label;
  final Money amount;
  final MkMoneyTone tone;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        MkMoneyText(amount, tone: tone),
      ],
    ),
  );
}
