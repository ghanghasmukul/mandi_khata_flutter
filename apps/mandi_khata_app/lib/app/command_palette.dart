import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/app/router.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_screen.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_screen.dart';
import 'package:mandi_khata_app/features/khata/presentation/day_book_screen.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_entry_dialog.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/record_payment_dialog.dart';
import 'package:mandi_khata_app/features/reports/presentation/reports_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One thing the palette can do.
class PaletteCommand {
  const PaletteCommand({
    required this.id,
    required this.label,
    required this.icon,
    required this.run,
  });

  final String id;
  final String label;
  final IconData icon;

  /// Called with the app's navigator context after the palette closed.
  final void Function(BuildContext context) run;
}

/// The commands available to a member with [can], in display order.
List<PaletteCommand> paletteCommands(
  AppLocalizations l10n,
  bool Function(Permission) can,
) => [
  if (can(Permission.entriesReverse))
    PaletteCommand(
      id: 'khata-entry',
      label: l10n.khataEntryTitle,
      icon: Icons.edit_note,
      run: showKhataEntryDialog,
    ),
  if (can(Permission.paymentsCreate))
    PaletteCommand(
      id: 'payment-new',
      label: l10n.paymentRecordTitle,
      icon: Icons.add_card_outlined,
      run: showRecordPaymentDialog,
    ),
  PaletteCommand(
    id: 'payments',
    label: l10n.paymentsTitle,
    icon: Icons.payments_outlined,
    run: (c) => c.go(PaymentRoutes.list),
  ),
  PaletteCommand(
    id: 'day-book',
    label: l10n.khataDayBookTitle,
    icon: Icons.menu_book_outlined,
    run: (c) => c.go(KhataRoutes.dayBook),
  ),
  PaletteCommand(
    id: 'reports',
    label: l10n.reportsTitle,
    icon: Icons.assessment_outlined,
    run: (c) => c.go(ReportRoutes.list),
  ),
  PaletteCommand(
    id: 'parties',
    label: l10n.partiesTitle,
    icon: Icons.groups_outlined,
    run: (c) => c.go(PartyRoutes.list),
  ),
  if (can(Permission.partiesManage))
    PaletteCommand(
      id: 'party-new',
      label: l10n.partiesAdd,
      icon: Icons.person_add_alt_1,
      run: (c) => c.go(PartyRoutes.create),
    ),
  PaletteCommand(
    id: 'arrivals',
    label: l10n.arrivalsTitle,
    icon: Icons.agriculture_outlined,
    run: (c) => c.go(ArrivalRoutes.list),
  ),
  PaletteCommand(
    id: 'crops',
    label: l10n.cropsTitle,
    icon: Icons.grass_outlined,
    run: (c) => c.go(CropRoutes.list),
  ),
  PaletteCommand(
    id: 'settings',
    label: l10n.settingsTitle,
    icon: Icons.tune,
    run: (c) => c.go(AppRoutes.settings),
  ),
];

/// Ctrl/⌘ K anywhere (once signed in and unlocked) opens the palette.
class CommandPaletteShortcut extends ConsumerWidget {
  const CommandPaletteShortcut({
    required this.navigatorKey,
    required this.child,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  Future<void> _open(WidgetRef ref) async {
    final context = navigatorKey.currentContext;
    if (context == null || ref.read(gateStepProvider) != GateStep.ready) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final member = ref.read(activeMembershipProvider);
    if (member == null) return;
    final picked = await showDialog<PaletteCommand>(
      context: context,
      barrierColor: MkColors.scrim,
      builder: (_) =>
          _PaletteDialog(commands: paletteCommands(l10n, member.can)),
    );
    final target = navigatorKey.currentContext;
    if (picked != null && target != null && target.mounted) picked.run(target);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            _open(ref),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            _open(ref),
      },
      child: child,
    );
  }
}

class _PaletteDialog extends StatefulWidget {
  const _PaletteDialog({required this.commands});

  final List<PaletteCommand> commands;

  @override
  State<_PaletteDialog> createState() => _PaletteDialogState();
}

class _PaletteDialogState extends State<_PaletteDialog> {
  String _query = '';
  int _highlight = 0;

  List<PaletteCommand> get _matches {
    final q = _query.trim().toLowerCase();
    return [
      for (final c in widget.commands)
        if (q.isEmpty || c.label.toLowerCase().contains(q)) c,
    ];
  }

  void _pick(PaletteCommand c) => Navigator.of(context).pop(c);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final matches = _matches;
    final highlight = matches.isEmpty
        ? 0
        : _highlight.clamp(0, matches.length - 1);
    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.all(MkSpacing.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(MkSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                      setState(() => _highlight = highlight + 1),
                  const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                      setState(() => _highlight = highlight - 1),
                },
                child: MkTextField(
                  key: const ValueKey('palette-search'),
                  autofocus: true,
                  hint: l10n.paletteHint,
                  prefix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.search, size: 20),
                  ),
                  onChanged: (v) => setState(() {
                    _query = v;
                    _highlight = 0;
                  }),
                  onSubmitted: (_) {
                    if (matches.isNotEmpty) _pick(matches[highlight]);
                  },
                ),
              ),
              const SizedBox(height: MkSpacing.sm),
              if (matches.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(MkSpacing.lg),
                  child: Text(l10n.paletteNoMatch),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (var i = 0; i < matches.length; i++)
                        ListTile(
                          key: ValueKey('palette-${matches[i].id}'),
                          selected: i == highlight,
                          leading: Icon(matches[i].icon),
                          title: Text(matches[i].label),
                          onTap: () => _pick(matches[i]),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
