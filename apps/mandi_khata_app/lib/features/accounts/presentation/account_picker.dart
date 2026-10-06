import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/accounts/domain/chart.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Type-ahead account search for a voucher line. [accounts] come in the
/// order to list them (suggested kinds first). Enter picks the highlighted
/// match and moves on ([onPicked]). The caller owns [controller] and
/// [focusNode] (they live as long as the line).
class AccountPicker extends StatelessWidget {
  const AccountPicker({
    required this.accounts,
    required this.chart,
    required this.onPicked,
    required this.controller,
    required this.focusNode,
    super.key,
  });

  final List<ChartEntry> accounts;
  final Chart chart;
  final ValueChanged<ChartEntry> onPicked;
  final TextEditingController controller;
  final FocusNode focusNode;

  static bool matches(ChartEntry a, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return a.name.toLowerCase().contains(q) ||
        (a.code?.toLowerCase().contains(q) ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RawAutocomplete<ChartEntry>(
      focusNode: focusNode,
      textEditingController: controller,
      displayStringForOption: (a) => a.label,
      optionsBuilder: (value) => [
        for (final a in accounts)
          if (matches(a, value.text)) a,
      ].take(30),
      onSelected: onPicked,
      fieldViewBuilder: (context, controller, node, onSubmit) => TextField(
        controller: controller,
        focusNode: node,
        decoration: InputDecoration(
          hintText: l10n.voucherAccountSearch,
          isDense: true,
        ),
        onSubmitted: (_) => onSubmit(),
      ),
      optionsViewBuilder: (context, onSelect, options) {
        final list = options.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280, maxWidth: 420),
              child: list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(MkSpacing.md),
                      child: Text(l10n.voucherNoAccount),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final a = list[i];
                        final highlighted =
                            AutocompleteHighlightedOption.of(context) == i;
                        return ListTile(
                          dense: true,
                          selected: highlighted,
                          title: Text(a.label),
                          subtitle: Text(chart.groupOf(a)?.name ?? ''),
                          trailing: a.kind == VoucherAccountKind.party
                              ? const Icon(Icons.person_outline, size: 16)
                              : a.kind.isBook
                              ? const Icon(Icons.account_balance, size: 16)
                              : null,
                          onTap: () => onSelect(a),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}
