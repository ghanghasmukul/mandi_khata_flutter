import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/interest/presentation/interest_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_terms_editor.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Opens the interest terms of one party (owner: `loans.manage`). Shows the
/// terms the party gets now, saves only what differs from the business
/// default as the party's own settings, and can drop every override.
/// Returns true once saved.
Future<bool?> showPartyInterestDialog(BuildContext context, Party party) =>
    showDialog<bool>(
      context: context,
      barrierColor: MkColors.scrim,
      builder: (_) => PartyInterestDialog(party: party),
    );

class PartyInterestDialog extends ConsumerStatefulWidget {
  const PartyInterestDialog({required this.party, super.key});

  final Party party;

  @override
  ConsumerState<PartyInterestDialog> createState() =>
      _PartyInterestDialogState();
}

class _PartyInterestDialogState extends ConsumerState<PartyInterestDialog> {
  /// What the editor reports; null while the rate is not valid.
  InterestConfig? _edited;
  bool _touched = false;
  bool _saving = false;
  bool _submitted = false;
  String? _error;

  Set<String> _ownKeys() {
    final rows = ref.read(settingRowsProvider(partyTarget(widget.party))).value;
    return {
      for (final r in rows ?? const <SettingRow>[])
        if (r.scope == SettingScope.party &&
            r.scopeId == widget.party.id &&
            r.value != null &&
            r.key.startsWith('interest.'))
          r.key,
    };
  }

  Future<void> _run(Map<String, Object?> values) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final failure = await ref
        .read(partyInterestWriterProvider)
        .apply(widget.party.id, values, existingKeys: _ownKeys());
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (failure != null) {
      setState(() {
        _saving = false;
        _error = switch (failure) {
          SettingNotPermitted() => l10n.byajNoPermission,
          _ => l10n.loanErrorRate,
        };
      });
      return;
    }
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(l10n.byajSaved)));
    Navigator.of(context).pop(true);
  }

  Future<void> _save(InterestConfig seed, InterestConfig inherited) async {
    setState(() => _submitted = true);
    final edited = _touched ? _edited : seed;
    if (edited == null) return;
    await _run(
      PartyInterestOverrides.diff(inherited: inherited, edited: edited),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final target = partyTarget(widget.party);
    final resolver = ref.watch(settingsResolverProvider(target));
    if (resolver == null) {
      return const MkDialog(
        title: '',
        content: Center(child: CircularProgressIndicator()),
      );
    }
    final party = widget.party;
    final current = InterestConfig.fromSettings(
      resolver,
      partyId: party.id,
      partyGroupId: party.partyGroupId,
      partyRoles: party.roles,
    );
    final inherited = InterestConfig.fromSettings(
      resolver,
      partyGroupId: party.partyGroupId,
      partyRoles: party.roles,
    );
    final seed = PartyInterestOverrides.forEditing(current);
    final perMonth =
        resolver
            .resolve(
              'interest.rate_unit_display',
              partyId: party.id,
              partyGroupId: party.partyGroupId,
            )
            .value ==
        'per100_per_month';

    void save() => _save(seed, inherited);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f10): save,
        const SingleActivator(LogicalKeyboardKey.enter, control: true): save,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): save,
      },
      child: MkDialog(
        title: l10n.byajDialogTitle(party.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.byajDialogHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: MkSpacing.md),
              LoanTermsEditor(
                initial: seed,
                perMonthInitially: perMonth,
                showRateError: _submitted,
                onChanged: (c) => setState(() {
                  _touched = true;
                  _edited = c;
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: MkSpacing.md),
                Text(
                  _error!,
                  key: const ValueKey('byaj-error'),
                  style: TextStyle(color: MkTokens.of(context).udhaar),
                ),
              ],
            ],
          ),
        ),
        actions: [
          MkButton(
            label: l10n.commonCancel,
            variant: MkButtonVariant.ghost,
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          ),
          MkButton(
            key: const ValueKey('byaj-defaults'),
            label: l10n.byajUseDefaults,
            variant: MkButtonVariant.secondary,
            onPressed: _saving
                ? null
                : () => _run({for (final k in _ownKeys()) k: null}),
          ),
          MkButton(
            key: const ValueKey('byaj-save'),
            label: l10n.byajSave,
            icon: Icons.check,
            onPressed: _saving ? null : save,
          ),
        ],
      ),
    );
  }
}
