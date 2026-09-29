import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mk_ui/src/theme.dart';
import 'package:mk_ui/src/tokens.dart';

/// How [MkMoneyText] colours an amount.
enum MkMoneyTone {
  /// Default text colour.
  plain,

  /// Green: credit to the party, we owe them.
  jama,

  /// Red: debit to the party, they owe us.
  udhaar,

  /// A khata balance: positive is jama, negative is udhaar. The amount is
  /// shown without a sign — the colour carries the side.
  balance,
}

/// Formats and styles an amount of money in the mono font.
class MkMoneyText extends StatelessWidget {
  const MkMoneyText(
    this.amount, {
    super.key,
    this.tone = MkMoneyTone.plain,
    this.compact = false,
    this.paise = PaiseDisplay.auto,
    this.size = 13,
    this.weight = FontWeight.w600,
    this.textAlign,
  });

  /// A khata balance (Σ jama − Σ udhaar), coloured by side.
  const MkMoneyText.balance(
    this.amount, {
    super.key,
    this.compact = false,
    this.paise = PaiseDisplay.auto,
    this.size = 13,
    this.weight = FontWeight.w600,
    this.textAlign,
  }) : tone = MkMoneyTone.balance;

  final Money amount;
  final MkMoneyTone tone;

  /// Lakh / crore form (`₹13.28 L`) instead of the full amount.
  final bool compact;
  final PaiseDisplay paise;
  final double size;
  final FontWeight weight;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final shown = tone == MkMoneyTone.balance ? amount.abs() : amount;
    final color = switch (tone) {
      MkMoneyTone.plain => null,
      MkMoneyTone.jama => tokens.jama,
      MkMoneyTone.udhaar => tokens.udhaar,
      MkMoneyTone.balance =>
        amount.isPositive
            ? tokens.jama
            : amount.isNegative
            ? tokens.udhaar
            : tokens.textMuted,
    };
    return Text(
      compact ? shown.short() : shown.format(paise: paise),
      maxLines: 1,
      softWrap: false,
      textAlign: textAlign,
      style: MkText.mono(size: size, weight: weight, color: color),
    );
  }
}

/// A pill showing a khata balance and its side, e.g. `₹12,400 · Udhaar`.
class MkBalanceChip extends StatelessWidget {
  const MkBalanceChip({
    required this.balance,
    required this.jamaLabel,
    required this.udhaarLabel,
    super.key,
    this.settledLabel,
    this.compact = false,
  });

  /// Σ jama − Σ udhaar for the party.
  final Money balance;

  /// Localised side labels ("Jama", "Udhaar", and "Settled" for zero).
  final String jamaLabel;
  final String udhaarLabel;
  final String? settledLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final (fg, bg, label) = balance.isPositive
        ? (tokens.jama, tokens.jamaTint, jamaLabel)
        : balance.isNegative
        ? (tokens.udhaar, tokens.udhaarTint, udhaarLabel)
        : (tokens.textMuted, tokens.field, settledLabel);
    final amount = balance.abs();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(MkRadius.pill),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: compact ? amount.short() : amount.format(),
              style: MkText.mono(size: 12, weight: FontWeight.w600, color: fg),
            ),
            if (label != null)
              TextSpan(
                text: ' · $label',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
          ],
        ),
        maxLines: 1,
      ),
    );
  }
}
