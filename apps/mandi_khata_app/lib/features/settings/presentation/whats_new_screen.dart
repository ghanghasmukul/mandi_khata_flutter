import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// Release notes shown in the app, newest first, in the user's language.
/// To add a release: one ARB key `changelogV<major><minor><patch>` in all
/// three languages and one line here (docs/release.md).
List<({String version, String notes})> changelog(AppLocalizations l10n) => [
  (version: '1.0.0', notes: l10n.changelogV100),
];

class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  static const route = '/whats-new';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            title: l10n.whatsNewTitle,
            actions: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.arrow_back),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(MkSpacing.lg),
              children: [
                for (final r in changelog(l10n))
                  MkCard(
                    key: ValueKey('release-${r.version}'),
                    title: l10n.whatsNewVersion(r.version),
                    child: Text(r.notes),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
