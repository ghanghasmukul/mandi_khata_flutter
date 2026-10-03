import 'package:flutter/material.dart';
import 'package:mandi_khata_app/features/onboarding/data/onboarding_repository.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// What every wizard step is given by the screen.
class StepContext {
  const StepContext({
    required this.index,
    required this.onNext,
    required this.onBack,
  });

  /// Position (0-based) of this step.
  final int index;

  /// Called after the step saved its values: moves on.
  final Future<void> Function() onNext;

  /// Back one step (null on the first).
  final VoidCallback? onBack;
}

/// Title, helper text, the fields and the Back / Next row of one step.
class StepFrame extends StatelessWidget {
  const StepFrame({
    required this.title,
    required this.children,
    required this.onNext,
    super.key,
    this.subtitle,
    this.onBack,
    this.nextLabel,
    this.busy = false,
    this.error,
    this.extraAction,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final String? nextLabel;
  final bool busy;
  final String? error;

  /// Optional secondary action beside Next (e.g. "Skip").
  final Widget? extraAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return MkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: MkSpacing.xs),
            Text(
              subtitle!,
              style: TextStyle(color: MkTokens.of(context).textMuted),
            ),
          ],
          const SizedBox(height: MkSpacing.lg),
          ...children,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.md),
              child: Text(
                error!,
                key: const ValueKey('step-error'),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          const SizedBox(height: MkSpacing.xl),
          Wrap(
            spacing: MkSpacing.sm,
            runSpacing: MkSpacing.sm,
            alignment: WrapAlignment.end,
            children: [
              if (onBack != null)
                MkButton(
                  key: const ValueKey('step-back'),
                  label: l10n.onboardingBack,
                  icon: Icons.arrow_back,
                  variant: MkButtonVariant.secondary,
                  onPressed: busy ? null : onBack,
                ),
              ?extraAction,
              MkButton(
                key: const ValueKey('step-next'),
                label: nextLabel ?? l10n.onboardingNext,
                busy: busy,
                onPressed: busy ? null : onNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Spacing between fields.
const Widget fieldGap = SizedBox(height: MkSpacing.md);

extension OnboardingFailureText on AppLocalizations {
  String onboardingFailure(OnboardingSaveFailure f) => switch (f) {
    OnboardingSaveFailure.notPermitted => onboardingErrNotPermitted,
    OnboardingSaveFailure.invalid => onboardingErrInvalid,
    OnboardingSaveFailure.notFound => onboardingErrInvalid,
  };
}
