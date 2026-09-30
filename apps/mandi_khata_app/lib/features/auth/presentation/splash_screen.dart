import 'package:flutter/material.dart';
import 'package:mandi_khata_app/features/auth/presentation/auth_layout.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';

/// Shown briefly while a new user's local data is being prepared.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: AppLocalizations.of(context).splashLoading,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
