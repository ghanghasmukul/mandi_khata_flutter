import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/dashboard/domain/alerts.dart';
import 'package:mandi_khata_app/features/dashboard/domain/dashboard.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_providers.dart';
import 'package:mandi_khata_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

final today = LedgerDate(2026, 10, 3);

Future<void> pump(
  WidgetTester tester, {
  MemberRole role = MemberRole.owner,
  DaySummary day = DaySummary.empty,
  List<DayAmount> earned = const [],
  List<CropSale> crops = const [],
  MoneyPosition position = MoneyPosition.empty,
  AttentionCounts attention = AttentionCounts.none,
  int rejected = 0,
  LoanAlerts loans = LoanAlerts.none,
  CreditAlerts credit = CreditAlerts.none,
  UnpostedInterest? unposted,
}) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayProvider.overrideWith((ref) => Stream.value(today)),
        daySummaryProvider.overrideWith((ref) => Stream.value(day)),
        earnedDaysProvider.overrideWith((ref) => Stream.value(earned)),
        cropMixProvider.overrideWith((ref) => Stream.value(crops)),
        moneyPositionProvider.overrideWith((ref) => Stream.value(position)),
        attentionCountsProvider.overrideWith((ref) => Stream.value(attention)),
        loanAlertsProvider.overrideWith((ref) => Stream.value(loans)),
        creditAlertsProvider.overrideWith((ref) => Stream.value(credit)),
        unpostedInterestProvider.overrideWith((ref) => Stream.value(unposted)),
        syncErrorsProvider.overrideWith(
          (ref) => Stream.value([
            for (var i = 0; i < rejected; i++)
              (
                id: '$i',
                table: 'lots',
                rowId: 'r$i',
                op: 'PUT',
                code: null,
                message: 'no',
                at: null,
              ),
          ]),
        ),
        activeMembershipProvider.overrideWithValue(
          Membership(tenantId: 't1', tenantName: 'Gupta Arhat', role: role),
        ),
      ],
      child: MaterialApp(
        theme: MkTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: DashboardView()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the day in the hero and the stat tiles', (tester) async {
    await pump(
      tester,
      day: const DaySummary(
        lots: 5,
        qtlMilli: 86400,
        arhatEarned: Money(723000),
        paidOut: Money(1200000),
        receipts: Money(500000),
      ),
      position: const MoneyPosition(
        farmersPayable: Money(15558000),
        farmersReceivable: Money(100000),
        othersReceivable: Money(132800000),
      ),
    );
    expect(find.textContaining('Gupta Arhat'), findsOneWidget);
    expect(find.textContaining('5 lots in today'), findsOneWidget);
    expect(find.textContaining('₹7,230 arhat earned'), findsOneWidget);
    expect(find.text('86.40 qtl'), findsOneWidget);
    // In the hero and again in "Where the money is".
    expect(find.text('₹1.56 L'), findsNWidgets(2));
    expect(find.text('WE OWE FARMERS'), findsOneWidget);
    // Others owe us = farmers owe + other parties owe.
    expect(find.text('₹13.29 L'), findsOneWidget);
  });

  testWidgets('says so when no lot came in yet', (tester) async {
    await pump(tester);
    expect(find.text('No lots in yet today'), findsOneWidget);
    expect(find.text('No arhat earned in these days yet'), findsOneWidget);
    expect(find.text('No posted sales this season yet'), findsOneWidget);
    expect(find.text('Nothing needs you right now'), findsOneWidget);
  });

  testWidgets('lists crops of this season with the financial year', (
    tester,
  ) async {
    await pump(
      tester,
      crops: const [
        CropSale(
          cropId: 'c1',
          code: 'paddy',
          nameEn: 'Paddy',
          nameHi: null,
          namePa: null,
          gross: Money(2500000),
          lots: 3,
        ),
      ],
    );
    expect(find.text('Crop mix by sale value · 2026-27'), findsOneWidget);
    expect(find.text('Paddy'), findsOneWidget);
    expect(find.text('3 lots'), findsOneWidget);
  });

  testWidgets('draws the arhat chart once something was earned', (
    tester,
  ) async {
    await pump(
      tester,
      earned: DashboardDays.chart(today, {today: const Money(50000)}),
    );
    expect(find.text('No arhat earned in these days yet'), findsNothing);
    expect(find.text('3'), findsOneWidget); // today's day-of-month label
  });

  testWidgets("needs-you rows follow the member's permissions", (tester) async {
    const attention = AttentionCounts(
      chequesDue: 2,
      chequesDueAmount: Money(500000),
      staffChanges: 4,
    );
    await pump(tester, attention: attention, rejected: 1);
    expect(find.text('1 change was rejected by the server'), findsOneWidget);
    expect(find.text('2 cheques due · ₹5,000'), findsOneWidget);
    expect(
      find.text('4 changes by munshis in the last 7 days'),
      findsOneWidget,
    );

    await pump(tester, role: MemberRole.munshi, attention: attention);
    expect(find.text('2 cheques due · ₹5,000'), findsOneWidget);
    expect(find.textContaining('changes by munshis'), findsNothing);
  });

  testWidgets('quick actions: owner sees all four, munshi only its own', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Add farmer'), findsOneWidget);
    expect(find.text('New arrival'), findsOneWidget);
    expect(find.text('Khata entry'), findsOneWidget);
    expect(find.text('Record payment'), findsOneWidget);

    await pump(tester, role: MemberRole.munshi);
    expect(find.text('New arrival'), findsOneWidget);
    expect(find.text('Record payment'), findsOneWidget);
    expect(find.text('Khata entry'), findsNothing);
  });

  group('loan, credit and interest alerts', () {
    final unposted = UnpostedInterest(
      asOf: LedgerDate(2026, 10, 1),
      accounts: 3,
      amount: const Money(1250000),
    );

    testWidgets('an owner sees every alert', (tester) async {
      await pump(
        tester,
        loans: const LoanAlerts(overdue: 2, dueSoon: 1),
        credit: const CreditAlerts(count: 4, excess: Money(900000)),
        unposted: unposted,
      );
      expect(find.text('2 loans are overdue'), findsOneWidget);
      expect(find.text('1 loan is due in 7 days'), findsOneWidget);
      expect(find.text('4 parties are over the credit limit'), findsOneWidget);
      expect(
        find.textContaining('Interest for the last quarter is not posted: '),
        findsOneWidget,
      );
      expect(find.textContaining('3 accounts'), findsOneWidget);
      expect(find.text('Nothing needs you right now'), findsNothing);
    });

    testWidgets('a munshi sees none of them', (tester) async {
      await pump(
        tester,
        role: MemberRole.munshi,
        loans: const LoanAlerts(overdue: 2, dueSoon: 1),
        credit: const CreditAlerts(count: 4, excess: Money(900000)),
      );
      expect(find.textContaining('overdue'), findsNothing);
      expect(find.textContaining('credit limit'), findsNothing);
      expect(find.text('Nothing needs you right now'), findsOneWidget);
    });
  });
}
