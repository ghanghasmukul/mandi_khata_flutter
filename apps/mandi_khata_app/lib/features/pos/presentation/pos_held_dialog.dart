import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/features/pos/data/pos_catalog.dart';
import 'package:mandi_khata_app/features/pos/presentation/pos_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The bills on hold on this device; tapping one recalls it (the bill in
/// hand is put on hold first, so nothing is lost).
Future<void> showHeldBillsDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierColor: MkColors.scrim,
  builder: (_) => const _HeldBillsDialog(),
);

class _HeldBillsDialog extends ConsumerWidget {
  const _HeldBillsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final held = ref.watch(heldBillsProvider).value ?? const <HeldBill>[];
    return MkDialog(
      title: l10n.posHeldTitle,
      content: held.isEmpty
          ? Text(l10n.posHeldEmpty)
          : Column(
              children: [
                for (final h in held)
                  ListTile(
                    key: ValueKey('held-${h.id}'),
                    minVerticalPadding: 12,
                    title: Text(h.partyName ?? l10n.posWalkIn),
                    subtitle: Text(
                      '${l10n.posHeldItems(h.lineCount)} · '
                      '${h.createdAt.toLocal().toString().substring(0, 16)}',
                    ),
                    onTap: () => _recall(context, ref, h),
                    trailing: IconButton(
                      tooltip: l10n.posHeldDelete,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final ctx = ref.read(writeContextProvider);
                        if (ctx == null) return;
                        final repo = await ref.read(
                          heldBillsRepositoryProvider.future,
                        );
                        await repo.delete(ctx.tenantId, h.id);
                      },
                    ),
                  ),
              ],
            ),
      actions: [
        MkButton(
          label: l10n.commonClose,
          variant: MkButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Future<void> _recall(BuildContext context, WidgetRef ref, HeldBill h) async {
    final ctx = ref.read(writeContextProvider);
    if (ctx == null) return;
    final controller = ref.read(posCartControllerProvider.notifier);
    final repo = await ref.read(heldBillsRepositoryProvider.future);
    final catalog = ref.read(posCatalogProvider).value ?? const [];
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    // Keep the bill in hand: hold it before replacing it.
    if (!ref.read(posCartControllerProvider).isEmpty) {
      await repo.hold(ctx, controller.toPayload());
    }
    final skipped = controller.restore(h.payload, catalog);
    await repo.delete(ctx.tenantId, h.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    if (skipped > 0) {
      MkToast.show(context, l10n.posHeldSkipped(skipped));
    }
  }
}
