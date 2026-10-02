import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Below this width a khata line uses two lines instead of columns.
const _columnsFrom = 640.0;

/// Fixed height of a khata line (lists use it as their item extent).
const khataLineHeight = 60.0;

/// One khata line: date, party (day book only), description, udhaar, jama
/// and the running baki. A reversed entry and its reversal are struck
/// through; an edited entry's replacement is tagged.
class KhataLine extends StatelessWidget {
  const KhataLine({
    required this.entry,
    required this.balance,
    required this.struck,
    super.key,
    this.partyName,
    this.onTap,
    this.onPartyTap,
    this.trailing,
  });

  final LedgerEntry entry;

  /// The party's baki after this entry.
  final Money balance;
  final bool struck;

  /// Shown in the day book, where lines of many parties mix.
  final String? partyName;
  final VoidCallback? onTap;
  final VoidCallback? onPartyTap;

  /// Row actions (edit / reverse menu).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = MkTokens.of(context);
    final strike = struck ? TextDecoration.lineThrough : null;
    final muted = struck ? tokens.textMuted : null;
    final isJama = entry.side == Side.jama;

    Widget money(Money? m, MkMoneyTone tone) => m == null
        ? const SizedBox.shrink()
        : DefaultTextStyle.merge(
            style: TextStyle(decoration: strike),
            child: MkMoneyText(
              m,
              tone: struck ? MkMoneyTone.plain : tone,
              textAlign: TextAlign.right,
            ),
          );

    final description = Text.rich(
      TextSpan(
        children: [
          if (partyName != null)
            TextSpan(
              text: '$partyName  ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          TextSpan(text: l10n.entryDescription(entry)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        decoration: strike,
        color: muted,
      ),
    );
    final tags = [
      if (entry.isReversal) l10n.khataTagReversal,
      if (entry.replacesId != null) l10n.khataTagEdited,
      if (struck && !entry.isReversal) l10n.khataTagReversed,
    ];
    final date = Text(
      AppFormat.ledgerDate(context, entry.entryDate),
      style: theme.textTheme.bodySmall?.copyWith(decoration: strike),
    );
    final baki = MkMoneyText.balance(balance, textAlign: TextAlign.right);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: khataLineHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MkSpacing.lg),
          child: LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= _columnsFrom;
              final middle = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(onTap: onPartyTap, child: description),
                  Row(
                    children: [
                      if (!wide) ...[date, const SizedBox(width: MkSpacing.sm)],
                      for (final t in tags)
                        Padding(
                          padding: const EdgeInsets.only(right: MkSpacing.xs),
                          child: Text(
                            t,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: tokens.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
              if (!wide) {
                return Row(
                  children: [
                    Expanded(child: middle),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        money(
                          entry.amount,
                          isJama ? MkMoneyTone.jama : MkMoneyTone.udhaar,
                        ),
                        baki,
                      ],
                    ),
                    ?trailing,
                  ],
                );
              }
              return Row(
                children: [
                  SizedBox(width: 92, child: date),
                  Expanded(child: middle),
                  SizedBox(
                    width: 120,
                    child: money(
                      isJama ? null : entry.amount,
                      MkMoneyTone.udhaar,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: money(
                      isJama ? entry.amount : null,
                      MkMoneyTone.jama,
                    ),
                  ),
                  SizedBox(width: 130, child: baki),
                  SizedBox(width: 48, child: trailing),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Column titles above wide khata lines.
class KhataHeader extends StatelessWidget {
  const KhataHeader({super.key, this.showParty = false});

  final bool showParty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.labelSmall;
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < _columnsFrom) return const SizedBox.shrink();
        Widget right(String t, double w) => SizedBox(
          width: w,
          child: Text(t, style: style, textAlign: TextAlign.right),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MkSpacing.lg,
            vertical: MkSpacing.xs,
          ),
          child: Row(
            children: [
              SizedBox(width: 92, child: Text(l10n.khataColDate, style: style)),
              Expanded(
                child: Text(
                  showParty ? l10n.khataColPartyDetails : l10n.khataColDetails,
                  style: style,
                ),
              ),
              right(l10n.khataColUdhaar, 120),
              right(l10n.khataColJama, 120),
              right(l10n.khataColBaki, 130),
              const SizedBox(width: 48),
            ],
          ),
        );
      },
    );
  }
}

/// "Jama · we owe" / "Udhaar · farmer owes" balance chip.
class KhataBalanceChip extends StatelessWidget {
  const KhataBalanceChip({
    required this.balance,
    super.key,
    this.isFarmer = false,
  });

  final Money balance;
  final bool isFarmer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkBalanceChip(
      balance: balance,
      jamaLabel: l10n.khataBalanceJama,
      udhaarLabel: isFarmer
          ? l10n.khataBalanceUdhaarFarmer
          : l10n.khataBalanceUdhaarParty,
      settledLabel: l10n.khataBalanceSettled,
      compact: true,
    );
  }
}
