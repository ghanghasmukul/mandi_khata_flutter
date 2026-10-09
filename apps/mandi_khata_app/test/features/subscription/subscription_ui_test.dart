import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/subscription/subscription_models.dart';
import 'package:mandi_khata_app/core/subscription/subscription_providers.dart';
import 'package:mandi_khata_app/core/subscription/subscription_repository.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/subscription/data/signup_repository.dart';
import 'package:mandi_khata_app/features/subscription/presentation/billing_screen.dart';
import 'package:mandi_khata_app/features/subscription/presentation/lifecycle_banner.dart';
import 'package:mandi_khata_app/features/subscription/presentation/signup_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

class _FakeRepo implements SubscriptionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  final requests = <Map<String, Object?>>[];

  @override
  Future<String> requestPlan(
    WriteContext ctx, {
    String? planCode,
    String? billingCycle,
    List<({String code, int qty})> addons = const [],
    String? note,
    DateTime? now,
  }) async {
    requests.add({
      'plan': planCode,
      'cycle': billingCycle,
      'addons': addons,
      'note': note,
    });
    return 'r1';
  }
}

class _FakeSignup extends SignupRepository {
  _FakeSignup(this.result) : super(null);

  final ({String? tenantId, SignupFailure? failure}) result;
  SignupInput? sent;
  String? sentId;

  @override
  Future<({String? tenantId, SignupFailure? failure})> signUp(
    SignupInput input, {
    String? tenantId,
  }) async {
    sent = input;
    sentId = tenantId;
    return result;
  }
}

PlanInfo plan(
  String code,
  String name, {
  Map<String, bool> modules = const {},
  int monthly = 0,
  bool isPublic = true,
}) => PlanInfo(
  spec: PlanSpec(
    code: code,
    name: name,
    modules: modules,
    maxUsers: 2,
    maxDevices: 2,
  ),
  name: name,
  priceMonthly: Money(monthly),
  priceYearly: Money(monthly * 10),
  isPublic: isPublic,
);

SubscriptionBundle bundle({
  SubscriptionStatus status = SubscriptionStatus.active,
}) => SubscriptionBundle(
  subscription: SubscriptionInfo(
    planCode: 'mandi_basic',
    billingCycle: 'monthly',
    terms: SubscriptionTerms(
      status: status,
      currentPeriodEnd: DateTime.utc(2027, 6),
    ),
    discountPct: 10,
  ),
  plans: [
    plan(
      'mandi_basic',
      'Mandi Basic',
      modules: {'khata': true, 'arrivals': true},
      monthly: 99900,
    ),
    plan(
      'combo',
      'Combo',
      modules: {'khata': true, 'shop': true},
      monthly: 249900,
    ),
  ],
  addonCatalog: const [
    AddonInfo(
      spec: AddonSpec(code: 'extra_user', grantsLimits: {'users': 1}),
      name: 'Extra user',
      priceMonthly: Money(19900),
      priceYearly: Money.zero,
    ),
  ],
);

const owner = Membership(
  tenantId: 't1',
  tenantName: 'Sandhu Traders',
  role: MemberRole.owner,
);

Widget host({
  required Widget child,
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    locale: locale,
    theme: MkTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ),
);

List<Override> billingOverrides(
  SubscriptionRepository repo, {
  Membership m = owner,
}) => [
  activeMembershipProvider.overrideWithValue(m),
  subscriptionBundleProvider.overrideWith((ref) => Stream.value(bundle())),
  subscriptionUsageProvider.overrideWith(
    (ref) => Stream.value(
      const SubscriptionUsage(users: 2, devices: 1, parties: 40),
    ),
  ),
  planRequestsProvider.overrideWith((ref) => Stream.value(const [])),
  supportSessionsProvider.overrideWith(
    (ref) => Stream.value([
      SupportSessionRow(
        id: 's1',
        who: 'Mandi Khata support',
        reason: 'Fix a report',
        startedAt: DateTime.utc(2027, 5, 2),
      ),
    ]),
  ),
  subscriptionRepositoryProvider.overrideWith((ref) async => repo),
  writeContextProvider.overrideWithValue(
    const WriteContext(
      tenantId: 't1',
      userId: 'u1',
      deviceId: 'd1',
      deviceCode: 'W1',
    ),
  ),
  lastSyncedAtProvider.overrideWithValue(DateTime.utc(2027, 5, 15)),
  clockNowProvider.overrideWithValue(DateTime.utc(2027, 5, 15)),
];

