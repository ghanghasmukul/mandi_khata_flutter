import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_charts.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_hero.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_needs.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_stats.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The start screen body: hero, quick actions, today's numbers, charts and
/// what needs attention. Everything is read live from the local database.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  /// Two columns of cards from this width.
  static const _wide = 900.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MkSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, box) {
              const gap = MkSpacing.md;
              final wide = box.maxWidth >= _wide;
              Widget pair(Widget a, Widget b) => wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: a),
                        const SizedBox(width: gap),
                        Expanded(child: b),
                      ],
                    )
                  : Column(
                      children: [
                        a,
                        const SizedBox(height: gap),
                        b,
                      ],
                    );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DashboardHero(),
                  const SizedBox(height: gap),
                  const DashboardQuickActions(),
                  const SizedBox(height: gap),
                  const DashboardStats(),
                  const SizedBox(height: gap),
                  pair(const EarnedChartCard(), const CropMixCard()),
                  const SizedBox(height: gap),
                  pair(const MoneyCard(), const NeedsYouCard()),
                  const SizedBox(height: MkSpacing.xxl),
                  const _DeviceCode(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// This install's device code (e.g. W1): what support asks for.
class _DeviceCode extends ConsumerWidget {
  const _DeviceCode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(activeDeviceProvider);
    if (device == null) return const SizedBox.shrink();
    return Text(
      AppLocalizations.of(context).homeDeviceCode(device.code),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
