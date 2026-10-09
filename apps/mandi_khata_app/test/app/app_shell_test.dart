import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/app_shell.dart';
import 'package:mandi_khata_app/app/nav_destinations.dart';
import 'package:mandi_khata_app/core/auth/auth_repository.dart';
import 'package:mandi_khata_app/core/auth/session.dart';
import 'package:mandi_khata_app/core/storage/app_prefs.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/core/update/update_checker.dart';
import 'package:mandi_khata_app/core/update/update_providers.dart';
import 'package:mandi_khata_app/features/dashboard/domain/alerts.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

import '../helpers/fakes.dart';

class _SignedInSession extends Session {
  @override
  SessionState build() =>
      const SignedIn(AuthUser(id: 'u1', phone: '9814022110'));
}

void main() {
  group('selectedNavId', () {
    const routes = ['/', '/accounts', '/accounts/expenses', '/parties'];
    test('longest prefix wins; / only matches /', () {
      expect(selectedNavId('/', routes), '/');
      expect(selectedNavId('/parties/abc/edit', routes), '/parties');
      expect(selectedNavId('/accounts/expenses', routes), '/accounts/expenses');
      expect(selectedNavId('/accounts/chart', routes), '/accounts');
      expect(selectedNavId('/accounts-other', routes), isNull);
      expect(selectedNavId('/unknown', routes), isNull);
    });
  });

  group('navSections', () {
    Future<List<MkNavSection>> build(
      WidgetTester tester,
      MemberRole role,
    ) async {
      late List<MkNavSection> out;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              out = navSections(
                AppLocalizations.of(context),
                role.allows,
                badges: const {'/loans': '3'},
              );
              return const SizedBox();
            },
          ),
        ),
      );
      return out;
    }

    testWidgets('an owner sees all three sections', (tester) async {
      final s = await build(tester, MemberRole.owner);
      expect(s.map((x) => x.id), ['daily', 'shop', 'money', 'admin']);
      final ids = [for (final x in s) ...x.items.map((i) => i.id)];
      expect(
        ids,
        containsAll([
          '/',
          '/loans',
          '/accounts',
          '/team',
          '/audit',
          '/settings',
        ]),
      );
      expect(s.first.items.firstWhere((i) => i.id == '/loans').badge, '3');
    });

    testWidgets('modules the plan lacks are hidden from the menu', (
      tester,
    ) async {
      late List<MkNavSection> out;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              out = navSections(
                AppLocalizations.of(context),
                MemberRole.owner.allows,
                moduleOn: (m) => m == 'arrivals' || m == 'karza',
              );
              return const SizedBox();
            },
          ),
        ),
      );
      final ids = [for (final x in out) ...x.items.map((i) => i.id)];
      expect(ids, containsAll(['/arrivals', '/loans', '/crops']));
      expect(ids, isNot(contains('/accounts')));
      expect(ids, isNot(contains('/accounts/expenses')));
      expect(ids.where((i) => i.startsWith('/shop') || i == '/pos'), isEmpty);
      // Base khata screens never depend on a module.
      expect(ids, containsAll(['/', '/parties', '/payments', '/reports']));
    });

    testWidgets('billing stays in the menu of a locked owner', (tester) async {
      late List<MkNavSection> out;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              out = navSections(
                AppLocalizations.of(context),
                (_) => false, // read-only: every write permission is off
                canIgnoringLock: MemberRole.owner.allows,
              );
              return const SizedBox();
            },
          ),
        ),
      );
      final ids = [for (final x in out) ...x.items.map((i) => i.id)];
      expect(ids, contains('/billing'));
      expect(ids, isNot(contains('/team')));
    });

    test('moduleOfLocation maps a screen to its module', () {
      expect(moduleOfLocation('/loans'), 'karza');
      expect(moduleOfLocation('/loans/abc'), 'karza');
      expect(moduleOfLocation('/accounts/expenses'), 'accounting');
      expect(moduleOfLocation('/arrivals/new'), 'arrivals');
      expect(moduleOfLocation('/shop/pos'), 'shop');
      expect(moduleOfLocation('/parties'), isNull);
      expect(moduleOfLocation('/billing'), isNull);
      expect(moduleOfLocation('/unknown'), isNull);
    });

    testWidgets('a munshi sees neither admin screens nor the accounts hub', (
      tester,
    ) async {
      final s = await build(tester, MemberRole.munshi);
      final ids = [for (final x in s) ...x.items.map((i) => i.id)];
      expect(ids, isNot(contains('/team')));
      expect(ids, isNot(contains('/audit')));
      // A munshi pays in cash, so the cash book and expenses stay.
      expect(ids, containsAll(['/accounts/expenses', '/settings']));
    });
  });

  group('AppShell', () {
    Future<GoRouter> pump(
      WidgetTester tester, {
      required Size size,
      MemberRole role = MemberRole.owner,
      int overdue = 2,
      String initial = '/',
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Widget page(String name) => Scaffold(
        body: Column(
          children: [
            MkTopBar(title: name),
            Expanded(child: Center(child: Text('page $name'))),
          ],
        ),
      );
      final router = GoRouter(
        initialLocation: initial,
        routes: [
          ShellRoute(
            builder: (context, state, child) =>
                AppShell(location: state.matchedLocation, child: child),
            routes: [
              for (final r in [
                '/',
                '/arrivals',
                '/parties',
                '/payments',
                '/loans',
                '/reports',
                '/settings',
              ])
                GoRoute(path: r, builder: (_, _) => page(r)),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(_SignedInSession.new),
            appPrefsProvider.overrideWithValue(await makePrefs()),
            syncIndicatorProvider.overrideWithValue(null),
            updateStatusProvider.overrideWith(
              (ref) async => const UpdateNone(),
            ),
            loanAlertsProvider.overrideWith(
              (ref) => Stream.value(LoanAlerts(overdue: overdue, dueSoon: 0)),
            ),
            activeMembershipProvider.overrideWithValue(
              Membership(
                tenantId: 't1',
                tenantName: 'Gupta Trading Co.',
                role: role,
              ),
            ),
          ],
          child: MaterialApp.router(
            theme: MkTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('desktop: sidebar with sections, business, badge, user', (
      tester,
    ) async {
      final router = await pump(tester, size: const Size(1400, 900));
      expect(find.text('Gupta Trading Co.'), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Loans (karza)'), findsOneWidget);
      expect(find.text('2'), findsOneWidget, reason: 'overdue loans badge');
      expect(find.text('9814022110'), findsOneWidget);
      expect(find.text('Owner'), findsWidgets);
      await tester.tap(find.text('Loans (karza)'));
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, '/loans');
      expect(find.text('page /loans'), findsOneWidget);
    });

    testWidgets('every screen header gets search, language and role', (
      tester,
    ) async {
      await pump(tester, size: const Size(1400, 900));
      expect(find.text('Search or run a command…'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('हिं'), findsOneWidget);
    });

    testWidgets('a munshi has no Team or Audit in the sidebar', (tester) async {
      await pump(tester, size: const Size(1400, 900), role: MemberRole.munshi);
      expect(find.text('Users & permissions'), findsNothing);
      expect(find.text('Audit log'), findsNothing);
    });

    testWidgets('phone: bottom bar, and More lists every screen', (
      tester,
    ) async {
      final router = await pump(tester, size: const Size(390, 800));
      expect(find.byType(MkBottomNav), findsOneWidget);
      expect(find.byType(MkSidebar), findsNothing);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('more-/reports')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.byKey(const ValueKey('more-/reports')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('more-/settings')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const ValueKey('more-/reports')));
      await tester.pumpAndSettle();
      expect(router.state.matchedLocation, '/reports');
    });
  });
}