void main() {
  group('BillingScreen', () {
    Future<_FakeRepo> pump(WidgetTester tester, {Membership m = owner}) async {
      tester.view.physicalSize = const Size(1000, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final repo = _FakeRepo();
      await tester.pumpWidget(
        host(
          overrides: billingOverrides(repo, m: m),
          child: const BillingScreen(),
        ),
      );
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('shows plan, usage against limits, modules and support', (
      tester,
    ) async {
      await pump(tester);
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('billing-plan-name')))
            .data,
        'Mandi Basic',
      );
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('2 of 2'), findsOneWidget); // users
      expect(find.text('1 of 2'), findsOneWidget); // devices
      expect(find.text('40 (no limit)'), findsOneWidget); // parties
      expect(find.text('Discount: 10%'), findsOneWidget);
      expect(find.text('Fix a report', skipOffstage: false), findsNothing);
      expect(find.textContaining('Fix a report'), findsOneWidget);
      // The plan the business has is marked; others can be requested.
      expect(find.byKey(const ValueKey('request-combo')), findsOneWidget);
      expect(find.byKey(const ValueKey('request-mandi_basic')), findsNothing);
    });

    testWidgets('an owner requests another plan', (tester) async {
      final repo = await pump(tester);
      await tester.tap(find.byKey(const ValueKey('request-combo')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yearly'));
      await tester.enterText(
        find.byKey(const ValueKey('request-note')),
        'call me',
      );
      await tester.tap(find.byKey(const ValueKey('request-send')));
      await tester.pumpAndSettle();
      expect(repo.requests.single, {
        'plan': 'combo',
        'cycle': 'yearly',
        'addons': const <({String code, int qty})>[],
        'note': 'call me',
      });
      expect(find.text('Request sent. We will contact you.'), findsOneWidget);
    });

    testWidgets('add-ons are requested with their quantity', (tester) async {
      final repo = await pump(tester);
      final more = find.descendant(
        of: find.byKey(const ValueKey('addon-extra_user')),
        matching: find.byTooltip('More'),
      );
      await tester.tap(more);
      await tester.tap(more);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('request-addons')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('request-send')));
      await tester.pumpAndSettle();
      expect(repo.requests.single['plan'], isNull);
      expect(repo.requests.single['addons'], [(code: 'extra_user', qty: 2)]);
    });

    testWidgets('a munshi can look but not request', (tester) async {
      await pump(
        tester,
        m: const Membership(
          tenantId: 't1',
          tenantName: 'T',
          role: MemberRole.munshi,
        ),
      );
      expect(find.text('Only the owner can change the plan.'), findsOneWidget);
      final button = tester.widget<MkButton>(
        find.byKey(const ValueKey('request-combo')),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('LifecycleBanner', () {
    Future<void> pump(
      WidgetTester tester,
      LifecycleState state, {
      Locale locale = const Locale('en'),
    }) async {
      await tester.pumpWidget(
        host(
          locale: locale,
          overrides: [
            activeMembershipProvider.overrideWithValue(owner),
            lifecycleProvider.overrideWithValue(state),
          ],
          child: const LifecycleBanner(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('nothing while all is well', (tester) async {
      await pump(tester, openLifecycle);
      expect(find.byKey(const ValueKey('lifecycle-banner')), findsNothing);
    });

    testWidgets('trial: quiet until the last week, then a count-down', (
      tester,
    ) async {
      await pump(
        tester,
        const LifecycleState(
          effective: SubscriptionStatus.trial,
          access: AccessLevel.full,
          reason: LifecycleReason.trialRunning,
          daysLeft: 12,
        ),
      );
      expect(find.byKey(const ValueKey('lifecycle-banner')), findsNothing);
      await pump(
        tester,
        const LifecycleState(
          effective: SubscriptionStatus.trial,
          access: AccessLevel.full,
          reason: LifecycleReason.trialRunning,
          daysLeft: 3,
        ),
      );
      expect(find.text('Free trial: 3 days left'), findsOneWidget);
      expect(find.byKey(const ValueKey('lifecycle-billing')), findsOneWidget);
    });

    testWidgets('read-only says what still works', (tester) async {
      await pump(
        tester,
        const LifecycleState(
          effective: SubscriptionStatus.locked,
          access: AccessLevel.readOnly,
          reason: LifecycleReason.graceEnded,
        ),
      );
      expect(find.textContaining('read-only'), findsOneWidget);
      expect(find.textContaining('export'), findsOneWidget);
    });

    testWidgets('speaks Hindi and Punjabi', (tester) async {
      const s = LifecycleState(
        effective: SubscriptionStatus.trial,
        access: AccessLevel.full,
        reason: LifecycleReason.trialRunning,
        daysLeft: 2,
      );
      await pump(tester, s, locale: const Locale('hi'));
      expect(find.textContaining('मुफ़्त ट्रायल'), findsOneWidget);
      await pump(tester, s, locale: const Locale('pa'));
      expect(find.textContaining('ਮੁਫ਼ਤ ਟ੍ਰਾਇਲ'), findsOneWidget);
    });
  });

  group('SignupScreen', () {
    Future<_FakeSignup> pump(
      WidgetTester tester,
      ({String? tenantId, SignupFailure? failure}) result,
    ) async {
      tester.view.physicalSize = const Size(800, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final fake = _FakeSignup(result);
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SignupScreen()),
          GoRoute(
            path: '/select-tenant',
            builder: (_, _) => const Scaffold(body: Text('picker')),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [signupRepositoryProvider.overrideWithValue(fake)],
          child: MaterialApp.router(
            routerConfig: router,
            theme: MkTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return fake;
    }

    testWidgets('a business name is required', (tester) async {
      final fake = await pump(tester, (tenantId: 't', failure: null));
      await tester.tap(find.byKey(const ValueKey('signup-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Enter the business name.'), findsOneWidget);
      expect(fake.sent, isNull);
    });

    testWidgets('sends the details once and goes to the picker', (
      tester,
    ) async {
      final fake = await pump(tester, (tenantId: 't', failure: null));
      await tester.enterText(
        find.byKey(const ValueKey('signup-name')),
        'Sandhu Traders',
      );
      await tester.tap(find.text('Input shop'));
      await tester.enterText(
        find.byKey(const ValueKey('signup-referral')),
        'dealer-1',
      );
      await tester.tap(find.byKey(const ValueKey('signup-submit')));
      await tester.pumpAndSettle();
      expect(fake.sent!.name, 'Sandhu Traders');
      expect(fake.sent!.businessType, 'shop');
      expect(fake.sent!.stateCode, '03');
      expect(fake.sent!.referralCode, 'dealer-1');
      expect(fake.sentId, matches(RegExp(r'^[0-9a-f-]{36}$')));
      expect(find.text('picker'), findsOneWidget);
    });

    testWidgets('failures are explained, not hidden', (tester) async {
      for (final (failure, text) in [
        (SignupFailure.offline, 'needs the internet'),
        (SignupFailure.closed, 'paused'),
        (SignupFailure.limitReached, 'number of businesses'),
      ]) {
        await pump(tester, (tenantId: null, failure: failure));
        await tester.enterText(find.byKey(const ValueKey('signup-name')), 'X');
        await tester.tap(find.byKey(const ValueKey('signup-submit')));
        await tester.pumpAndSettle();
        expect(find.textContaining(text), findsOneWidget, reason: '$failure');
      }
    });
  });
}
