import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/auth/phone_number.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Two steps: mobile number → 6-digit SMS code. India (+91) only for now.
class PhoneLoginForm extends ConsumerStatefulWidget {
  const PhoneLoginForm({super.key});

  /// Wait before the code can be sent again.
  static const resendDelay = 30;

  @override
  ConsumerState<PhoneLoginForm> createState() => _PhoneLoginFormState();
}

class _PhoneLoginFormState extends ConsumerState<PhoneLoginForm> {
  final _phone = TextEditingController();
  final _code = TextEditingController();

  /// E.164 number the code was sent to; null while entering the number.
  String? _sentTo;
  bool _busy = false;
  String? _error;
  int _resendIn = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  AuthRepository get _auth => ref.read(authRepositoryProvider);

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).authFailure(e.kind),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() async {
    final phone = normaliseIndianMobile(_phone.text);
    if (phone == null) {
      setState(() => _error = AppLocalizations.of(context).loginPhoneInvalid);
      return;
    }
    await _run(() async {
      await _auth.sendOtp(phone);
      _code.clear();
      setState(() => _sentTo = phone);
      _startResendTimer();
    });
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendIn = PhoneLoginForm.resendDelay);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  Future<void> _verify() async {
    final phone = _sentTo;
    if (phone == null) return;
    final code = _code.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(
        () => _error = AppLocalizations.of(context).loginOtpInvalidFormat,
      );
      return;
    }
    await _run(() => _auth.verifyOtp(phone: phone, code: code));
  }

  void _changeNumber() {
    _timer?.cancel();
    setState(() {
      _sentTo = null;
      _error = null;
      _resendIn = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sentTo = _sentTo;
    if (sentTo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MkTextField(
            key: const ValueKey('login-phone'),
            label: l10n.loginPhoneLabel,
            controller: _phone,
            autofocus: true,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d +\-]')),
              LengthLimitingTextInputFormatter(16),
            ],
            prefix: const Text('+91 '),
            errorText: _error,
            onSubmitted: (_) => _sendCode(),
          ),
          const SizedBox(height: MkSpacing.xl),
          MkButton(
            label: l10n.loginSendOtp,
            icon: Icons.sms_outlined,
            expand: true,
            busy: _busy,
            onPressed: _busy ? null : _sendCode,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.loginOtpSentTo(formatIndianMobile(sentTo))),
        const SizedBox(height: MkSpacing.md),
        MkTextField(
          key: const ValueKey('login-otp'),
          label: l10n.loginOtpLabel,
          controller: _code,
          autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          errorText: _error,
          onSubmitted: (_) => _verify(),
        ),
        const SizedBox(height: MkSpacing.xl),
        MkButton(
          label: l10n.loginVerify,
          icon: Icons.verified_user_outlined,
          expand: true,
          busy: _busy,
          onPressed: _busy ? null : _verify,
        ),
        const SizedBox(height: MkSpacing.sm),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            MkButton(
              label: l10n.loginChangeNumber,
              variant: MkButtonVariant.ghost,
              onPressed: _busy ? null : _changeNumber,
            ),
            MkButton(
              label: _resendIn > 0
                  ? l10n.loginResendIn(_resendIn)
                  : l10n.loginResend,
              variant: MkButtonVariant.ghost,
              onPressed: _busy || _resendIn > 0 ? null : _sendCode,
            ),
          ],
        ),
      ],
    );
  }
}
