import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

extension OpeningLabels on AppLocalizations {
  String openingError(OpeningRowError e, String? detail) => switch (e) {
    OpeningRowError.nameMissing => obErrNameMissing,
    OpeningRowError.amountInvalid => obErrAmountInvalid,
    OpeningRowError.amountNegative => obErrAmountNegative,
    OpeningRowError.sideMissing => obErrSideMissing,
    OpeningRowError.sideUnknown => obErrSideUnknown,
    OpeningRowError.sideConflict => obErrSideConflict,
    OpeningRowError.mobileInvalid => obErrMobileInvalid,
    OpeningRowError.roleUnknown => obErrRoleUnknown,
    OpeningRowError.duplicateInFile => obErrDuplicateInFile(detail ?? ''),
    OpeningRowError.possibleDuplicate => obErrPossibleDuplicate(detail ?? ''),
    OpeningRowError.codeTaken => obErrCodeTaken(detail ?? ''),
    OpeningRowError.alreadyHasOpening => obErrAlreadyHasOpening,
  };

  String openingWarning(OpeningRowWarning w) => switch (w) {
    OpeningRowWarning.noAmount => obWarnNoAmount,
    OpeningRowWarning.nameDiffers => obWarnNameDiffers,
    OpeningRowWarning.mobileOfOther => obWarnMobileOfOther,
  };

  String openingProblem(SheetProblem p) => switch (p) {
    SheetProblem.empty => obProblemEmpty,
    SheetProblem.noNameColumn => obProblemNoName,
    SheetProblem.noAmountColumn => obProblemNoAmount,
    SheetProblem.tooManyRows => obProblemTooMany(OpeningBalanceImport.maxRows),
  };
}

/// Counts and totals of what would be imported.
class OpeningSummary extends StatelessWidget {
  const OpeningSummary({required this.preview, super.key});

  final OpeningPreview preview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: MkSpacing.md,
      runSpacing: MkSpacing.md,
      children: [
        _tile(l10n.obSumRows, '${preview.rows.length}'),
        _tile(l10n.obSumNewParties, '${preview.newParties}'),
        _tile(l10n.obSumMatched, '${preview.matchedParties}'),
        _tile(l10n.obSumProblems, '${preview.invalid.length}'),
        _tile(l10n.khataColUdhaar, preview.totalUdhaar.format()),
        _tile(l10n.khataColJama, preview.totalJama.format()),
        _tile(
          l10n.obSumNet,
          preview.net.abs().format(),
          note: preview.net.isZero
              ? null
              : preview.net.isPositive
              ? l10n.obNetWeOwe
              : l10n.obNetTheyOwe,
        ),
      ],
    );
  }

  Widget _tile(String label, String value, {String? note}) => SizedBox(
    width: 150,
    child: MkStatTile(label: label, value: value, sub: note),
  );
}

/// One row of the preview.
class OpeningRowTile extends StatelessWidget {
  const OpeningRowTile({required this.row, super.key});

  final OpeningRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final theme = Theme.of(context);
    final (icon, color) = row.hasError
        ? (Icons.error_outline, theme.colorScheme.error)
        : row.warnings.isNotEmpty
        ? (Icons.warning_amber_outlined, MkColors.gold)
        : (Icons.check_circle_outline, tokens.jama);
    final notes = [
      for (final e in row.errors) l10n.openingError(e, row.detail),
      for (final w in row.warnings) l10n.openingWarning(w),
    ];
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(vertical: MkSpacing.sm),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.border2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: MkSpacing.sm),
          SizedBox(
            width: 36,
            child: Text(
              '${row.number}',
              style: TextStyle(color: tokens.textMuted),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    if (row.name.isNotEmpty) row.name else '—',
                    if (row.village != null) row.village!,
                  ].join(' · '),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  [
                    if (row.code != null) row.code!,
                    if (row.matchedPartyName != null && !row.hasError)
                      l10n.obMatchedWith(row.matchedPartyName!)
                    else if (row.createsParty)
                      l10n.obNewParty(l10n.partyRole(row.role)),
                  ].join(' · '),
                  style: TextStyle(color: tokens.textMuted, fontSize: 12),
                ),
                for (final n in notes)
                  Text(n, style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
          ),
          if (row.side != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MkMoneyText(
                  row.amount,
                  tone: row.side == Side.jama
                      ? MkMoneyTone.jama
                      : MkMoneyTone.udhaar,
                ),
                Text(
                  row.side == Side.jama
                      ? l10n.khataColJama
                      : l10n.khataColUdhaar,
                  style: TextStyle(color: tokens.textMuted, fontSize: 11),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
