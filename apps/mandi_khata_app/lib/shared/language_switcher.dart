import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/i18n/app_language.dart';
import 'package:mk_ui/mk_ui.dart';

/// EN / हिं / ਪੰ switch bound to [appLanguageProvider].
class AppLanguageSwitcher extends ConsumerWidget {
  const AppLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MkLanguageSwitcher(
    languages: appLanguages,
    selected: Localizations.localeOf(context).languageCode,
    onSelect: (code) => ref.read(appLanguageProvider.notifier).set(code),
  );
}
