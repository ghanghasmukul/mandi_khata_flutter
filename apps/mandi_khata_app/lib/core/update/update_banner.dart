import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/update/update_checker.dart';
import 'package:mandi_khata_app/core/update/update_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Version 1.2.0 is available": a thin strip above the dashboard. Nothing is
/// drawn while the check runs, offline, or when this is the newest version.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(updateStatusProvider).value;
    if (status is! UpdateAvailable) return const SizedBox.shrink();
    final dismissed = ref.watch(dismissedUpdateProvider);
    if (!status.required && dismissed == status.latest.toString()) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final version = status.latest.toString();
    return Material(
      // Fixed colours with white text: readable in light and dark themes.
      color: status.required
          ? const Color(0xFFB91C1C)
          : const Color(0xFF8A6420),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MkSpacing.lg,
          vertical: MkSpacing.sm,
        ),
        child: Wrap(
          key: const ValueKey('update-banner'),
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: MkSpacing.md,
          children: [
            Text(
              status.required
                  ? l10n.updateRequiredTitle(version)
                  : l10n.updateAvailableTitle(version),
              style: const TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () => launchUrl(
                Uri.parse(status.url),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(
                l10n.updateDownload,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!status.required)
              TextButton(
                onPressed: () => ref
                    .read(dismissedUpdateProvider.notifier)
                    .dismiss(status.latest),
                child: Text(
                  l10n.updateLater,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
