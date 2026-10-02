import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/khata/presentation/party_khata_tab.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mandi_khata_app/shared/shortcuts.dart';
import 'package:mk_ui/mk_ui.dart';

/// One party: details, edit / delete, and tabs that later steps fill
/// (khata 1.4, lots 1.3, loans 2.2, shop 4.4, documents 6.3).
class PartyDetailScreen extends ConsumerWidget {
  const PartyDetailScreen({required this.partyId, super.key});

  final String partyId;

  Future<void> _delete(BuildContext context, WidgetRef ref, Party p) async {
    final l10n = AppLocalizations.of(context);
    final ok = await MkDialog.show<bool>(
      context,
      title: l10n.partyDeleteTitle(p.name),
      content: Text(l10n.partyDeleteBody),
      actions: [
        Builder(
          builder: (c) => MkButton(
            label: l10n.commonCancel,
            variant: MkButtonVariant.ghost,
            onPressed: () => Navigator.of(c).pop(false),
          ),
        ),
        Builder(
          builder: (c) => MkButton(
            label: l10n.partyDelete,
            icon: Icons.delete_outline,
            variant: MkButtonVariant.danger,
            onPressed: () => Navigator.of(c).pop(true),
          ),
        ),
      ],
    );
    if (ok != true || !context.mounted) return;
    final result = await ref.read(partyWriterProvider).delete(p.id);
    if (!context.mounted) return;
    if (result is PartySaved) {
      MkToast.show(context, l10n.partyDeleted, tone: MkToastTone.success);
      context.go(PartyRoutes.list);
    } else {
      MkToast.show(context, l10n.settingsNoPermission, tone: MkToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(partyProvider(partyId));
    final party = async.value;
    final canEdit = ref.watch(canProvider(Permission.partiesManage));
    final canDelete = ref.watch(canProvider(Permission.masterDelete));
    void back() => context.go(PartyRoutes.list);
    void edit() => context.go(PartyRoutes.edit(partyId));

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): back,
        if (canEdit && party != null)
          ...primaryShortcut(LogicalKeyboardKey.keyE, edit),
      },
      child: Focus(
        autofocus: true,
        child: DefaultTabController(
          length: 6,
          child: Scaffold(
            body: Column(
              children: [
                MkTopBar(
                  title: party?.name ?? l10n.partiesTitle,
                  subtitle: party?.code,
                  actions: [
                    if (party != null && canEdit)
                      IconButton(
                        tooltip: l10n.partyEdit,
                        onPressed: edit,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    if (party != null && canDelete)
                      IconButton(
                        tooltip: l10n.partyDelete,
                        onPressed: () => _delete(context, ref, party),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      onPressed: back,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
                Expanded(
                  child: switch (async) {
                    AsyncData(value: null) => Center(
                      child: Text(l10n.partyNotFound),
                    ),
                    AsyncData(:final value?) => _Body(party: value),
                    _ => const Center(child: CircularProgressIndicator()),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.party});

  final Party party;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = party;
    Widget fact(String label, String? value) => value == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(right: MkSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          );
    final place = [?p.village, ?p.district, ?p.state].join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(MkSpacing.lg),
          child: MkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.partyFullName(p), style: theme.textTheme.titleLarge),
                const SizedBox(height: MkSpacing.sm),
                Wrap(
                  spacing: MkSpacing.sm,
                  runSpacing: MkSpacing.sm,
                  children: [
                    for (final r in PartyRole.values)
                      if (p.roles.contains(r))
                        MkRoleChip(label: l10n.partyRole(r)),
                  ],
                ),
                const SizedBox(height: MkSpacing.md),
                Wrap(
                  runSpacing: MkSpacing.md,
                  children: [
                    fact(l10n.partyFieldCode, p.code),
                    fact(l10n.partyFieldMobile, p.mobile),
                    fact(l10n.partyFieldAltMobile, p.altMobile),
                    fact(l10n.partyFieldVillage, place.isEmpty ? null : place),
                    fact(l10n.partyFieldBankName, p.bankName),
                    fact(l10n.partyFieldBankAccount, p.bankAccountMasked),
                    fact(l10n.partyFieldIfsc, p.ifsc),
                    fact(l10n.partyFieldGstin, p.gstin),
                  ],
                ),
              ],
            ),
          ),
        ),
        TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: l10n.partyTabKhata),
            Tab(text: l10n.partyTabLots),
            Tab(text: l10n.partyTabLoans),
            Tab(text: l10n.partyTabShop),
            Tab(text: l10n.partyTabDocuments),
            Tab(text: l10n.partyTabNotes),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              PartyKhataTab(party: p),
              for (var i = 0; i < 4; i++)
                MkEmptyState(
                  icon: Icons.construction_outlined,
                  title: l10n.partyTabComingSoon,
                ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(MkSpacing.lg),
                child: Text(p.notes ?? l10n.partyNoNotes),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
