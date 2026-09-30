import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Allows only what can become a weight in qtl (3 decimals).
class QtlInputFormatter extends TextInputFormatter {
  const QtlInputFormatter();

  static final _pattern = RegExp(r'^\d{0,6}(\.\d{0,3})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => _pattern.hasMatch(newValue.text) ? newValue : oldValue;
}

/// Active crops of the business (plus [cropId] if it was switched off),
/// in the user's language. Type to filter, ↑ / ↓ and Enter to pick.
class CropSelector extends ConsumerWidget {
  const CropSelector({
    required this.cropId,
    required this.onSelected,
    super.key,
    this.focusNode,
    this.errorText,
    this.enabled = true,
  });

  final String? cropId;
  final ValueChanged<Crop> onSelected;
  final FocusNode? focusNode;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final all = ref.watch(cropListProvider(includeInactive: true)).value;
    final crops = [
      for (final c in all ?? const <Crop>[])
        if (c.isActive || c.id == cropId) c,
    ];
    return LayoutBuilder(
      builder: (context, constraints) => DropdownMenu<String>(
        key: ValueKey('crop-$cropId-${crops.length}'),
        focusNode: focusNode,
        enabled: enabled,
        width: constraints.maxWidth,
        label: Text(l10n.lotCrop),
        errorText: errorText,
        initialSelection: cropId,
        enableFilter: true,
        requestFocusOnTap: true,
        menuHeight: 320,
        dropdownMenuEntries: [
          for (final c in crops)
            DropdownMenuEntry(value: c.id, label: c.nameIn(lang)),
        ],
        onSelected: (id) {
          for (final c in crops) {
            if (c.id == id) onSelected(c);
          }
        },
      ),
    );
  }
}

/// The business date of a lot; opens a date picker.
class LotDateField extends StatelessWidget {
  const LotDateField({
    required this.date,
    required this.onChanged,
    super.key,
    this.enabled = true,
  });

  final LedgerDate date;
  final ValueChanged<LedgerDate> onChanged;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final initial = DateTime(date.year, date.month, date.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) onChanged(LedgerDate.fromDateTime(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkButton(
      label: '${l10n.lotDate}: ${AppFormat.ledgerDate(context, date)}',
      variant: MkButtonVariant.secondary,
      icon: Icons.event,
      onPressed: enabled ? () => _pick(context) : null,
    );
  }
}

/// Label + value pair in the lot detail and wizard summary.
class LotInfoRow extends StatelessWidget {
  const LotInfoRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(color: MkTokens.of(context).textMuted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: muted)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
