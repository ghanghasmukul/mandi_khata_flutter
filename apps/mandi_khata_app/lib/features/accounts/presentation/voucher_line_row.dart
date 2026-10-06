import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:mandi_khata_app/features/accounts/presentation/account_picker.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One editable line of the voucher form. Owns its controllers and focus
/// nodes; [dispose] them with the line.
class VoucherLineState {
  VoucherLineState(this.side, {ChartEntry? account, Money? amount})
    : account = account,
      accountText = TextEditingController(text: account?.label ?? ''),
      amountText = TextEditingController(
        text: amount == null
            ? ''
            : amount.format(symbol: false).replaceAll(',', ''),
      );

  DrCr side;
  ChartEntry? account;
  final TextEditingController accountText;
  final TextEditingController amountText;
  final FocusNode accountFocus = FocusNode();
  final FocusNode amountFocus = FocusNode();

  Money? get amount => Money.tryParse(amountText.text);

  set amount(Money? value) => amountText.text = value == null
      ? ''
      : value.format(symbol: false).replaceAll(',', '');

  bool get isEmpty => account == null && (amount?.isZero ?? true);

  void dispose() {
    accountText.dispose();
    amountText.dispose();
    accountFocus.dispose();
    amountFocus.dispose();
  }
}

/// Dr / Cr, account search and amount of one line, in a row.
class VoucherLineRow extends StatelessWidget {
  const VoucherLineRow({
    required this.line,
    required this.index,
    required this.accounts,
    required this.chart,
    required this.onChanged,
    required this.onAccountPicked,
    required this.onAmountSubmitted,
    required this.onRemove,
    super.key,
  });

  final VoucherLineState line;
  final int index;
  final List<ChartEntry> accounts;
  final Chart chart;
  final VoidCallback onChanged;
  final VoidCallback onAccountPicked;
  final VoidCallback onAmountSubmitted;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MkSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<DrCr>(
            key: ValueKey('line-$index-side'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: DrCr.dr, label: Text(l10n.voucherDr)),
              ButtonSegment(value: DrCr.cr, label: Text(l10n.voucherCr)),
            ],
            selected: {line.side},
            onSelectionChanged: (s) {
              line.side = s.first;
              onChanged();
            },
          ),
          const SizedBox(width: MkSpacing.sm),
          Expanded(
            flex: 3,
            child: KeyedSubtree(
              key: ValueKey('line-$index-account'),
              child: AccountPicker(
                accounts: accounts,
                chart: chart,
                controller: line.accountText,
                focusNode: line.accountFocus,
                onPicked: (a) {
                  line.account = a;
                  onAccountPicked();
                },
              ),
            ),
          ),
          const SizedBox(width: MkSpacing.sm),
          Expanded(
            flex: 2,
            child: TextField(
              key: ValueKey('line-$index-amount'),
              controller: line.amountText,
              focusNode: line.amountFocus,
              textAlign: TextAlign.right,
              style: MkText.mono(),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: const [
                MkNumberInputFormatter(MkNumberKind.money),
              ],
              decoration: InputDecoration(
                hintText: l10n.voucherAmount,
                prefixText: '₹ ',
                isDense: true,
              ),
              onChanged: (_) => onChanged(),
              onSubmitted: (_) => onAmountSubmitted(),
            ),
          ),
          IconButton(
            tooltip: l10n.voucherRemoveLine,
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}
