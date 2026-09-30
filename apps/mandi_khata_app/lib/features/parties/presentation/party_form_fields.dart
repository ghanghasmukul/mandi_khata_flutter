import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Text controllers for every free-text party field.
class PartyFormControllers {
  final code = TextEditingController();
  final name = TextEditingController();
  final father = TextEditingController();
  final village = TextEditingController();
  final district = TextEditingController();
  final state = TextEditingController();
  final mobile = TextEditingController();
  final altMobile = TextEditingController();
  final aadhaar = TextEditingController();
  final bankName = TextEditingController();
  final bankAccount = TextEditingController();
  final ifsc = TextEditingController();
  final gstin = TextEditingController();
  final notes = TextEditingController();

  List<TextEditingController> get _all => [
    code,
    name,
    father,
    village,
    district,
    state,
    mobile,
    altMobile,
    aadhaar,
    bankName,
    bankAccount,
    ifsc,
    gstin,
    notes,
  ];

  void fill(PartyInput p) {
    code.text = p.code;
    name.text = p.name;
    father.text = p.fatherOrHusbandName ?? '';
    village.text = p.village ?? '';
    district.text = p.district ?? '';
    state.text = p.state ?? '';
    mobile.text = p.mobile ?? '';
    altMobile.text = p.altMobile ?? '';
    aadhaar.text = p.aadhaarLast4 ?? '';
    bankName.text = p.bankName ?? '';
    bankAccount.text = p.bankAccount ?? '';
    ifsc.text = p.ifsc ?? '';
    gstin.text = p.gstin ?? '';
    notes.text = p.notes ?? '';
  }

  PartyInput read({required Set<PartyRole> roles, Relation? relation}) =>
      PartyInput(
        code: code.text,
        name: name.text,
        roles: roles,
        relation: relation,
        fatherOrHusbandName: father.text,
        village: village.text,
        district: district.text,
        state: state.text,
        mobile: mobile.text,
        altMobile: altMobile.text,
        aadhaarLast4: aadhaar.text,
        bankName: bankName.text,
        bankAccount: bankAccount.text,
        ifsc: ifsc.text,
        gstin: gstin.text,
        notes: notes.text,
      );

  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
  }
}

/// A titled group of fields that wraps into columns on wide screens.
class PartyFormSection extends StatelessWidget {
  const PartyFormSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: MkSpacing.lg),
    child: MkCard(
      title: title,
      child: LayoutBuilder(
        builder: (context, c) {
          final twoColumns = c.maxWidth >= 560;
          final width = twoColumns
              ? (c.maxWidth - MkSpacing.lg) / 2
              : c.maxWidth;
          return Wrap(
            spacing: MkSpacing.lg,
            runSpacing: MkSpacing.md,
            children: [
              for (final child in children)
                SizedBox(
                  width: child is FullWidth ? c.maxWidth : width,
                  child: child,
                ),
            ],
          );
        },
      ),
    ),
  );
}

/// Marks a field that spans both columns.
class FullWidth extends StatelessWidget {
  const FullWidth({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Multi-select role chips with an error line.
class RolePicker extends StatelessWidget {
  const RolePicker({
    required this.selected,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final Set<PartyRole> selected;
  final ValueChanged<Set<PartyRole>> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.partyFieldRoles, style: theme.textTheme.labelLarge),
        const SizedBox(height: MkSpacing.sm),
        Wrap(
          spacing: MkSpacing.sm,
          runSpacing: MkSpacing.sm,
          children: [
            for (final r in PartyRole.values)
              FilterChip(
                label: Text(l10n.partyRole(r)),
                selected: selected.contains(r),
                onSelected: (on) => onChanged(
                  on ? {...selected, r} : ({...selected}..remove(r)),
                ),
              ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: MkSpacing.xs),
            child: Text(
              errorText!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

/// Input formatters for the typed-in party fields.
abstract final class PartyInputFormatters {
  static final List<TextInputFormatter> phone = [
    FilteringTextInputFormatter.allow(RegExp(r'[\d +\-]')),
    LengthLimitingTextInputFormatter(16),
  ];
  static final List<TextInputFormatter> aadhaar = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(4),
  ];
  static final List<TextInputFormatter> upperCode = [
    LengthLimitingTextInputFormatter(15),
    TextInputFormatter.withFunction(
      (_, v) => v.copyWith(text: v.text.toUpperCase()),
    ),
  ];
}
