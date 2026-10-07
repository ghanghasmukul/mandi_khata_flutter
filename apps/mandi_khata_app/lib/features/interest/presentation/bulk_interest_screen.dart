import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/features/interest/presentation/interest_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_terms_editor.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Set the interest terms of many parties at once (owner: `loans.manage`):
/// pick the parties, for example one village, set the terms, apply. Each
/// party gets its own party-level settings (they win over the business
/// default). There is no separate party-group record yet; a village is the
/// usual group.
class BulkInterestScreen extends ConsumerStatefulWidget {
  const BulkInterestScreen({super.key});

  @override
  ConsumerState<BulkInterestScreen> createState() => _BulkInterestState();
}

class _BulkInterestState extends ConsumerState<BulkInterestScreen> {
  String? _village;
  final Set<String> _selected = {};
  InterestConfig? _edited;
  bool _touched = false;
  bool _saving = false;
  bool _submitted = false;
  String? _message;

  Future<void> _apply(InterestConfig seed) async {
    setState(() => _submitted = true);
    final config = _touched ? _edited : seed;
    if (config == null || _selected.isEmpty) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    final values = PartyInterestOverrides.explicit(config);
    final writer = ref.read(partyInterestWriterProvider);
    var done = 0;
    var failed = false;
    for (final id in _selected) {
      final failure = await writer.apply(id, values, existingKeys: const {});
      if (failure == null) {
        done++;
      } else {
        failed = true;
      }
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = false;
      _message = failed ? l10n.byajBulkFailed : l10n.byajBulkDone(done);
      if (!failed) _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canManage = ref.watch(canProvider(Permission.loansManage));
    final parties = ref.watch(partyListProvider('', null)).value ?? const [];
    final resolver = ref.watch(settingsResolverProvider(businessTarget));
    final villages = {
      for (final p in parties)
        if (p.village != null && p.village!.trim().isNotEmpty)
          p.village!.trim(),
    }.toList()..sort();
    final shown = [
      for (final p in parties)
        if (_village == null || p.village?.trim() == _village) p,
    ];
    final seed = resolver == null
        ? null
        : PartyInterestOverrides.forEditing(
            InterestConfig.fromSettings(resolver),
          );

    return Scaffold(
      body: Column(
        children: [
          MkTopBar(title: l10n.byajBulkTitle),
          Expanded(
            child: !canManage
                ? Center(child: Text(l10n.byajNoPermission))
                : seed == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(MkSpacing.lg),
                    children: [
                      Text(l10n.byajBulkIntro),
                      const SizedBox(height: MkSpacing.md),
                      MkCard(
                        child: LoanTermsEditor(
                          initial: seed,
                          showRateError: _submitted,
                          onChanged: (c) => setState(() {
                            _touched = true;
                            _edited = c;
                          }),
                        ),
                      ),
                      const SizedBox(height: MkSpacing.md),
                      Wrap(
                        spacing: MkSpacing.sm,
                        runSpacing: MkSpacing.xs,
                        children: [
                          ChoiceChip(
                            key: const ValueKey('bulk-village-all'),
                            label: Text(l10n.byajBulkAllVillages),
                            selected: _village == null,
                            onSelected: (_) => setState(() => _village = null),
                          ),
                          for (final v in villages)
                            ChoiceChip(
                              key: ValueKey('bulk-village-$v'),
                              label: Text(v),
                              selected: _village == v,
                              onSelected: (_) => setState(() => _village = v),
                            ),
                        ],
                      ),
                      const SizedBox(height: MkSpacing.sm),
                      if (shown.isEmpty)
                        Text(l10n.byajBulkNone)
                      else
                        CheckboxListTile(
                          key: const ValueKey('bulk-select-all'),
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.byajBulkSelectAll),
                          value: shown.every((p) => _selected.contains(p.id)),
                          onChanged: (v) => setState(() {
                            for (final p in shown) {
                              v ?? false
                                  ? _selected.add(p.id)
                                  : _selected.remove(p.id);
                            }
                          }),
                        ),
                      for (final Party p in shown)
                        CheckboxListTile(
                          key: ValueKey('bulk-party-${p.id}'),
                          contentPadding: EdgeInsets.zero,
                          title: Text(p.name),
                          subtitle: Text([p.code, ?p.village].join(' · ')),
                          value: _selected.contains(p.id),
                          onChanged: (v) => setState(() {
                            v ?? false
                                ? _selected.add(p.id)
                                : _selected.remove(p.id);
                          }),
                        ),
                      if (_message != null) ...[
                        const SizedBox(height: MkSpacing.md),
                        Text(_message!, key: const ValueKey('bulk-message')),
                      ],
                      const SizedBox(height: MkSpacing.md),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: MkButton(
                          key: const ValueKey('bulk-apply'),
                          label: l10n.byajBulkApply(_selected.length),
                          icon: Icons.check,
                          onPressed: _saving || _selected.isEmpty
                              ? null
                              : () => _apply(seed),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
