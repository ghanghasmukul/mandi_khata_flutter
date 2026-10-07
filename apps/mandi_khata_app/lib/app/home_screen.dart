import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

/// The start screen: the dashboard under the app shell's navigation. Search,
/// language, role and the account menu come from the shell's top bar scope.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final membership = ref.watch(activeMembershipProvider);
    return Scaffold(
      body: Column(
        children: [
          MkTopBar(
            // A phone has no sidebar to show the business, so its name
            // takes the title.
            title: MediaQuery.sizeOf(context).width < MkBreakpoints.rail
                ? membership?.tenantName ?? l10n.navDashboard
                : l10n.navDashboard,
            subtitle: [
              ?membership?.tenantName,
              ?membership?.mandiName,
            ].join(' · '),
          ),
          const Expanded(child: DashboardView()),
        ],
      ),
    );
  }
}
