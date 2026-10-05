import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/features/interest/presentation/interest_posting_providers.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_detail_cards.dart';
import 'package:mandi_khata_app/features/settings/presentation/setting_labels.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Posts the interest charged so far on a party's khata ([loanId] null) or
/// on one loan, as one udhaar entry. Shows what will be posted first and
/// writes nothing until the user confirms. Needs `loans.manage`.
Future<bool?> showPostInterestDialog(
  BuildContext context, {
  required String partyId,
  String? loanId,
}) => showDialog<bool>(
  context: context,
  barrierColor: MkColors.scrim,
  builder: (_) => PostInterestDialog(partyId: partyId, loanId: loanId),
);

class PostInterestDialog extends ConsumerStatefulWidget {
  const PostInterestDialog({required this.partyId, this.loanId, super.key});

  final String partyId;
  final String? loanId;

  @override
  ConsumerState<PostInterestDialog> createState() => _PostInterestDialogState();
}

class _PostInterestDialogState extends ConsumerState<PostInterestDialog> {
  final LedgerDate _today = LedgerDate.fromDateTime(DateTime.now());
  bool _saving = false;
  String? _error;

  Future<void> _post(PostingCandidate c) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref.read(interestPostingWriterProvider).post([c.plan]);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final error = l10n.postingError(result);
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(l10n.postInterestDone(c.amount.format()))),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(
      postingCandidatesProvider(_today, partyId: widget.partyId),
    );
    final candidate = async.value
        ?.where((c) => c.loanId == widget.loanId)
        .firstOrNull;

    return MkDialog(
      title: l10n.postInterestTitle,
      content: SingleChildScrollView(
        child: switch (async) {
          AsyncValue(hasValue: false) => const Center(
            child: CircularProgressIndicator(),
          ),
          _ when candidate == null => Text(
            l10n.postInterestNone,
            key: const ValueKey('post-none'),
          ),
          _ => _Preview(candidate: candidate, error: _error),
        },
      ),
      actions: [
        MkButton(
          label: l10n.commonCancel,
          variant: MkButtonVariant.ghost,
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
        ),
        if (candidate != null && !candidate.alreadyPosted)
          MkButton(
            key: const ValueKey('post-confirm'),
            label: l10n.postInterestConfirm(candidate.amount.format()),
            icon: Icons.check,
            onPressed: _saving ? null : () => _post(candidate),
          ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.candidate, this.error});

  final PostingCandidate candidate;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plan = candidate.plan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.postInterestIntro,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: MkSpacing.md),
        loanFact(context, l10n.postColParty, Text(candidate.partyName)),
        loanFact(
          context,
          l10n.postColAccount,
          Text(
            candidate.loanNo == null
                ? l10n.postAccountKhata
                : l10n.postAccountLoan(candidate.loanNo!),
          ),
        ),
        loanFact(
          context,
          l10n.postColPeriod,
          Text(
            l10n.postPeriod(
              AppFormat.ledgerDate(context, plan.from),
              AppFormat.ledgerDate(context, plan.to),
            ),
          ),
        ),
        loanFact(
          context,
          l10n.postColTerms,
          Text(
            l10n.postTerms(
              plan.ratePa.toString(),
              l10n.settingOption('interest.method', plan.method.name),
            ),
          ),
        ),
        loanFact(
          context,
          l10n.loanPrincipalOutstanding,
          MkMoneyText(candidate.principal),
        ),
        const Divider(),
        Text(
          l10n.postInterestAmount,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        MkMoneyText(
          candidate.amount,
          key: const ValueKey('post-amount'),
          size: 28,
        ),
        if (candidate.alreadyPosted) ...[
          const SizedBox(height: MkSpacing.sm),
          Text(l10n.postSkipAlready, key: const ValueKey('post-already')),
        ],
        if (error != null) ...[
          const SizedBox(height: MkSpacing.md),
          Text(
            error!,
            key: const ValueKey('post-error'),
            style: TextStyle(color: MkTokens.of(context).udhaar),
          ),
        ],
      ],
    );
  }
}
