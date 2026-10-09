import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/subscription/data/signup_repository.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:uuid/uuid.dart';

/// "Create your business": the self-serve start of a free trial. Needs the
/// internet once; afterwards the business arrives by sync and the setup
/// wizard (step 1.9) opens by itself.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _name = TextEditingController();
  final _mandi = TextEditingController();
  final _phone = TextEditingController();
  final _referral = TextEditingController();
  String _state = '03';
  String _type = 'arhtiya';
  bool _busy = false;
  String? _error;
  String? _nameError;

  // One id per form, so a retry cannot create a second business.
  final String _tenantId = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionProvider);
    if (session is SignedIn) {
      final phone = session.user.phone;
      if (phone != null && phone.length >= 10) {
        _phone.text = phone.substring(phone.length - 10);
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _mandi.dispose();
    _phone.dispose();
    _referral.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final input = SignupInput(
      name: _name.text.trim(),
      stateCode: _state,
      businessType: _type,
      mandiName: _mandi.text.trim(),
      phone: _phone.text.trim(),
      referralCode: _referral.text.trim(),
    );
    if (input.firstProblem == 'name') {
      setState(() => _nameError = l10n.signupNameRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _nameError = null;
    });
    final repo = ref.read(signupRepositoryProvider);
    final result = await repo.signUp(input, tenantId: _tenantId);
    if (!mounted) return;
    if (result.failure != null) {
      setState(() {
        _busy = false;
        _error = switch (result.failure!) {
          SignupFailure.offline => l10n.signupOffline,
          SignupFailure.closed => l10n.signupClosed,
          SignupFailure.limitReached => l10n.signupLimit,
          SignupFailure.invalid => l10n.signupInvalid,
          SignupFailure.other => l10n.signupFailed,
        };
      });
      return;
    }
    // The business arrives through sync; the picker takes it from here.
    context.go(GateRoutes.selectTenant);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return AuthLayout(
      title: l10n.signupTitle,
      subtitle: l10n.signupSubtitle,
      maxWidth: 480,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MkTextField(
            key: const ValueKey('signup-name'),
            controller: _name,
            label: l10n.signupName,
            errorText: _nameError,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: MkSpacing.md),
          Text(l10n.signupType, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: MkSpacing.xs),
          SegmentedButton<String>(
            key: const ValueKey('signup-type'),
            segments: [
              ButtonSegment(
                value: 'arhtiya',
                label: Text(l10n.signupTypeArhtiya),
              ),
              ButtonSegment(value: 'shop', label: Text(l10n.signupTypeShop)),
              ButtonSegment(value: 'both', label: Text(l10n.signupTypeBoth)),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: MkSpacing.md),
          DropdownMenu<String>(
            key: const ValueKey('signup-state'),
            label: Text(l10n.onboardingState),
            initialSelection: _state,
            expandedInsets: EdgeInsets.zero,
            onSelected: (v) => setState(() => _state = v ?? _state),
            dropdownMenuEntries: [
              for (final s in OnboardingRules.states)
                DropdownMenuEntry(value: s.code, label: s.nameIn(lang)),
            ],
          ),
          const SizedBox(height: MkSpacing.md),
          MkTextField(
            key: const ValueKey('signup-mandi'),
            controller: _mandi,
            label: l10n.onboardingMandiName,
            hint: l10n.onboardingMandiNameHint,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: MkSpacing.md),
          MkTextField(
            key: const ValueKey('signup-phone'),
            controller: _phone,
            label: l10n.signupPhone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: MkSpacing.md),
          MkTextField(
            key: const ValueKey('signup-referral'),
            controller: _referral,
            label: l10n.signupReferral,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: MkSpacing.md),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: MkSpacing.lg),
          MkButton(
            key: const ValueKey('signup-submit'),
            label: l10n.signupCreate,
            icon: Icons.rocket_launch_outlined,
            busy: _busy,
            onPressed: _busy ? null : _submit,
            expand: true,
          ),
          const SizedBox(height: MkSpacing.sm),
          Text(
            l10n.signupTrialNote,
            textAlign: TextAlign.center,
            style: TextStyle(color: MkTokens.of(context).textMuted),
          ),
          TextButton(
            onPressed: _busy ? null : () => context.go(GateRoutes.selectTenant),
            child: Text(l10n.signupBack),
          ),
        ],
      ),
    );
  }
}
