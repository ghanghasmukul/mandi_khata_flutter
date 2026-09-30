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
        final summary = Text(
          structuredSummary(l10n, def.key, value),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        );
        if (!settingHasEditor(def)) return summary;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: summary),
            IconButton(
              key: ValueKey('edit-${def.key}'),
              tooltip: l10n.settingsEdit,
              onPressed: enabled ? () => _editStructured(context) : null,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        );
    }
  }

  Future<void> _editStructured(BuildContext context) async {
    final dialog = switch (def.key) {
      'mandi.cess' => CessListDialog.show(context, value),
      'mandi.charges_borne_by' => ChargesBorneByDialog.show(context, value),
      _ => null,
    };
    final edited = await dialog;
    if (edited == null) return;
    final error = await onSave(edited);
    if (error != null && context.mounted) {
      MkToast.show(context, error, tone: MkToastTone.error);
    }
  }
}

/// List / map settings that have their own editor. The rest (price tiers,
/// number series, languages) are shown read-only for now.
bool settingHasEditor(SettingDef def) =>
    def.type != SettingType.structured ||
    def.key == 'mandi.cess' ||
    def.key == 'mandi.charges_borne_by';

/// Edits a `mandi.cess` list: rows of name + percent. Returns the new list,
/// or null when cancelled.
class CessListDialog extends StatefulWidget {
  const CessListDialog({required this.initial, super.key});

  final List<({String name, String pct})> initial;

  static Future<List<Map<String, String>>?> show(
    BuildContext context,
    Object? value,
  ) => showDialog<List<Map<String, String>>>(
    context: context,
    barrierColor: MkColors.scrim,
    builder: (_) => CessListDialog(
      initial: [
        if (value is List)
          for (final e in value)
            if (e is Map)
              (
                name: '${e['name'] ?? ''}',
                pct: SettingsSchema.decimalOf(e['pct'])?.toString() ?? '',
              ),
      ],
    ),
  );

  @override
  State<CessListDialog> createState() => _CessListDialogState();
}

class _CessListDialogState extends State<CessListDialog> {
  late final List<(TextEditingController, TextEditingController)> _rows = [
    for (final r in widget.initial)
      (TextEditingController(text: r.name), TextEditingController(text: r.pct)),
  ];
  bool _invalid = false;

  @override
  void dispose() {
    for (final (a, b) in _rows) {
      a.dispose();
      b.dispose();
    }
    super.dispose();
  }

  void _add() => setState(
    () => _rows.add((TextEditingController(), TextEditingController())),
  );

  void _remove(int i) {
    final (a, b) = _rows.removeAt(i);
    a.dispose();
    b.dispose();
    setState(() {});
  }

  void _save() {
    final list = [
      for (final (name, pct) in _rows)
        if (name.text.trim().isNotEmpty || pct.text.trim().isNotEmpty)
          {
            'name': name.text.trim(),
            'pct': Decimal.tryParse(pct.text.trim())?.toString() ?? '',
          },
    ];
    final def = SettingsSchema.parse('mandi.cess')!.def;
    if (def.validate(list) != null) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(list);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkDialog(
      title: l10n.settingMandiCess,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (name, pct)) in _rows.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: MkSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: MkTextField(
                      key: ValueKey('cess-name-$i'),
                      controller: name,
                      hint: l10n.cessName,
                      autofocus: i == _rows.length - 1,
                    ),
                  ),
                  const SizedBox(width: MkSpacing.sm),
                  SizedBox(
                    width: 90,
                    child: MkTextField(
                      key: ValueKey('cess-pct-$i'),
                      controller: pct,
                      hint: l10n.cessPct,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,4}'),
                        ),
                      ],
                      suffix: const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text('%'),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.cessRemove,
                    onPressed: () => _remove(i),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const ValueKey('cess-add'),
              onPressed: _add,
              icon: const Icon(Icons.add),
              label: Text(l10n.cessAdd),
            ),
          ),
          if (_invalid)
            Text(
              l10n.settingErrorInvalid,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      actions: [
        MkButton(
          label: MaterialLocalizations.of(context).cancelButtonLabel,
          variant: MkButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MkButton(
          key: const ValueKey('cess-save'),
          label: l10n.settingsSave,
          onPressed: _save,
        ),
      ],
    );
  }
}

/// Edits `mandi.charges_borne_by`: one payer per charge. Always returns a
/// complete map (every charge), or null when cancelled.
class ChargesBorneByDialog extends StatefulWidget {
  const ChargesBorneByDialog({required this.initial, super.key});

  final Map<MandiCharge, ChargePayer> initial;

  static Future<Map<String, String>?> show(
    BuildContext context,
    Object? value,
  ) {
    final map = value is Map ? value : const <String, Object?>{};
    return showDialog<Map<String, String>>(
      context: context,
      barrierColor: MkColors.scrim,
      builder: (_) => ChargesBorneByDialog(
        initial: {
          for (final c in MandiCharge.values)
            c: ChargePayer.parse('${map[c.key]}') ?? ChargePayer.farmer,
        },
      ),
    );
  }

  @override
  State<ChargesBorneByDialog> createState() => _ChargesBorneByDialogState();
}

class _ChargesBorneByDialogState extends State<ChargesBorneByDialog> {
  late final Map<MandiCharge, ChargePayer> _payers = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkDialog(
      title: l10n.settingMandiChargesBorneBy,
      content: Column(
        children: [
          for (final c in MandiCharge.values)
            Padding(
              padding: const EdgeInsets.only(bottom: MkSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.mandiCharge(c))),
                  DropdownButton<ChargePayer>(
                    key: ValueKey('payer-${c.key}'),
                    value: _payers[c],
                    isDense: true,
                    onChanged: (p) => setState(() => _payers[c] = p!),
                    items: [
                      for (final p in ChargePayer.values)
                        DropdownMenuItem(
                          value: p,
                          child: Text(l10n.chargePayer(p)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        MkButton(
          label: MaterialLocalizations.of(context).cancelButtonLabel,
          variant: MkButtonVariant.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MkButton(
          key: const ValueKey('payers-save'),
          label: l10n.settingsSave,
          onPressed: () => Navigator.of(
            context,
          ).pop({for (final c in MandiCharge.values) c.key: _payers[c]!.name}),
        ),
      ],
    );
  }
}

/// One-line text for list / map values (cess, tiers, number series).
String structuredSummary(AppLocalizations l10n, String key, Object? value) {
  if (key == 'mandi.charges_borne_by' && value is Map) {
    // Only what differs from "farmer pays"; all-farmer shows one word.
    final notFarmer = [
      for (final c in MandiCharge.values)
        if (ChargePayer.parse('${value[c.key]}') case final p?
            when p != ChargePayer.farmer)
          '${l10n.mandiCharge(c)}: ${l10n.chargePayer(p)}',
    ];
    return notFarmer.isEmpty ? l10n.payerFarmer : notFarmer.join(', ');
  }
  return switch (value) {
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
}

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
