import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/subscription/subscription_providers.dart';
import 'package:mandi_khata_app/core/subscription/subscription_repository.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'announcement_banner.g.dart';

@riverpod
Stream<List<AnnouncementRow>> announcements(Ref ref) async* {
  final repo = await ref.watch(subscriptionRepositoryProvider.future);
  yield* repo.watchAnnouncements();
}

/// Announcements this device has already dismissed (kept on the device).
@Riverpod(keepAlive: true)
class DismissedAnnouncements extends _$DismissedAnnouncements {
  @override
  Set<String> build() => {
    ...ref.watch(appPrefsProvider).dismissedAnnouncements,
  };

  Future<void> dismiss(String id) async {
    state = {...state, id};
    await ref.read(appPrefsProvider).setDismissedAnnouncements(state.toList());
  }
}

/// The newest announcement that is current, for this plan and not yet
/// dismissed, translated into the app language.
@riverpod
AnnouncementRow? currentAnnouncement(Ref ref) {
  final all = ref.watch(announcementsProvider).value ?? const [];
  final dismissed = ref.watch(dismissedAnnouncementsProvider);
  final plan = ref.watch(planSummaryProvider)?.code;
  final now = ref.watch(clockNowProvider);
  for (final a in all) {
    if (!dismissed.contains(a.id) && a.visible(now, plan)) return a;
  }
  return null;
}

/// A message from the platform (new feature, maintenance, price change).
class AnnouncementBanner extends ConsumerWidget {
  const AnnouncementBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(currentAnnouncementProvider);
    if (a == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final tokens = MkTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final color = switch (a.severity) {
      'critical' => tokens.udhaar,
      'warning' => MkColors.gold,
      _ => MkColors.brand,
    };
    final body = a.body(lang);
    return Material(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MkSpacing.lg,
          vertical: MkSpacing.sm,
        ),
        child: Row(
          key: const ValueKey('announcement-banner'),
          children: [
            Icon(Icons.campaign_outlined, size: 18, color: color),
            const SizedBox(width: MkSpacing.sm),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: a.title(lang),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (body.isNotEmpty) TextSpan(text: '  $body'),
                  ],
                ),
                style: TextStyle(color: tokens.textBody),
              ),
            ),
            TextButton(
              onPressed: () => ref
                  .read(dismissedAnnouncementsProvider.notifier)
                  .dismiss(a.id),
              child: Text(l10n.annDismiss),
            ),
          ],
        ),
      ),
    );
  }
}
