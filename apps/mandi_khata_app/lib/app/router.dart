import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show GlobalKey, NavigatorState;
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/app/home_screen.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_screen.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/lot_detail_screen.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/lot_form_screen.dart';
import 'package:mandi_khata_app/features/audit/presentation/audit_screen.dart';
import 'package:mandi_khata_app/features/auth/presentation/device_revoked_screen.dart';
import 'package:mandi_khata_app/features/auth/presentation/lock_screen.dart';
import 'package:mandi_khata_app/features/auth/presentation/login_screen.dart';
import 'package:mandi_khata_app/features/auth/presentation/select_tenant_screen.dart';
import 'package:mandi_khata_app/features/auth/presentation/set_pin_screen.dart';
import 'package:mandi_khata_app/features/auth/presentation/splash_screen.dart';
import 'package:mandi_khata_app/features/crops/presentation/crop_detail_screen.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_screen.dart';
import 'package:mandi_khata_app/features/dev_gallery/presentation/gallery_screen.dart';
import 'package:mandi_khata_app/features/dev_sync/presentation/dev_sync_screen.dart';
import 'package:mandi_khata_app/features/diagnostics/presentation/diagnostics_screen.dart';
import 'package:mandi_khata_app/features/interest/presentation/bulk_interest_screen.dart';
import 'package:mandi_khata_app/features/interest/presentation/bulk_posting_screen.dart';
import 'package:mandi_khata_app/features/interest/presentation/settlement_screen.dart';
import 'package:mandi_khata_app/features/khata/presentation/day_book_screen.dart';
import 'package:mandi_khata_app/features/loans/presentation/loan_detail_screen.dart';
import 'package:mandi_khata_app/features/loans/presentation/loans_screen.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:mandi_khata_app/features/opening_balances/presentation/opening_balances_screen.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_screen.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_detail_screen.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_form_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/bank_accounts_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/payment_detail_screen.dart';
import 'package:mandi_khata_app/features/payments/presentation/payments_screen.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:mandi_khata_app/features/reports/presentation/reports_screen.dart';
import 'package:mandi_khata_app/features/settings/presentation/settings_screen.dart';
import 'package:mandi_khata_app/features/team/presentation/team_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

abstract final class AppRoutes {
  static const String home = GateRoutes.home;
  static const String login = GateRoutes.login;
  static const String selectTenant = GateRoutes.selectTenant;
  static const String lock = GateRoutes.lock;
  static const String setPin = GateRoutes.setPin;
  static const settings = '/settings';

  /// Owner-only health page. In every build (support needs it).
  static const diagnostics = '/dev/diagnostics';

  /// Design-system gallery. Not registered in release builds.
  static const gallery = '/dev/gallery';

  /// Offline / sync test bench. Not registered in release builds.
  static const sync = '/dev/sync';
}

/// The root navigator's key: lets app-wide shortcuts (the command palette)
/// open dialogs on top of whatever screen is showing.
@Riverpod(keepAlive: true)
GlobalKey<NavigatorState> rootNavigatorKey(Ref ref) =>
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// The app's router. Guards follow [gateStepProvider]: signed out → login,
/// locked → PIN, no business → picker.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final refresh = ValueNotifier<GateStep>(ref.read(gateStepProvider));
  ref.listen(gateStepProvider, (_, step) => refresh.value = step);

  final router = GoRouter(
    navigatorKey: ref.watch(rootNavigatorKeyProvider),
    refreshListenable: refresh,
    redirect: (context, state) =>
        redirectFor(refresh.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: GateRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.selectTenant,
        builder: (context, state) => const SelectTenantScreen(),
      ),
      GoRoute(
        path: AppRoutes.lock,
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: GateRoutes.deviceRevoked,
        builder: (context, state) => const DeviceRevokedScreen(),
      ),
      GoRoute(
        path: AppRoutes.setPin,
        builder: (context, state) => const SetPinScreen(),
      ),
      GoRoute(
        path: PartyRoutes.list,
        builder: (context, state) => const PartiesScreen(),
        routes: [
          // Before ':id' so "new" is never read as an id.
          GoRoute(
            path: 'new',
            builder: (context, state) => const PartyFormScreen(),
          ),
          GoRoute(
            path: 'interest',
            builder: (context, state) => const BulkInterestScreen(),
          ),
          GoRoute(
            path: 'import',
            builder: (context, state) => const OpeningBalancesScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                PartyDetailScreen(partyId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    PartyFormScreen(partyId: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'hisaab',
                builder: (context, state) =>
                    SettlementScreen(partyId: state.pathParameters['id']!),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: OnboardingRoutes.wizard,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: ArrivalRoutes.list,
        builder: (context, state) => const ArrivalsScreen(),
        routes: [
          // Before ':id' so "new" is never read as an id.
          GoRoute(
            path: 'new',
            builder: (context, state) =>
                LotFormScreen(copyFromId: state.uri.queryParameters['from']),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                LotDetailScreen(lotId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    LotFormScreen(lotId: state.pathParameters['id']),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: PaymentRoutes.list,
        builder: (context, state) => const PaymentsScreen(),
        routes: [
          // Before ':id' so "accounts" is never read as an id.
          GoRoute(
            path: 'accounts',
            builder: (context, state) => const BankAccountsScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                PaymentDetailScreen(paymentId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: LoanRoutes.list,
        builder: (context, state) => const LoansScreen(),
        routes: [
          // Before ':id' so "post" is never read as an id.
          GoRoute(
            path: 'post',
            builder: (context, state) {
              final asOf = state.uri.queryParameters['asOf'];
              return BulkPostingScreen(
                initialAsOf: asOf == null ? null : _tryDate(asOf),
              );
            },
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                LoanDetailScreen(loanId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: KhataRoutes.dayBook,
        builder: (context, state) => const DayBookScreen(),
      ),
      GoRoute(
        path: ReportRoutes.list,
        builder: (context, state) {
          final kind = ReportKind.values
              .asNameMap()[state.uri.queryParameters['r']];
          return ReportsScreen(
            key: ValueKey(kind),
            initial: kind ?? ReportKind.outstanding,
          );
        },
      ),
      GoRoute(
        path: CropRoutes.list,
        builder: (context, state) => const CropsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                CropDetailScreen(cropId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: TeamRoutes.list,
        builder: (context, state) => const TeamScreen(),
      ),
      GoRoute(
        path: AuditRoutes.list,
        builder: (context, state) => const AuditScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.diagnostics,
        builder: (context, state) => const DiagnosticsScreen(),
      ),
      if (!kReleaseMode) ...[
        GoRoute(
          path: AppRoutes.gallery,
          builder: (context, state) => const GalleryScreen(),
        ),
        GoRoute(
          path: AppRoutes.sync,
          builder: (context, state) => const DevSyncScreen(),
        ),
      ],
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
}

LedgerDate? _tryDate(String text) {
  try {
    return LedgerDate.parse(text);
  } on FormatException {
    return null;
  }
}
