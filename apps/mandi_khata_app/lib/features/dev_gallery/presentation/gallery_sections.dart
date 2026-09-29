// Developer-only gallery content; sample text is not localised on purpose.
import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mk_ui/mk_ui.dart';

class GallerySection extends StatelessWidget {
  const GallerySection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: MkSpacing.md),
          child,
        ],
      ),
    );
  }
}

class ColourSwatches extends StatelessWidget {
  const ColourSwatches({super.key});

  static const Map<String, Color> _colours = {
    'brand dark': MkColors.brandDark,
    'brand': MkColors.brand,
    'brand 2': MkColors.brand2,
    'gold': MkColors.gold,
    'gold soft': MkColors.goldSoft,
    'gold text': MkColors.goldText,
    'background': MkColors.background,
    'surface alt': MkColors.surfaceAlt,
    'border': MkColors.border,
    'text': MkColors.textPrimary,
    'muted': MkColors.textMuted,
    'jama': MkColors.jama,
    'udhaar': MkColors.udhaar,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: MkSpacing.md,
      runSpacing: MkSpacing.md,
      children: [
        for (final entry in _colours.entries)
          SizedBox(
            width: 104,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: entry.value,
                    borderRadius: BorderRadius.circular(MkRadius.sm),
                    border: Border.all(color: MkColors.border),
                  ),
                ),
                const SizedBox(height: 4),
                Text(entry.key, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}

class TypeSamples extends StatelessWidget {
  const TypeSamples({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return MkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: MkSpacing.sm,
        children: [
          Text('Gupta Trading Co.', style: t.displaySmall),
          Text('Screen title · titleLarge', style: t.titleLarge),
          Text('Card title · titleMedium', style: t.titleMedium),
          Text(
            'Body text for forms and tables · bodyMedium',
            style: t.bodyMedium,
          ),
          Text('Muted note · bodySmall', style: t.bodySmall),
          Text('मंडी खाता — किसान का हिसाब', style: t.titleMedium),
          Text('ਮੰਡੀ ਖਾਤਾ — ਕਿਸਾਨ ਦਾ ਹਿਸਾਬ', style: t.titleMedium),
          Text('₹1,55,580 · L-445 · R-3008', style: MkText.mono(size: 16)),
        ],
      ),
    );
  }
}

class MoneySamples extends StatelessWidget {
  const MoneySamples({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: MkSpacing.lg,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final tiles = [
              MkStatTile(
                label: 'We owe farmers',
                value: const Money(132800000).short(),
                sub: '41 parties',
                valueColor: tokens.jama,
              ),
              MkStatTile(
                label: 'Others owe us',
                value: const Money(1200000000).short(),
                sub: '17 parties · 3 overdue',
                valueColor: tokens.udhaar,
              ),
              const MkStatTile(
                label: 'Lots today',
                value: '28',
                sub: '1,240 bags',
              ),
              MkStatTile(
                label: 'Arhat today',
                value: const Money(4560000).short(),
                sub: '2.5% commission',
              ),
            ];
            final columns = (c.maxWidth / 200).floor().clamp(1, 4);
            final width = (c.maxWidth - (columns - 1) * 14) / columns;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final t in tiles) SizedBox(width: width, child: t),
              ],
            );
          },
        ),
        const Wrap(
          spacing: MkSpacing.xl,
          runSpacing: MkSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            MkMoneyText(Money(15558000), size: 16),
            MkMoneyText(Money(110959), tone: MkMoneyTone.jama),
            MkMoneyText(Money(240000), tone: MkMoneyTone.udhaar),
            MkMoneyText.balance(Money(-9820000), compact: true),
            MkBalanceChip(
              balance: Money(1250000),
              jamaLabel: 'Jama',
              udhaarLabel: 'Udhaar',
            ),
            MkBalanceChip(
              balance: Money(-240000),
              jamaLabel: 'Jama',
              udhaarLabel: 'Udhaar',
            ),
            MkBalanceChip(
              balance: Money.zero,
              jamaLabel: 'Jama',
              udhaarLabel: 'Udhaar',
              settledLabel: 'Settled',
            ),
          ],
        ),
      ],
    );
  }
}

class ButtonSamples extends StatefulWidget {
  const ButtonSamples({super.key});

  @override
  State<ButtonSamples> createState() => _ButtonSamplesState();
}

class _ButtonSamplesState extends State<ButtonSamples> {
  bool _busy = false;

  Future<void> _save() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: MkSpacing.md,
      runSpacing: MkSpacing.md,
      children: [
        MkButton(label: 'Accept voucher', icon: Icons.check, onPressed: () {}),
        MkButton(
          label: 'Export',
          variant: MkButtonVariant.secondary,
          icon: Icons.download,
          onPressed: () {},
        ),
        MkButton(
          label: 'Cancel',
          variant: MkButtonVariant.ghost,
          onPressed: () {},
        ),
        MkButton(
          label: 'Reverse entry',
          variant: MkButtonVariant.danger,
          onPressed: () {},
        ),
        const MkButton(label: 'Disabled', onPressed: null),
        MkButton(label: 'Save (busy)', busy: _busy, onPressed: _save),
      ],
    );
  }
}
