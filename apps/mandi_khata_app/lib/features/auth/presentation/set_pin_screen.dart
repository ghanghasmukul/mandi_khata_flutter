import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/auth/app_lock/app_lock.dart';
import 'package:mandi_khata_app/core/auth/app_lock/biometric_auth.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/auth/presentation/pin_pad.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Sets or changes the app PIN: enter, then confirm. Offered once after the
/// first sign-in (skippable) and from the account menu.
class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  String? _first;
  bool _mismatch = false;
  bool _saving = false;
  bool _biometric = false;

  bool get _isFirstRunPrompt => ref.read(gateStepProvider) == GateStep.setupPin;

  Future<void> _onPin(String pin) async {
    final first = _first;
    if (first == null) {
      setState(() {
        _first = pin;
        _mismatch = false;
      });
      return;
    }
    if (pin != first) {
      setState(() {
        _first = null;
        _mismatch = true;
      });
      return;
    }
    setState(() => _saving = true);
    final lock = ref.read(appLockProvider.notifier);
    await lock.setPin(pin);
    await lock.setBiometric(enabled: _biometric);
    if (!mounted) return;
    MkToast.show(
      context,
      AppLocalizations.of(context).pinSaved,
      tone: MkToastTone.success,
    );
    context.go(GateRoutes.home);
  }

  Future<void> _cancel() async {
    if (_isFirstRunPrompt) {
      await ref.read(appLockProvider.notifier).skipSetup();
    }
    if (mounted) context.go(GateRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firstRun = ref.watch(gateStepProvider) == GateStep.setupPin;
    final canUseBiometric =
        ref.watch(biometricAvailableProvider).value ?? false;
    return AuthLayout(
      title: _first == null ? l10n.pinSetupTitle : l10n.pinConfirmTitle,
      subtitle: l10n.pinSetupBody,
      maxWidth: 360,
      child: Column(
        children: [
          PinPad(
            // A new pad for the confirm step so the dots start empty.
            key: ValueKey(_first == null),
            enabled: !_saving,
            errorText: _mismatch ? l10n.pinMismatch : null,
            onSubmit: _onPin,
          ),
          if (canUseBiometric)
            SwitchListTile(
              value: _biometric,
              onChanged: (v) => setState(() => _biometric = v),
              title: Text(l10n.pinBiometricOption),
            ),
          const SizedBox(height: MkSpacing.sm),
          MkButton(
            label: firstRun ? l10n.pinSkip : l10n.commonCancel,
            variant: MkButtonVariant.ghost,
            onPressed: _saving ? null : _cancel,
          ),
        ],
      ),
    );
  }
}
