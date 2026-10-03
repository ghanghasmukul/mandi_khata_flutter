import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/payments/domain/payment.dart';
import 'package:mandi_khata_app/features/payments/presentation/payment_mode_fields.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_providers.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/receipt_actions.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// One payment: its details and the receipt (print / share), with cheque
/// actions (clear, bounce) and Reverse for members who may.
class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({required this.paymentId, super.key});

  final String paymentId;

  void _toast(BuildContext context, String? error, String done) => MkToast.show(
    context,
    error ?? done,
    tone: error == null ? MkToastTone.success : MkToastTone.error,
  );

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(paymentWriterProvider)
        .setChequeStatus(paymentId, ChequeStatus.cleared);
    if (context.mounted) {
      _toast(context, l10n.paymentSaveError(result), l10n.paymentClearedToast);
    }
  }

  Future<void> _bounce(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final date = await showDialog<LedgerDate>(
      context: context,
      barrierColor: MkColors.scrim,
      builder: (_) => const _BounceDialog(),
    );
    if (date == null || !context.mounted) return;
    final result = await ref
        .read(paymentWriterProvider)
        .setChequeStatus(paymentId, ChequeStatus.bounced, bounceDate: date);
    if (context.mounted) {
      _toast(context, l10n.paymentSaveError(result), l10n.paymentBouncedToast);
    }
  }

  Future<void> _reverse(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await MkDialog.show<bool>(
      context,
      title: l10n.paymentReverseTitle,
      content: Text(l10n.paymentReverseBody),
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
            key: const ValueKey('payment-confirm'),
            label: l10n.paymentReverse,
            icon: Icons.undo,
            variant: MkButtonVariant.danger,
            onPressed: () => Navigator.of(c).pop(true),
          ),
        ),
      ],
    );
    if (ok != true || !context.mounted) return;
    final result = await ref.read(paymentWriterProvider).reverse(paymentId);
    if (context.mounted) {
      _toast(context, l10n.paymentSaveError(result), l10n.paymentReversedToast);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(paymentProvider(paymentId));
    final canCreate = ref.watch(canProvider(Permission.paymentsCreate));
    final canReverse = ref.watch(canProvider(Permission.entriesReverse));
    final p = async.value;
    void back() => context.go(PaymentRoutes.list);

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): back},
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              MkTopBar(
                title: p?.receiptNo ?? l10n.paymentsTitle,
                subtitle: p == null
                    ? null
                    : l10n.paymentDocumentTitle(p.direction),
                actions: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: back,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: switch (async) {
                  AsyncValue(value: null, isLoading: true) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  AsyncValue(value: null) => MkEmptyState(
                    icon: Icons.search_off,
                    title: l10n.paymentNotFound,
                  ),
                  AsyncValue(value: final p?) => ListView(
                    padding: const EdgeInsets.all(MkSpacing.lg),
                    children: [
                      Wrap(
                        spacing: MkSpacing.md,
                        runSpacing: MkSpacing.sm,
                        children: [
                          MkButton(
                            key: const ValueKey('payment-detail-print'),
                            label: l10n.paymentPrintReceipt,
                            icon: Icons.print_outlined,
                            variant: MkButtonVariant.secondary,
                            onPressed: () => PaymentReceipts.print(ref, p),
                          ),
                          MkButton(
                            key: const ValueKey('payment-detail-share'),
                            label: l10n.paymentShareReceipt,
                            icon: Icons.share_outlined,
                            variant: MkButtonVariant.secondary,
                            onPressed: () => PaymentReceipts.share(ref, p),
                          ),
                          if (p.isPendingCheque && canCreate)
                            MkButton(
                              key: const ValueKey('payment-clear'),
                              label: l10n.paymentMarkCleared,
                              icon: Icons.check_circle_outline,
                              variant: MkButtonVariant.secondary,
                              onPressed: () => _clear(context, ref),
                            ),
                          if (p.isPendingCheque && canReverse)
                            MkButton(
                              key: const ValueKey('payment-bounce'),
                              label: l10n.paymentMarkBounced,
                              icon: Icons.block,
                              variant: MkButtonVariant.danger,
                              onPressed: () => _bounce(context, ref),
                            ),
                          if (!p.isReversed && canReverse)
                            MkButton(
                              key: const ValueKey('payment-reverse'),
                              label: l10n.paymentReverse,
                              icon: Icons.undo,
                              variant: MkButtonVariant.danger,
                              onPressed: () => _reverse(context, ref),
                            ),
                        ],
                      ),
                      const SizedBox(height: MkSpacing.md),
                      _Details(payment: p),
                    ],
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = payment;
    Widget row(String label, Widget value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: MkSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: value),
        ],
      ),
    );
    return MkCard(
      key: const ValueKey('payment-details'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            l10n.khataFieldParty,
            InkWell(
              onTap: () => context.go(PartyRoutes.detail(p.partyId)),
              child: Text(
                p.partyCode == null
                    ? p.partyName
                    : '${p.partyName} · ${p.partyCode}',
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ),
          row(
            l10n.paymentsColType,
            Text(l10n.paymentDirectionName(p.direction)),
          ),
          row(
            l10n.paymentFieldAmount,
            MkMoneyText(
              p.amount,
              size: 18,
              tone: p.direction == PaymentDirection.toParty
                  ? MkMoneyTone.udhaar
                  : MkMoneyTone.jama,
            ),
          ),
          row(
            l10n.paymentFieldDate,
            Text(AppFormat.ledgerDate(context, p.entryDate)),
          ),
          row(l10n.paymentFieldMode, Text(l10n.paymentModeName(p.mode))),
          if (p.accountName != null)
            row(l10n.paymentFieldAccount, Text(p.accountName!)),
          if (p.reference != null)
            row(l10n.paymentFieldReference, Text(p.reference!)),
          if (p.chequeNo != null)
            row(l10n.paymentFieldChequeNo, Text(p.chequeNo!)),
          if (p.chequeDate != null)
            row(
              l10n.paymentFieldChequeDate,
              Text(AppFormat.ledgerDate(context, p.chequeDate!)),
            ),
          if (p.chequeStatus != null)
            row(
              l10n.paymentsColStatus,
              Text(l10n.chequeStatusName(p.chequeStatus!)),
            ),
          if (p.narration != null)
            row(l10n.paymentFieldNarration, Text(p.narration!)),
          if (p.isReversed)
            row(
              l10n.paymentsColStatus,
              MkRoleChip(label: l10n.paymentStatusReversed, warning: true),
            ),
        ],
      ),
    );
  }
}

/// Asks for the bounce date (the reversal is dated that day).
class _BounceDialog extends StatefulWidget {
  const _BounceDialog();

  @override
  State<_BounceDialog> createState() => _BounceDialogState();
}

class _BounceDialogState extends State<_BounceDialog> {
  LedgerDate _date = LedgerDate.fromDateTime(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkDialog(
      title: l10n.paymentBounceTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.paymentBounceBody),
          const SizedBox(height: MkSpacing.md),
          PaymentDateField(
            key: const ValueKey('payment-bounce-date'),
            label: l10n.paymentBounceDate,
            date: _date,
            onChanged: (d) => setState(() => _date = d),
          ),
        ],
      ),
      actions: [
        MkButton(
          label: l10n.commonCancel,
          variant: MkButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        MkButton(
          key: const ValueKey('payment-bounce-confirm'),
          label: l10n.paymentMarkBounced,
          icon: Icons.block,
          variant: MkButtonVariant.danger,
          onPressed: () => Navigator.of(context).pop(_date),
        ),
      ],
    );
  }
}
