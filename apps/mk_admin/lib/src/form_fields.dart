import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mk_ui/mk_ui.dart';

/// What the plan modules are called (the app knows these five).
const knownModules = ['khata', 'arrivals', 'karza', 'accounting', 'shop'];

enum FieldKind {
  text,
  multiline,
  integer,
  decimal,
  boolean,
  json,
  modules,
  choice,

  /// An int of paise shown and edited in rupees.
  rupees,

  /// A list of strings, one per line (plan codes).
  lines,
}

class FieldSpec {
  const FieldSpec(
    this.key,
    this.label,
    this.kind, {
    this.required = false,
    this.lockedWhenEditing = false,
    this.choices = const [],
    this.hint,
    this.initial,
  });

  final String key;
  final String label;
  final FieldKind kind;
  final bool required;

  /// The key of a row cannot be renamed.
  final bool lockedWhenEditing;
  final List<String> choices;
  final String? hint;
  final Object? initial;
}

/// The state behind a form built from [FieldSpec]s.
class FormValues {
  FormValues(this.fields, Map<String, Object?>? row) : editing = row != null {
    for (final f in fields) {
      final raw = row == null ? f.initial : row[f.key];
      switch (f.kind) {
        case FieldKind.boolean:
          bools[f.key] = raw is bool ? raw : (f.initial as bool? ?? true);
        case FieldKind.modules:
          final m = raw is Map<dynamic, dynamic>
              ? raw
              : const <String, Object?>{};
          modules[f.key] = {
            for (final k in knownModules) k: m[k] == true,
            for (final e in m.entries)
              if (e.key is String && e.value == true) e.key as String: true,
          };
        case FieldKind.choice:
          choices[f.key] = raw?.toString() ?? f.choices.first;
        default:
          text[f.key] = TextEditingController(text: _show(f, raw));
      }
    }
  }

  final List<FieldSpec> fields;
  final bool editing;
  final Map<String, TextEditingController> text = {};
  final Map<String, bool> bools = {};
  final Map<String, Map<String, bool>> modules = {};
  final Map<String, String> choices = {};

  static String _show(FieldSpec f, Object? raw) {
    if (raw == null) return '';
    return switch (f.kind) {
      FieldKind.json => const JsonEncoder.withIndent('  ').convert(raw),
      FieldKind.rupees => raw is num ? (raw / 100).toString() : '$raw',
      FieldKind.lines => raw is List ? raw.join('\n') : '$raw',
      _ => '$raw',
    };
  }

  void dispose() {
    for (final c in text.values) {
      c.dispose();
    }
  }

  /// The values to send, or a message for the first field that is wrong.
  ({Map<String, Object?>? values, String? error}) read() {
    final out = <String, Object?>{};
    for (final f in fields) {
      switch (f.kind) {
        case FieldKind.boolean:
          out[f.key] = bools[f.key];
        case FieldKind.modules:
          out[f.key] = modules[f.key];
        case FieldKind.choice:
          out[f.key] = choices[f.key];
        default:
          final raw = text[f.key]!.text.trim();
          if (raw.isEmpty) {
            if (f.required) {
              return (values: null, error: '${f.label} is needed');
            }
            out[f.key] = switch (f.kind) {
              FieldKind.json => <String, Object?>{},
              FieldKind.lines => null,
              _ => null,
            };
            continue;
          }
          switch (f.kind) {
            case FieldKind.integer:
              final v = int.tryParse(raw);
              if (v == null) {
                return (values: null, error: '${f.label}: whole number');
              }
              out[f.key] = v;
            case FieldKind.decimal:
              final v = num.tryParse(raw);
              if (v == null) {
                return (values: null, error: '${f.label}: a number');
              }
              out[f.key] = v;
            case FieldKind.rupees:
              final v = num.tryParse(raw);
              if (v == null || v < 0) {
                return (
                  values: null,
                  error: '${f.label}: rupees, like 999 or 999.50',
                );
              }
              out[f.key] = (v * 100).round();
            case FieldKind.json:
              try {
                out[f.key] = jsonDecode(raw);
              } on FormatException {
                return (values: null, error: '${f.label}: not valid JSON');
              }
            case FieldKind.lines:
              out[f.key] = [
                for (final l in raw.split('\n'))
                  if (l.trim().isNotEmpty) l.trim(),
              ];
            default:
              out[f.key] = raw;
          }
      }
    }
    return (values: out, error: null);
  }
}

/// Renders [FormValues] as a column of inputs.
class FormFields extends StatefulWidget {
  const FormFields({required this.values, super.key});

  final FormValues values;

  @override
  State<FormFields> createState() => _FormFieldsState();
}

class _FormFieldsState extends State<FormFields> {
  @override
  Widget build(BuildContext context) {
    final v = widget.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final f in v.fields)
          Padding(
            padding: const EdgeInsets.only(bottom: MkSpacing.md),
            child: switch (f.kind) {
              FieldKind.boolean => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(f.label),
                value: v.bools[f.key]!,
                onChanged: (b) => setState(() => v.bools[f.key] = b),
              ),
              FieldKind.modules => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.label, style: Theme.of(context).textTheme.labelLarge),
                  Wrap(
                    spacing: MkSpacing.sm,
                    children: [
                      for (final m in v.modules[f.key]!.keys)
                        FilterChip(
                          label: Text(m),
                          selected: v.modules[f.key]![m]!,
                          onSelected: (b) =>
                              setState(() => v.modules[f.key]![m] = b),
                        ),
                    ],
                  ),
                ],
              ),
              FieldKind.choice => DropdownMenu<String>(
                label: Text(f.label),
                expandedInsets: EdgeInsets.zero,
                initialSelection: v.choices[f.key],
                onSelected: (c) =>
                    setState(() => v.choices[f.key] = c ?? v.choices[f.key]!),
                dropdownMenuEntries: [
                  for (final c in f.choices)
                    DropdownMenuEntry(value: c, label: c),
                ],
              ),
              _ => MkTextField(
                key: ValueKey('field-${f.key}'),
                controller: v.text[f.key],
                label: f.label + (f.required ? ' *' : ''),
                hint: f.hint,
                enabled: !(f.lockedWhenEditing && v.editing),
                maxLines: switch (f.kind) {
                  FieldKind.json => 6,
                  FieldKind.multiline => 3,
                  FieldKind.lines => 3,
                  _ => 1,
                },
              ),
            },
          ),
      ],
    );
  }
}

/// Asks for one line of text. Null when cancelled; the text may be empty
/// unless [required].
Future<String?> promptText(
  BuildContext context, {
  required String title,
  required String label,
  bool required = false,
  String confirmLabel = 'Confirm',
  Key? fieldKey,
  Key? confirmKey,
}) => showDialog<String>(
  context: context,
  builder: (_) => _PromptDialog(
    title: title,
    label: label,
    required: required,
    confirmLabel: confirmLabel,
    fieldKey: fieldKey,
    confirmKey: confirmKey,
  ),
);

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({
    required this.title,
    required this.label,
    required this.required,
    required this.confirmLabel,
    this.fieldKey,
    this.confirmKey,
  });

  final String title;
  final String label;
  final bool required;
  final String confirmLabel;
  final Key? fieldKey;
  final Key? confirmKey;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 420,
      child: MkTextField(
        key: widget.fieldKey,
        controller: _controller,
        label: widget.label,
        autofocus: true,
        maxLines: 2,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: widget.confirmKey,
        onPressed: () {
          final text = _controller.text.trim();
          if (widget.required && text.isEmpty) return;
          Navigator.of(context).pop(text);
        },
        child: Text(widget.confirmLabel),
      ),
    ],
  );
}
