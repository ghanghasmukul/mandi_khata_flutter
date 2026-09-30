import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Saves a value; returns an error message to show, or null on success.
typedef SaveSetting = Future<String?> Function(Object? value);

/// The input for one setting, chosen by its type. Switches and dropdowns
/// save at once; typed numbers save on Enter or the save button.
class SettingEditor extends StatelessWidget {
  const SettingEditor({
    required this.def,
    required this.value,
    required this.enabled,
    required this.onSave,
    super.key,
  });

  final SettingDef def;

  /// The resolved (current) value shown in the input.
  final Object? value;
  final bool enabled;
  final SaveSetting onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (def.type) {
      case SettingType.boolean:
        return Switch(value: value == true, onChanged: enabled ? onSave : null);
      case SettingType.choice:
        return DropdownButton<String>(
          value: value as String?,
          isDense: true,
          onChanged: enabled ? onSave : null,
          items: [
            for (final o in def.options!)
              DropdownMenuItem(
                value: o,
                child: Text(l10n.settingOption(def.key, o)),
              ),
          ],
        );
      case SettingType.integer:
      case SettingType.paise:
      case SettingType.percent:
      case SettingType.decimal:
        return _NumberSettingField(
          def: def,
          value: value,
          enabled: enabled,
          onSave: onSave,
        );
      case SettingType.structured:
        return Text(
          structuredSummary(value),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        );
    }
  }
}

/// One-line text for list / map values (cess, tiers, number series).
String structuredSummary(Object? value) => switch (value) {
  null => '—',
  final List<Object?> list when list.isEmpty => '—',
  final List<Object?> list =>
    list.map((e) => e is Map ? '${e['name']} ${e['pct']}%' : '$e').join(', '),
  final Map<Object?, Object?> map when map.containsKey('prefix') =>
    '${map['prefix']}${map['next']}',
  final Map<Object?, Object?> map =>
    map.entries.map((e) => '${e.key}: ${e.value}').join(', '),
  _ => '$value',
};

class _NumberSettingField extends StatefulWidget {
  const _NumberSettingField({
    required this.def,
    required this.value,
    required this.enabled,
    required this.onSave,
  });

  final SettingDef def;
  final Object? value;
  final bool enabled;
  final SaveSetting onSave;

  @override
  State<_NumberSettingField> createState() => _NumberSettingFieldState();
}

class _NumberSettingFieldState extends State<_NumberSettingField> {
  late final _controller = TextEditingController(text: _format(widget.value));
  String? _error;
  bool _saving = false;

  bool get _isMoney => widget.def.type == SettingType.paise;
  bool get _isDecimal =>
      widget.def.type == SettingType.percent ||
      widget.def.type == SettingType.decimal;

  String _format(Object? v) {
    if (v == null) return '';
    if (_isMoney) {
      return Money(v as int).format(symbol: false).replaceAll(',', '');
    }
    if (_isDecimal) return SettingsSchema.decimalOf(v)?.toString() ?? '';
    return '$v';
  }

  /// Text → stored value, or null if it cannot be read.
  Object? _parse(String text) {
    final t = text.trim();
    if (_isMoney) return Money.tryParse(t)?.paise;
    if (_isDecimal) return Decimal.tryParse(t)?.toString();
    return int.tryParse(t);
  }

  bool get _dirty => _controller.text != _format(widget.value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final parsed = _parse(_controller.text);
    if (parsed == null) {
      setState(() => _error = l10n.settingErrorWrongType);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.onSave(parsed);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: MkTextField(
            controller: _controller,
            enabled: widget.enabled,
            errorText: _error,
            keyboardType: TextInputType.numberWithOptions(
              decimal: _isMoney || _isDecimal,
            ),
            inputFormatters: [
              if (_isMoney)
                const MkNumberInputFormatter(MkNumberKind.money)
              else if (_isDecimal)
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}'))
              else
                FilteringTextInputFormatter.digitsOnly,
            ],
            prefix: _isMoney
                ? const Padding(
                    padding: EdgeInsets.only(left: 12, right: 4),
                    child: Text('₹'),
                  )
                : null,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
          ),
        ),
        if (widget.enabled && _dirty)
          IconButton(
            tooltip: l10n.settingsSave,
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check),
          ),
      ],
    );
  }
}
