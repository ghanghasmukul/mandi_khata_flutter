import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/auth/app_lock/app_lock.dart';
import 'package:mandi_khata_app/core/utils/clock.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/auth/presentation/pin_pad.dart';
import 'package:mandi_khata_app/features/auth/presentation/sign_out_flow.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Asks for the app PIN (or fingerprint on Android). Unlocking moves the
/// router on by itself.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _checking = false;
  bool _wrong = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Re-render every second while a cooldown counts down.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_cooldownLeft() > 0 && mounted) setState(() {});
    });
    if (ref.read(appLockProvider).biometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _biometric());
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int _cooldownLeft() {
    final until = ref.read(appLockProvider).cooldownUntil;
    if (until == null) return 0;
    final left = until.difference(ref.read(clockProvider)()).inSeconds;
    return left > 0 ? left + 1 : 0;
  }

  Future<void> _unlock(String pin) async {
    setState(() {
      _checking = true;
      _wrong = false;
    });
    final result = await ref.read(appLockProvider.notifier).unlock(pin);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _wrong = result == UnlockResult.wrongPin;
    });
  }

  Future<void> _biometric() async {
    final reason = AppLocalizations.of(context).lockBiometricReason;
    await ref.read(appLockProvider.notifier).unlockWithBiometric(reason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lock = ref.watch(appLockProvider);
    final cooldown = _cooldownLeft();
    final error = cooldown > 0
        ? l10n.lockCooldown(cooldown)
        : _wrong
        ? l10n.lockWrongPin
        : null;

    return AuthLayout(
      title: l10n.lockTitle,
      maxWidth: 360,
      child: Column(
        children: [
          PinPad(
            autoSubmitLength: lock.pinLength,
            enabled: !_checking && cooldown == 0,
            errorText: error,
            onSubmit: _unlock,
          ),
          const SizedBox(height: MkSpacing.lg),
          if (lock.biometricEnabled)
            MkButton(
              label: l10n.lockUseBiometric,
              icon: Icons.fingerprint,
              variant: MkButtonVariant.secondary,
              onPressed: _biometric,
            ),
          const SizedBox(height: MkSpacing.sm),
          MkButton(
            label: l10n.lockForgotPin,
            variant: MkButtonVariant.ghost,
            onPressed: () => confirmAndSignOut(context, ref),
          ),
        ],
      ),
    );
  }
}
