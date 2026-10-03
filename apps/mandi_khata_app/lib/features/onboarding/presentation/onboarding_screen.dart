import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mandi_khata_app/core/sync/presentation/sync_status_chip.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_providers.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_steps_business.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_steps_finish.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_steps_rates.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_widgets.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

abstract final class OnboardingRoutes {
  static const wizard = '/onboarding';
}

/// First-run wizard for a new business (owner): business details, mandi and
/// state, crops, default commission and charges, interest defaults, language,
/// invite the munshi. Each step saves on Next to the local database, so it
/// works offline, and the finished-step count is a setting, so the wizard
/// resumes where it stopped (also on another device).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int? _step;
  bool _finished = false;
  bool _skipping = false;

  Future<void> _advance(int from) async {
    await ref.read(onboardingActionsProvider).markProgress(from + 1);
    if (mounted) setState(() => _step = from + 1);
  }

  Future<void> _skip() async {
    setState(() => _skipping = true);
    await ref.read(onboardingActionsProvider).skip();
    if (mounted) context.go(GateRoutes.home);
  }

  String _stepTitle(AppLocalizations l10n, OnboardingStep s) => switch (s) {
    OnboardingStep.business => l10n.onboardingBusinessTitle,
    OnboardingStep.mandi => l10n.onboardingMandiTitle,
    OnboardingStep.crops => l10n.onboardingCropsTitle,
    OnboardingStep.charges => l10n.onboardingChargesTitle,
    OnboardingStep.interest => l10n.onboardingInterestTitle,
    OnboardingStep.language => l10n.onboardingLanguageTitle,
    OnboardingStep.invite => l10n.onboardingInviteTitle,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final member = ref.watch(activeMembershipProvider);
    final finishedSteps = ref.watch(onboardingFinishedProvider);
    final status = ref.watch(onboardingStatusProvider);
    final tenant = ref.watch(tenantRowProvider).value;
    final ready = finishedSteps != null && status != null && tenant != null;

    if (ready && _step == null) {
      // Re-running a completed or skipped wizard starts again at step 1.
      _step = status == 'in_progress'
          ? OnboardingRules.resume(finishedSteps).index
          : 0;
    }
    final step = _step;

    Widget body;
    if (member == null || !ready || step == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (!member.can(Permission.adminManage)) {
      body = MkEmptyState(
        icon: Icons.lock_outline,
        title: l10n.onboardingOwnerOnly,
      );
    } else if (_finished) {
      body = const OnboardingDone();
    } else {
      final current = OnboardingStep.values[step];
      final ctx = StepContext(
        index: step,
        onNext: () => _advance(step),
        onBack: step == 0 ? null : () => setState(() => _step = step - 1),
      );
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingStepOf(step + 1, OnboardingStep.values.length),
            key: const ValueKey('step-counter'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: MkSpacing.xs),
          LinearProgressIndicator(
            value: (step + 1) / OnboardingStep.values.length,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: MkSpacing.xs),
          Text(
            _stepTitle(l10n, current),
            style: TextStyle(color: MkTokens.of(context).textMuted),
          ),
          const SizedBox(height: MkSpacing.lg),
          KeyedSubtree(
            key: ValueKey('step-${current.name}'),
            child: switch (current) {
              OnboardingStep.business => BusinessStep(step: ctx),
              OnboardingStep.mandi => MandiStep(step: ctx),
              OnboardingStep.crops => CropsStep(step: ctx),
              OnboardingStep.charges => ChargesStep(step: ctx),
              OnboardingStep.interest => InterestStep(step: ctx),
              OnboardingStep.language => LanguageStep(step: ctx),
              OnboardingStep.invite => InviteStep(
                step: ctx,
                onFinished: () => setState(() => _finished = true),
              ),
            },
          ),
          const SizedBox(height: MkSpacing.md),
          Center(
            child: TextButton(
              key: const ValueKey('onboarding-skip'),
              onPressed: _skipping ? null : _skip,
              child: Text(l10n.onboardingSkip),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.onboardingTitle,
            subtitle: member?.tenantName,
            languages: appLanguages,
            language: Localizations.localeOf(context).languageCode,
            onLanguage: (c) => ref.read(appLanguageProvider.notifier).set(c),
            actions: const [SyncStatusChip()],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.all(MkSpacing.lg),
                  children: [body],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
