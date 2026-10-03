import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/dashboard/domain/dashboard.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Bar chart of the arhat earned on each of the last ten days.
class EarnedChartCard extends ConsumerWidget {
  const EarnedChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final days = ref.watch(earnedDaysProvider).value ?? const [];
    final peak = days.fold<int>(
      0,
      (m, d) => d.amount.paise > m ? d.amount.paise : m,
    );
    return MkCard(
      title: l10n.dashChartTitle,
      child: SizedBox(
        height: 190,
        child: peak == 0
            ? Center(
                child: Text(
                  l10n.dashChartEmpty,
                  style: TextStyle(color: tokens.textMuted),
                ),
              )
            : BarChart(
                BarChartData(
                  // The chart takes rupees as doubles for drawing only; every
                  // figure shown comes from the paise Money values.
                  maxY: peak / 100 * 1.15,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${days[value.toInt()].date.day}',
                            style: TextStyle(
                              fontSize: 11,
                              color: tokens.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, _, rod, _) {
                        final d = days[group.x];
                        return BarTooltipItem(
                          '${AppFormat.ledgerDate(context, d.date)}\n'
                          '${d.amount.format()}',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < days.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: days[i].amount.paise / 100,
                            width: 16,
                            color: i == days.length - 1
                                ? MkColors.gold
                                : MkColors.brand,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// This season's sales by crop: a share bar per crop, biggest first.
class CropMixCard extends ConsumerWidget {
  const CropMixCard({super.key});

  /// Crops listed before the rest are folded into one "other" row.
  static const _shown = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final today = ref.watch(todayProvider).value;
    final crops = ref.watch(cropMixProvider).value ?? const [];
    final total = crops.fold<int>(0, (s, c) => s + c.gross.paise);
    final year = today == null ? '' : FinancialYear.containing(today).label;
    return MkCard(
      title: l10n.dashCropMixTitle(year),
      child: crops.isEmpty
          ? Text(
              l10n.dashCropMixEmpty,
              style: TextStyle(color: tokens.textMuted),
            )
          : Column(
              children: [
                for (final c in crops.take(_shown))
                  _CropRow(
                    name: c.nameIn(language),
                    sub: l10n.dashCropMixLots(c.lots),
                    amount: c.gross,
                    share: total == 0 ? 0 : c.gross.paise / total,
                  ),
              ],
            ),
    );
  }
}

class _CropRow extends StatelessWidget {
  const _CropRow({
    required this.name,
    required this.sub,
    required this.amount,
    required this.share,
  });

  final String name;
  final String sub;
  final Money amount;
  final double share;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
              Text(
                sub,
                style: TextStyle(fontSize: 11.5, color: tokens.textMuted),
              ),
              const SizedBox(width: MkSpacing.md),
              Text(amount.short(), style: MkText.mono()),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(MkRadius.pill),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 6,
              color: MkColors.brand,
              backgroundColor: tokens.border2,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Where the money is": farmers' payable against receivable, and what other
/// parties owe us. All from the khata.
class MoneyCard extends ConsumerWidget {
  const MoneyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = ref.watch(moneyPositionProvider).value ?? MoneyPosition.empty;
    final rows = [
      (l10n.dashFarmersPayable, p.farmersPayable, MkColors.jama),
      (l10n.dashFarmersReceivable, p.farmersReceivable, MkColors.udhaar),
      (l10n.dashOthersReceivable, p.othersReceivable, MkColors.udhaar),
    ];
    final peak = rows.fold<int>(0, (m, r) => r.$2.paise > m ? r.$2.paise : m);
    final tokens = MkTokens.of(context);
    return MkCard(
      title: l10n.dashMoneyTitle,
      child: Column(
        children: [
          for (final (label, amount, color) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(label)),
                      Text(amount.short(), style: MkText.mono(color: color)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(MkRadius.pill),
                    child: LinearProgressIndicator(
                      value: peak == 0 ? 0 : amount.paise / peak,
                      minHeight: 6,
                      color: color,
                      backgroundColor: tokens.border2,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
