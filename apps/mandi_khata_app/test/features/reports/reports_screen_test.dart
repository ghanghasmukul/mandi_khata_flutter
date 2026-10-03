import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/features/reports/domain/report_models.dart';
import 'package:mandi_khata_app/features/reports/presentation/reports_providers.dart';
import 'package:mandi_khata_app/features/reports/presentation/reports_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

Future<void> pump(
  WidgetTester tester, {
  MemberRole role = MemberRole.owner,
  ReportKind kind = ReportKind.outstanding,
  List<OutstandingRow> outstanding = const [],
}) async {
  tester.view.physicalSize = const Size(1400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        outstandingReportProvider.overrideWith((ref, args) => outstanding),
        commissionReportProvider.overrideWith((ref, filter) => const []),
        cropListProvider.overrideWith(
          (ref, includeInactive) => Stream.value(const []),
        ),
        farmerVillagesProvider.overrideWith((ref) => const []),
        syncErrorsProvider.overrideWith((ref) => Stream.value(const [])),
        activeMembershipProvider.overrideWithValue(
          Membership(tenantId: 't1', tenantName: 'Gupta Arhat', role: role),
        ),
      ],
      child: MaterialApp(
        theme: MkTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ReportsScreen(initial: kind),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

OutstandingRow party(String name, int balance, LedgerDate last) =>
    OutstandingRow(
      partyId: name,
      code: 'C-$name',
      name: name,
      balance: Money(balance),
      lastEntry: last,
    );

void main() {
  final recent = LedgerDate.fromDateTime(DateTime.now()).addDays(-5);
  final old = LedgerDate.fromDateTime(DateTime.now()).addDays(-400);

  testWidgets('lists who owes what with ageing and totals', (tester) async {
    await pump(
      tester,
      outstanding: [
        party('Gurmeet', 500000, recent),
        party('Bansal', -900000, old),
      ],
    );
    expect(find.text('Gurmeet'), findsOneWidget);
    expect(find.text('Bansal'), findsOneWidget);
    expect(find.text('2 rows'), findsOneWidget);
    // Ageing cards.
    expect(find.text('0–30 days'), findsWidgets);
    expect(find.text('Over 180 days'), findsWidgets);
    // Totals strip: we owe ₹5,000, they owe ₹9,000.
    expect(find.textContaining('₹5,000'), findsWidgets);
    expect(find.textContaining('₹9,000'), findsWidgets);
  });

  testWidgets('an owner can export, a munshi cannot', (tester) async {
    await pump(tester, outstanding: [party('Gurmeet', 500000, recent)]);
    for (final k in [
      'report-pdf',
      'report-excel',
      'report-csv',
      'report-print',
    ]) {
      final button = tester.widget<MkButton>(find.byKey(ValueKey(k)));
      expect(button.onPressed, isNotNull, reason: k);
    }

    await pump(
      tester,
      role: MemberRole.munshi,
      outstanding: [party('Gurmeet', 500000, recent)],
    );
    for (final k in [
      'report-pdf',
      'report-excel',
      'report-csv',
      'report-print',
    ]) {
      final button = tester.widget<MkButton>(find.byKey(ValueKey(k)));
      expect(button.onPressed, isNull, reason: k);
    }
    // The report itself is still readable.
    expect(find.text('Gurmeet'), findsOneWidget);
  });

  testWidgets('the commission report is closed to a munshi', (tester) async {
    await pump(tester, role: MemberRole.munshi, kind: ReportKind.commission);
    expect(find.text('This report needs finance access'), findsOneWidget);
    expect(find.byKey(const ValueKey('report-pdf')), findsNothing);
  });

  testWidgets('says so when there is nothing to show', (tester) async {
    await pump(tester);
    expect(find.text('Nothing to show for these filters'), findsOneWidget);
  });

  testWidgets('switching report resets the filters', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('report-kind-commission')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('report-asof')), findsNothing);
  });
}
