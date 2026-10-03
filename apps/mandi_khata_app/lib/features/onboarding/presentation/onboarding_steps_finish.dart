import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_providers.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_widgets.dart';
import 'package:mandi_khata_app/features/opening_balances/presentation/opening_balances_screen.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/team/presentation/invite_dialog.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Step 6: the business's default language (also switches the app now).
class LanguageStep extends ConsumerStatefulWidget {
  const LanguageStep({required this.step, super.key});

  final StepContext step;

  @override
  ConsumerState<LanguageStep> createState() => _LanguageStepState();
}

class _LanguageStepState extends ConsumerState<LanguageStep> {
  String? _error;
  bool _busy = false;

  Future<void> _pick(String code) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final failure = await ref
        .read(onboardingActionsProvider)
        .saveLanguage(code);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = failure == null ? null : l10n.onboardingErrNotPermitted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;
    const names = {'en': 'English', 'hi': 'हिन्दी', 'pa': 'ਪੰਜਾਬੀ'};
    return StepFrame(
      title: l10n.onboardingLanguageTitle,
      subtitle: l10n.onboardingLanguageHint,
      error: _error,
      onBack: widget.step.onBack,
      onNext: _busy ? null : widget.step.onNext,
      children: [
        for (final MapEntry(:key, :value) in names.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: MkSpacing.sm),
            child: MkCard(
              key: ValueKey('lang-$key'),
              onTap: _busy ? null : () => _pick(key),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (current == key)
                      const Icon(Icons.check_circle, color: MkColors.brand),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Step 7: invite the munshi (the 1.8 invite flow), then finish.
class InviteStep extends ConsumerStatefulWidget {
  const InviteStep({required this.step, required this.onFinished, super.key});

  final StepContext step;

  /// Called once the wizard is marked complete.
  final VoidCallback onFinished;

  @override
  ConsumerState<InviteStep> createState() => _InviteStepState();
}

class _InviteStepState extends ConsumerState<InviteStep> {
  String? _error;
  bool _busy = false;

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final failure = await ref.read(onboardingActionsProvider).complete();
    if (!mounted) return;
    if (failure != null) {
      setState(() {
        _busy = false;
        _error = l10n.onboardingErrNotPermitted;
      });
      return;
    }
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StepFrame(
      title: l10n.onboardingInviteTitle,
      subtitle: l10n.onboardingInviteHint,
      busy: _busy,
      error: _error,
      nextLabel: l10n.onboardingFinish,
      onBack: widget.step.onBack,
      onNext: _finish,
      children: [
        MkButton(
          key: const ValueKey('onboarding-invite'),
          label: l10n.onboardingInviteButton,
          icon: Icons.person_add_alt_1,
          variant: MkButtonVariant.secondary,
          onPressed: _busy ? null : () => InviteDialog.show(context),
        ),
        const SizedBox(height: MkSpacing.sm),
        Text(
          l10n.onboardingInviteLater,
          style: TextStyle(color: MkTokens.of(context).textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

/// After the last step: what to do next.
class OnboardingDone extends StatelessWidget {
  const OnboardingDone({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MkEmptyState(
            icon: Icons.check_circle_outline,
            title: l10n.onboardingDoneTitle,
            message: l10n.onboardingDoneBody,
          ),
          const SizedBox(height: MkSpacing.lg),
          MkButton(
            key: const ValueKey('done-import'),
            label: l10n.onboardingDoneImport,
            icon: Icons.upload_file_outlined,
            onPressed: () => context.go(OpeningBalanceRoutes.import),
          ),
          const SizedBox(height: MkSpacing.sm),
          MkButton(
            key: const ValueKey('done-party'),
            label: l10n.onboardingDoneAddParty,
            icon: Icons.person_add_alt_1,
            variant: MkButtonVariant.secondary,
            onPressed: () => context.go(PartyRoutes.create),
          ),
          const SizedBox(height: MkSpacing.sm),
          MkButton(
            key: const ValueKey('done-home'),
            label: l10n.onboardingDoneHome,
            variant: MkButtonVariant.ghost,
            onPressed: () => context.go(GateRoutes.home),
          ),
        ],
      ),
    );
  }
}
