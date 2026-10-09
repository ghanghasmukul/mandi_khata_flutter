import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_form_fields.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

/// Add ([partyId] null) or edit a party. Ctrl/⌘+S saves, Esc goes back.
class PartyFormScreen extends ConsumerStatefulWidget {
  const PartyFormScreen({super.key, this.partyId});

  final String? partyId;

  @override
  ConsumerState<PartyFormScreen> createState() => _PartyFormScreenState();
}

class _PartyFormScreenState extends ConsumerState<PartyFormScreen> {
  final _c = PartyFormControllers();
  Set<PartyRole> _roles = {PartyRole.farmer};
  Relation? _relation;
  Map<PartyField, PartyFieldError> _errors = const {};
  bool _codeTaken = false;
  bool _saving = false;
  late bool _loading = widget.partyId != null;

  bool get _editing => widget.partyId != null;

  @override
  void initState() {
    super.initState();
    final id = widget.partyId;
    if (id != null) {
      unawaited(_load(id));
    }
  }

  Future<void> _load(String id) async {
    final p = await ref.read(partyProvider(id).future);
    if (!mounted) return;
    if (p != null) {
      _c.fill(p.toInput());
      _roles = p.roles;
      _relation = p.relation;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _back() => context.go(
    _editing ? PartyRoutes.detail(widget.partyId!) : PartyRoutes.list,
  );

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final input = _c.read(roles: _roles, relation: _relation);
    setState(() {
      _saving = true;
      _codeTaken = false;
    });
    final writer = ref.read(partyWriterProvider);
    final result = _editing
        ? await writer.update(widget.partyId!, input)
        : await writer.create(input);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _errors = result is PartyInvalid ? result.errors : const {};
      _codeTaken = result is PartyCodeTaken;
    });
    switch (result) {
      case PartySaved(:final id):
        MkToast.show(context, l10n.partySaved, tone: MkToastTone.success);
        context.go(PartyRoutes.detail(id));
      case PartyNotPermitted():
        MkToast.show(
          context,
          l10n.settingsNoPermission,
          tone: MkToastTone.error,
        );
      case PartyLimitReached(:final limit):
        MkToast.show(
          context,
          l10n.limitReachedParties(limit),
          tone: MkToastTone.error,
        );
      case PartyNotFound():
        MkToast.show(context, l10n.partyNotFound, tone: MkToastTone.error);
      case PartyInvalid() || PartyCodeTaken():
        break;
    }
  }

  String? _err(PartyField f) =>
      AppLocalizations.of(context).partyFieldError(f, _errors[f]);

  Widget _field(
    TextEditingController c,
    String label, {
    PartyField? field,
    String? hint,
    String? error,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    int maxLines = 1,
    bool autofocus = false,
  }) => MkTextField(
    controller: c,
    label: label,
    hint: hint,
    autofocus: autofocus,
    errorText: error ?? (field == null ? null : _err(field)),
    keyboardType: keyboard,
    inputFormatters: formatters,
    maxLines: maxLines,
    textInputAction: maxLines > 1 ? TextInputAction.newline : null,
    onSubmitted: maxLines > 1 ? null : (_) => _save(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nextCode = _editing ? null : ref.watch(nextPartyCodeProvider).value;
    return CallbackShortcuts(
      bindings: {
        ...primaryShortcut(LogicalKeyboardKey.keyS, _save),
        const SingleActivator(LogicalKeyboardKey.escape): _back,
      },
      child: Scaffold(
        body: Column(
          children: [
            MkTopBar(title: _editing ? l10n.partyEditTitle : l10n.partiesAdd),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _form(l10n, nextCode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(AppLocalizations l10n, String? nextCode) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
      child: ListView(
        padding: const EdgeInsets.all(MkSpacing.lg),
        children: [
          PartyFormSection(
            title: l10n.partySectionIdentity,
            children: [
              _field(
                _c.name,
                l10n.partyFieldName,
                field: PartyField.name,
                autofocus: !_editing,
              ),
              _field(
                _c.code,
                l10n.partyFieldCode,
                field: PartyField.code,
                hint: nextCode == null
                    ? null
                    : l10n.partyCodeAutoHint(nextCode),
                error: _codeTaken ? l10n.partyErrorCodeTaken : null,
                formatters: PartyInputFormatters.upperCode,
              ),
              DropdownButtonFormField<Relation?>(
                initialValue: _relation,
                decoration: InputDecoration(labelText: l10n.partyFieldRelation),
                items: [
                  for (final r in <Relation?>[null, ...Relation.values])
                    DropdownMenuItem(value: r, child: Text(l10n.relation(r))),
                ],
                onChanged: (r) => setState(() => _relation = r),
              ),
              _field(
                _c.father,
                l10n.partyFieldFatherOrHusband,
                field: PartyField.fatherOrHusbandName,
              ),
              FullWidth(
                child: RolePicker(
                  selected: _roles,
                  onChanged: (r) => setState(() => _roles = r),
                  errorText: _err(PartyField.roles),
                ),
              ),
            ],
          ),
          PartyFormSection(
            title: l10n.partySectionContact,
            children: [
              _field(
                _c.mobile,
                l10n.partyFieldMobile,
                field: PartyField.mobile,
                keyboard: TextInputType.phone,
                formatters: PartyInputFormatters.phone,
              ),
              _field(
                _c.altMobile,
                l10n.partyFieldAltMobile,
                field: PartyField.altMobile,
                keyboard: TextInputType.phone,
                formatters: PartyInputFormatters.phone,
              ),
              _field(_c.village, l10n.partyFieldVillage),
              _field(_c.district, l10n.partyFieldDistrict),
              _field(_c.state, l10n.partyFieldState),
              _field(
                _c.aadhaar,
                l10n.partyFieldAadhaar,
                field: PartyField.aadhaarLast4,
                keyboard: TextInputType.number,
                formatters: PartyInputFormatters.aadhaar,
              ),
            ],
          ),
          PartyFormSection(
            title: l10n.partySectionBank,
            children: [
              // Bank details need finance.view. The hidden controllers keep
              // their values, so saving does not blank what a munshi cannot
              // see.
              if (ref.watch(canProvider(Permission.financeView))) ...[
                _field(_c.bankName, l10n.partyFieldBankName),
                _field(
                  _c.bankAccount,
                  l10n.partyFieldBankAccount,
                  hint: l10n.partyBankAccountHint,
                  keyboard: TextInputType.number,
                ),
                _field(
                  _c.ifsc,
                  l10n.partyFieldIfsc,
                  field: PartyField.ifsc,
                  formatters: PartyInputFormatters.upperCode,
                ),
              ],
              _field(
                _c.gstin,
                l10n.partyFieldGstin,
                field: PartyField.gstin,
                formatters: PartyInputFormatters.upperCode,
              ),
              FullWidth(
                child: _field(_c.notes, l10n.partyFieldNotes, maxLines: 3),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: MkButton(
              label: l10n.partySave,
              icon: Icons.check,
              busy: _saving,
              onPressed: _saving ? null : _save,
            ),
          ),
        ],
      ),
    ),
  );
}
