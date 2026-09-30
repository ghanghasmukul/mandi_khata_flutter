import 'package:flutter/material.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/features/auth/presentation/email_login_form.dart';
import 'package:mandi_khata_app/features/auth/presentation/phone_login_form.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

enum _Method { phone, email }

/// Phone OTP (default, +91) with email + password as a fallback for web and
/// accountants. Signing in moves the router on by itself.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _Method _method = _Method.phone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthLayout(
      title: l10n.loginTitle,
      subtitle: _method == _Method.phone ? l10n.loginSubtitle : null,
      child: MkCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<_Method>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _Method.phone,
                  icon: const Icon(Icons.smartphone),
                  label: Text(l10n.loginTabPhone),
                ),
                ButtonSegment(
                  value: _Method.email,
                  icon: const Icon(Icons.alternate_email),
                  label: Text(l10n.loginTabEmail),
                ),
              ],
              selected: {_method},
              onSelectionChanged: (s) => setState(() => _method = s.first),
            ),
            const SizedBox(height: MkSpacing.xl),
            switch (_method) {
              _Method.phone => const PhoneLoginForm(),
              _Method.email => const EmailLoginForm(),
            },
          ],
        ),
      ),
    );
  }
}
