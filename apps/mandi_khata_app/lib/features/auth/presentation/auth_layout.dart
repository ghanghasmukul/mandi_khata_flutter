import 'package:flutter/material.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Centred brand + card layout shared by the login, business picker, PIN
/// and lock screens. Scrolls on small phones and with the keyboard open.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.maxWidth = 420,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MkSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: MkSidebarBrand(
                      appName: 'Mandi Khata',
                      compact: true,
                    ),
                  ),
                  const SizedBox(height: MkSpacing.xl),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: MkSpacing.sm),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: MkTokens.of(context).textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: MkSpacing.xl),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension AuthFailureText on AppLocalizations {
  String authFailure(AuthFailureKind kind) => switch (kind) {
    AuthFailureKind.notConfigured => authErrorNotConfigured,
    AuthFailureKind.network => authErrorNetwork,
    AuthFailureKind.invalidOtp => authErrorInvalidOtp,
    AuthFailureKind.invalidCredentials => authErrorInvalidCredentials,
    AuthFailureKind.rateLimited => authErrorRateLimited,
    AuthFailureKind.smsUnavailable => authErrorSms,
    AuthFailureKind.unknown => authErrorUnknown,
  };

  String roleName(MemberRole role) => switch (role) {
    MemberRole.owner => roleOwner,
    MemberRole.accountant => roleAccountant,
    MemberRole.munshi => roleMunshi,
    MemberRole.custom => roleCustom,
  };
}
