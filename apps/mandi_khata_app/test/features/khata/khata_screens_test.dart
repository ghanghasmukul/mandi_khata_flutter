import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/app/command_palette.dart';
import 'package:mandi_khata_app/app/gate.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/khata/domain/ledger_posting.dart';
import 'package:mandi_khata_app/features/khata/presentation/day_book_screen.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/features/parties/presentation/party_detail_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

import '../parties/parties_screens_test.dart' show FakePartiesRepository;
import 'fake_ledger_repository.dart';

const ctx = WriteContext(
  tenantId: 't1',
  userId: 'u1',
  deviceId: 'd1',
  deviceCode: 'W1',
);

class _FixedTenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

const gurmeet = Party(
  id: 'p1',
  code: 'F-101',
  name: 'Gurmeet Singh',
  roles: {PartyRole.farmer},
  village: 'Rampura',
);

void main() {
  late FakeLedgerRepository ledger;
  late FakePartiesRepository parties;

  setUp(() {
    parties = FakePartiesRepository()..parties.add(gurmeet);
    ledger = FakeLedgerRepository()
      ..partyNames['p1'] = 'Gurmeet Singh'
      ..add(
        'p1',
        '2026-04-01',
        Side.udhaar,
        2000,
        refType: RefType.openingBalance,
      )
      ..add(
        'p1',
        '2026-04-05',
        Side.jama,
        15558,
        refType: RefType.arrival,
        narration: 'L-W1-0001',
      )
      ..add('p1', '2026-04-09', Side.jama, 999, id: 'wrong', narration: 'typo');
  });

  Future<void> pump(
    WidgetTester tester,
    MemberRole role, {
    String start = '/khata',
    Size size = const Size(1200, 1400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final navKey = GlobalKey<NavigatorState>();
    final router = GoRouter(
      navigatorKey: navKey,
      initialLocation: start,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(path: '/khata', builder: (_, _) => const DayBookScreen()),
        GoRoute(path: '/parties', builder: (_, _) => const Text('parties')),
        GoRoute(
          path: '/parties/:id',
          builder: (_, s) =>
              PartyDetailScreen(partyId: s.pathParameters['id']!),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ledgerRepositoryProvider.overrideWith((ref) async => ledger),
          partiesRepositoryProvider.overrideWith((ref) async => parties),
          activeTenantProvider.overrideWith(_FixedTenant.new),
          writeContextProvider.overrideWithValue(ctx),
          activeMembershipProvider.overrideWithValue(
            Membership(tenantId: 't1', tenantName: 'Gupta', role: role),
          ),
          syncIndicatorProvider.overrideWithValue(null),
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
  }

  group('day book', () {
    testWidgets('lists entries newest first with running baki and totals', (
      tester,
    ) async {
      await pump(tester, MemberRole.owner);
      expect(find.text('3 entries'), findsOneWidget);
      expect(find.textContaining('Crop sale · L-W1-0001'), findsOneWidget);
      expect(find.textContaining('Opening balance'), findsWidgets);
      // Running baki after the last entry: -2000 + 15558 + 999 = 14,557.
      expect(find.text('₹14,557'), findsWidgets);
      // Totals: udhaar 2,000, jama 16,557.
      expect(find.text('₹2,000'), findsWidgets);
      expect(find.text('₹16,557'), findsOneWidget);
    });

    testWidgets('filtering by type narrows the list', (tester) async {
      await pump(tester, MemberRole.owner);
      await tester.tap(find.byKey(const ValueKey('khata-type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Crop sale').last);
      await tester.pumpAndSettle();
      expect(find.text('1 entry'), findsOneWidget);
    });

    testWidgets('empty filter shows the empty state', (tester) async {
      ledger.entries.clear();
      await pump(tester, MemberRole.owner);
      expect(find.text('No entries for this filter'), findsOneWidget);
    });

    testWidgets('a munshi cannot add, edit or reverse', (tester) async {
      await pump(tester, MemberRole.munshi);
      expect(find.text('Khata entry'), findsNothing);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('reverse asks first, then strikes the pair through', (
      tester,
    ) async {
      await pump(tester, MemberRole.owner);
      // Newest line first: the typo entry's menu.
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reverse'));
      await tester.pumpAndSettle();
      expect(find.text('Reverse this entry?'), findsOneWidget);
      await tester.tap(find.widgetWithText(MkButton, 'Reverse'));
      await tester.pumpAndSettle();
      expect(ledger.reversed, ['wrong']);
      expect(find.text('4 entries'), findsOneWidget);
      expect(find.text('Entry reversed'), findsOneWidget);
    });
  });

  group('khata entry dialog', () {
    testWidgets('posts a manual entry for the picked party', (tester) async {
      await pump(tester, MemberRole.owner);
      await tester.tap(find.text('Khata entry').last);
      await tester.pumpAndSettle();

      // Needs a party and an amount first.
      await tester.tap(find.byKey(const ValueKey('khata-save')));
      await tester.pumpAndSettle();
      expect(ledger.appended, isEmpty);
      expect(find.text('Enter an amount above zero'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey('khata-amount')),
          matching: find.byType(TextField),
        ),
        '1250',
      );
      await tester.enterText(
        find
            .descendant(
              of: find.byType(Dialog),
              matching: find.byType(TextField),
            )
            .first,
        'gur',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Gurmeet Singh').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('khata-save')));
      await tester.pumpAndSettle();

      final draft = ledger.appended.single;
      expect(draft.partyId, 'p1');
      expect(draft.side, Side.udhaar);
      expect(draft.amount, const Money.rupees(1250));
      expect(draft.refType, RefType.journal);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('4 entries'), findsOneWidget);
    });

    testWidgets('shows why a back-dated entry was refused', (tester) async {
      ledger.nextResult = const LedgerNotPermitted(
        Permission.entriesReverse,
        backdateDays: 3,
      );
      await pump(tester, MemberRole.accountant, start: '/parties/p1');
      await tester.tap(find.byKey(const ValueKey('statement-add')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey('khata-amount')),
          matching: find.byType(TextField),
        ),
        '10',
      );
      await tester.tap(find.byKey(const ValueKey('khata-save')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('khata-error')), findsOneWidget);
      expect(find.textContaining('older than 3 days'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('edit shows the struck-through original and corrects it', (
      tester,
    ) async {
      await pump(tester, MemberRole.owner, start: '/parties/p1');
      // Statement order: opening, sale, typo. Edit the typo (a manual entry).
      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit (reverse and re-enter)'));
      await tester.pumpAndSettle();
      expect(find.text('Original entry (will be reversed)'), findsOneWidget);
      expect(
        tester
            .widgetList<Text>(
              find.descendant(
                of: find.byType(Dialog),
                matching: find.byType(Text),
              ),
            )
            .any((t) => t.style?.decoration == TextDecoration.lineThrough),
        isTrue,
      );
      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey('khata-amount')),
          matching: find.byType(TextField),
        ),
        '99',
      );
      await tester.tap(find.byKey(const ValueKey('khata-save')));
      await tester.pumpAndSettle();
      expect(ledger.corrected.single.id, 'wrong');
      expect(ledger.corrected.single.amount, const Money.rupees(99));
    });
  });

  group('party khata tab', () {
    testWidgets('statement: opening, rows, running baki, closing', (
      tester,
    ) async {
      await pump(tester, MemberRole.owner, start: '/parties/p1');
      expect(find.text('Closing balance'), findsOneWidget);
      expect(find.text('Crop sale · L-W1-0001'), findsOneWidget);
      // Closing = -2000 + 15558 + 999 = 14,557 jama.
      expect(find.text('₹14,557 · Jama · we owe'), findsOneWidget);
      expect(find.byKey(const ValueKey('statement-print')), findsOneWidget);
      expect(find.byKey(const ValueKey('statement-share')), findsOneWidget);
    });

    testWidgets('range chip narrows the statement to the chosen period', (
      tester,
    ) async {
      await pump(tester, MemberRole.owner, start: '/parties/p1');
      await tester.tap(find.byKey(const ValueKey('statement-range-today')));
      await tester.pumpAndSettle();
      expect(find.text('No entries in this period'), findsOneWidget);
      // Balance brought forward still counts everything before the period.
      expect(find.text('₹14,557 · Jama · we owe'), findsOneWidget);
    });

    testWidgets('works on a phone width', (tester) async {
      await pump(
        tester,
        MemberRole.owner,
        start: '/parties/p1',
        size: const Size(400, 800),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Crop sale · L-W1-0001'), findsOneWidget);
    });
  });

  group('command palette', () {
    testWidgets('Ctrl+K opens it and filters commands', (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        navigatorKey: navKey,
        routes: [GoRoute(path: '/', builder: (_, _) => const Text('home'))],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeMembershipProvider.overrideWithValue(
              const Membership(
                tenantId: 't1',
                tenantName: 'Gupta',
                role: MemberRole.owner,
              ),
            ),
            gateStepProvider.overrideWithValue(GateStep.ready),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
            builder: (context, child) =>
                CommandPaletteShortcut(navigatorKey: navKey, child: child!),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('palette-khata-entry')), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('palette-search')),
        'arr',
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('palette-arrivals')), findsOneWidget);
      expect(find.byKey(const ValueKey('palette-khata-entry')), findsNothing);
    });

    testWidgets('a munshi is not offered Khata entry', (tester) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      List<String> ids(MemberRole r) => [
        for (final c in paletteCommands(l10n, r.allows)) c.id,
      ];
      expect(ids(MemberRole.owner), contains('khata-entry'));
      expect(ids(MemberRole.accountant), contains('khata-entry'));
      expect(ids(MemberRole.munshi), isNot(contains('khata-entry')));
      expect(ids(MemberRole.munshi), contains('day-book'));
    });
  });
}
