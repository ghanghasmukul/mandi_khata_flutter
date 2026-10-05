import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/permissions/permissions.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/features/interest/domain/interest_posting_models.dart';
import 'package:mandi_khata_app/features/interest/presentation/bulk_posting_screen.dart';
import 'package:mandi_khata_app/features/interest/presentation/interest_posting_providers.dart';
import 'package:mandi_khata_app/features/interest/presentation/post_interest_dialog.dart';
import 'package:mandi_khata_app/features/interest/presentation/settlement_screen.dart';
import 'package:mandi_khata_app/features/khata/presentation/khata_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

class _FixedTenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

class _FakeWriter implements InterestPostingWriter {
  final posted = <List<InterestPostingPlan>>[];
  final settled =
      <
        ({
          String partyId,
          LedgerDate asOf,
          Map<String, int> waivers,
          String reason,
        })
      >[];
  PostingResult? next;

  @override
  Future<PostingResult> post(List<InterestPostingPlan> plans) async {
    posted.add(plans);
    return next ?? InterestPosted(posted: plans, skipped: const []);
  }

  @override
  Future<PostingResult> settle(
    String partyId,
    LedgerDate asOf, {
    Map<String, int> waivers = const {},
    String reason = '',
  }) async {
    settled.add((
      partyId: partyId,
      asOf: asOf,
      waivers: waivers,
      reason: reason,
    ));
    return next ??
        const SettlementDone(interest: Money(493151), waived: Money(93151));
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError('$i');
}

final today = LedgerDate.fromDateTime(DateTime.now());

PostingCandidate cand(
  String name,
  int paise, {
  String partyId = 'p1',
  String? loanId,
  String? loanNo,
  bool already = false,
}) => PostingCandidate(
  partyName: name,
  partyCode: 'C-$name',
  principal: const Money.rupees(100000),
  loanNo: loanNo,
  alreadyPosted: already,
  plan: InterestPostingPlan(
    scope: loanId == null ? PostingScope.khata : PostingScope.loan,
    partyId: partyId,
    loanId: loanId,
    from: today.addDays(-100),
    to: today,
    ratePa: Decimal.parse('18'),
    method: InterestMethod.simple,
    amountPaise: paise,
    periodKey:
        'interest:${loanId == null ? 'khata' : 'loan'}:'
        '${loanId ?? partyId}:$today',
  ),
);

LedgerEntry entry(Side side, int rupees, RefType type, {String id = 'e1'}) =>
    LedgerEntry(
      id: id,
      partyId: 'p1',
      entryDate: today.addDays(-100),
      side: side,
      amount: Money.rupees(rupees),
      refType: type,
      createdAt: DateTime.utc(2026),
    );

void main() {
  late _FakeWriter writer;

  setUp(() => writer = _FakeWriter());

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    List<PostingCandidate> bulk = const [],
    List<PostingCandidate> party = const [],
    List<LedgerEntry> entries = const [],
    bool manage = true,
    bool reverse = true,
  }) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const p = Party(
      id: 'p1',
      code: 'F-1',
      name: 'Gurmeet Singh',
      roles: {PartyRole.farmer},
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeTenantProvider.overrideWith(_FixedTenant.new),
          settingRowsProvider(
            businessTarget,
          ).overrideWith((ref) => Stream.value(const [])),
          postingCandidatesProvider(today).overrideWith((ref) async => bulk),
          postingCandidatesProvider(
            today.addDays(-30),
          ).overrideWith((ref) async => bulk),
          postingCandidatesProvider(
            today,
            partyId: 'p1',
          ).overrideWith((ref) async => party),
          partyPostingsProvider(
            'p1',
          ).overrideWith((ref) => Stream.value(const <PostingRow>[])),
          partyEntriesProvider(
            'p1',
          ).overrideWith((ref) => Stream.value(entries)),
          partyProvider('p1').overrideWith((ref) => Stream.value(p)),
          interestPostingWriterProvider.overrideWithValue(writer),
          canProvider(Permission.loansManage).overrideWithValue(manage),
          canProvider(Permission.entriesReverse).overrideWithValue(reverse),
          syncIndicatorProvider.overrideWithValue(null),
        ],
        child: MaterialApp.router(
          theme: MkTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            routes: [
              GoRoute(path: '/', builder: (_, _) => home),
              GoRoute(path: '/loans', builder: (_, _) => const Text('loans')),
              GoRoute(
                path: '/parties/:id',
                builder: (_, _) => const Text('party'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder key(String k) => find.byKey(ValueKey(k));
  Money money(WidgetTester t, String k) => t.widget<MkMoneyText>(key(k)).amount;

  group('bulk posting', () {
    final rows = [
      cand('Gurmeet', 493151),
      cand('Harbans', 246575, partyId: 'p2'),
      cand('Balwinder', 100000, partyId: 'p3', loanId: 'L1', loanNo: 'KZ-W1-1'),
      cand('Old', 500, partyId: 'p4', already: true),
    ];

    testWidgets('lists every account, selects all but already posted', (
      tester,
    ) async {
      await pump(tester, const BulkPostingScreen(), bulk: rows);
      expect(find.text('Gurmeet'), findsOneWidget);
      expect(find.text('Balwinder · KZ-W1-1'), findsOneWidget);
      expect(find.text('Already posted up to this day'), findsOneWidget);
      expect(
        find.text('3 selected · ₹8,397.26'),
        findsOneWidget,
        reason: '4,931.51 + 2,465.75 + 1,000',
      );
    });

    testWidgets('unticking a row lowers the total and what is posted', (
      tester,
    ) async {
      await pump(tester, const BulkPostingScreen(), bulk: rows);
      await tester.tap(key('bulk-post-interest:khata:p2:$today'));
      await tester.pumpAndSettle();
      expect(find.text('2 selected · ₹5,931.51'), findsOneWidget);
      await tester.tap(key('bulk-post-run'));
      await tester.pumpAndSettle();
      expect(writer.posted, hasLength(1));
      expect(writer.posted.single.map((p) => p.amountPaise), [493151, 100000]);
      expect(find.textContaining('Posted 2 entries'), findsOneWidget);
    });

    testWidgets('opens on the day an alert asked for', (tester) async {
      await pump(
        tester,
        BulkPostingScreen(initialAsOf: today.addDays(-30)),
        bulk: rows,
      );
      expect(find.text('Gurmeet'), findsOneWidget);
      // Not the schedule's day: a way back to it is offered.
      expect(key('bulk-post-today'), findsOneWidget);
    });

    testWidgets('says so when there is nothing to post', (tester) async {
      await pump(tester, const BulkPostingScreen());
      expect(key('bulk-post-none'), findsOneWidget);
      expect(tester.widget<MkButton>(key('bulk-post-run')).onPressed, isNull);
    });

    testWidgets('a refusal from the writer is shown', (tester) async {
      writer.next = const PostingNotPermitted(Permission.loansManage);
      await pump(tester, const BulkPostingScreen(), bulk: rows);
      await tester.tap(key('bulk-post-run'));
      await tester.pumpAndSettle();
      expect(
        find.text('You are not allowed to post interest. Ask the owner.'),
        findsOneWidget,
      );
    });

    testWidgets('without loans.manage the screen refuses', (tester) async {
      await pump(tester, const BulkPostingScreen(), bulk: rows, manage: false);
      expect(key('bulk-post-run'), findsNothing);
    });
  });

  group('post interest dialog', () {
    Widget host() => Builder(
      builder: (context) => TextButton(
        key: const ValueKey('open'),
        onPressed: () => showPostInterestDialog(context, partyId: 'p1'),
        child: const Text('open'),
      ),
    );

    testWidgets('previews the amount, posts only on confirm', (tester) async {
      await pump(
        tester,
        Scaffold(body: host()),
        party: [cand('Gurmeet', 493151)],
      );
      await tester.tap(key('open'));
      await tester.pumpAndSettle();
      expect(money(tester, 'post-amount'), const Money(493151));
      expect(writer.posted, isEmpty);
      await tester.tap(key('post-confirm'));
      await tester.pumpAndSettle();
      expect(writer.posted.single.single.amountPaise, 493151);
      expect(key('post-confirm'), findsNothing);
    });

    testWidgets('nothing to post: no confirm button', (tester) async {
      await pump(tester, Scaffold(body: host()));
      await tester.tap(key('open'));
      await tester.pumpAndSettle();
      expect(key('post-none'), findsOneWidget);
      expect(key('post-confirm'), findsNothing);
    });

    testWidgets('an error stays on the dialog', (tester) async {
      writer.next = const PostingInFuture();
      await pump(
        tester,
        Scaffold(body: host()),
        party: [cand('Gurmeet', 493151)],
      );
      await tester.tap(key('open'));
      await tester.pumpAndSettle();
      await tester.tap(key('post-confirm'));
      await tester.pumpAndSettle();
      expect(key('post-error'), findsOneWidget);
      expect(key('post-confirm'), findsOneWidget);
    });
  });

  group('hisaab karo', () {
    final entries = [entry(Side.udhaar, 100000, RefType.journal)];

    testWidgets('shows the khata, the interest due and the final amount', (
      tester,
    ) async {
      await pump(
        tester,
        const SettlementScreen(partyId: 'p1'),
        party: [cand('Gurmeet', 493151)],
        entries: entries,
      );
      expect(money(tester, 'settle-balance'), const Money.rupees(-100000));
      expect(money(tester, 'settle-interest-due'), const Money(493151));
      // The party owes 1,00,000 + 4,931.51.
      expect(money(tester, 'settle-final'), const Money(10493151));
      expect(find.text('Party pays you'), findsOneWidget);
    });

    testWidgets('a discount lowers the final amount; it needs a reason', (
      tester,
    ) async {
      await pump(
        tester,
        const SettlementScreen(partyId: 'p1'),
        party: [cand('Gurmeet', 493151)],
        entries: entries,
      );
      await tester.enterText(key('settle-waiver-khata'), '931.51');
      await tester.pumpAndSettle();
      expect(money(tester, 'settle-final'), const Money(10400000));
      expect(key('settle-problems'), findsOneWidget);
      expect(
        tester.widget<MkButton>(key('settle-post')).onPressed,
        isNull,
        reason: 'no reason yet',
      );

      await tester.enterText(key('settle-reason'), 'Diwali');
      await tester.pumpAndSettle();
      expect(key('settle-problems'), findsNothing);
      await tester.tap(key('settle-post'));
      await tester.pumpAndSettle();
      expect(writer.settled.single.partyId, 'p1');
      expect(writer.settled.single.waivers, {'khata': 93151});
      expect(writer.settled.single.reason, 'Diwali');
      expect(
        find.textContaining('Interest ₹4,931.51 posted, ₹931.51 waived'),
        findsOneWidget,
      );
    });

    testWidgets('a discount above the interest is refused on screen', (
      tester,
    ) async {
      await pump(
        tester,
        const SettlementScreen(partyId: 'p1'),
        party: [cand('Gurmeet', 493151)],
        entries: entries,
      );
      await tester.enterText(key('settle-waiver-khata'), '5000');
      await tester.enterText(key('settle-reason'), 'x');
      await tester.pumpAndSettle();
      expect(
        find.text('The discount is more than the interest charged.'),
        findsOneWidget,
      );
      expect(tester.widget<MkButton>(key('settle-post')).onPressed, isNull);
      // The final amount ignores an impossible discount.
      expect(money(tester, 'settle-final'), const Money(10493151));
    });

    testWidgets('a loan has its own discount field', (tester) async {
      await pump(
        tester,
        const SettlementScreen(partyId: 'p1'),
        party: [
          cand('Gurmeet', 493151),
          cand('Gurmeet', 100000, loanId: 'L1', loanNo: 'KZ-W1-1'),
        ],
        entries: entries,
      );
      expect(key('settle-waiver-khata'), findsOneWidget);
      expect(key('settle-waiver-loan:L1'), findsOneWidget);
      expect(money(tester, 'settle-interest-due'), const Money(593151));
    });

    testWidgets('no interest due: only print, no post', (tester) async {
      await pump(
        tester,
        const SettlementScreen(partyId: 'p1'),
        entries: entries,
      );
      expect(key('settle-nothing'), findsOneWidget);
      expect(key('settle-post'), findsNothing);
      expect(key('settle-print'), findsOneWidget);
      expect(money(tester, 'settle-final'), const Money.rupees(100000));
    });

    testWidgets('without entries.reverse there is no discount field', (
      tester,
    ) async {
      await pump(
        tester,
        const SettlementScreen(partyId: 'p1'),
        party: [cand('Gurmeet', 493151)],
        entries: entries,
        reverse: false,
      );
      expect(key('settle-waiver-khata'), findsNothing);
      expect(key('settle-post'), findsOneWidget);
    });

    testWidgets('without loans.manage the screen refuses', (tester) async {
      await pump(
        tester,
        const SettlementScreen(partyId: 'p1'),
        party: [cand('Gurmeet', 493151)],
        entries: entries,
        manage: false,
      );
      expect(key('settle-post'), findsNothing);
    });

    testWidgets('a credit balance shows what you pay the party', (
      tester,
    ) async {
      await pump(
        tester,
        const SettlementScreen(partyId: 'p1'),
        entries: [entry(Side.jama, 5000, RefType.arrival)],
      );
      expect(find.text('You pay the party'), findsOneWidget);
      expect(money(tester, 'settle-final'), const Money.rupees(5000));
    });
  });
}
