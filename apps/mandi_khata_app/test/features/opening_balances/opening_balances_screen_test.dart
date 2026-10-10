import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/opening_balances/data/opening_balances_repository.dart';
import 'package:mandi_khata_app/features/opening_balances/presentation/opening_balances_providers.dart';
import 'package:mandi_khata_app/features/opening_balances/presentation/opening_balances_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

class _Importer implements OpeningBalanceImporter {
  _Importer({this.existing = const [], this.result});

  final List<ExistingParty> existing;
  OpeningImportResult? result;
  OpeningPreview? imported;
  LedgerDate? asOn;

  @override
  Future<List<ExistingParty>> existingParties() async => existing;

  @override
  Future<bool> alreadyImported(OpeningPreview p, LedgerDate d) async => false;

  @override
  Future<OpeningImportResult> run(
    OpeningPreview preview, {
    required LedgerDate asOn,
    String? fileName,
    String source = 'file',
  }) async {
    imported = preview;
    this.asOn = asOn;
    return result ??
        OpeningImported(
          batchId: 'b',
          newParties: preview.newParties,
          entries: preview.entries,
          totalUdhaar: preview.totalUdhaar,
          totalJama: preview.totalJama,
        );
  }
}

class _Tenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

void main() {
  late _Importer importer;
  PickedFile? picked;

  Future<void> pump(
    WidgetTester tester, {
    MemberRole role = MemberRole.owner,
  }) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const OpeningBalancesScreen()),
        GoRoute(path: '/parties', builder: (_, _) => const Text('parties')),
        GoRoute(path: '/home', builder: (_, _) => const Text('home')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeTenantProvider.overrideWith(_Tenant.new),
          activeMembershipProvider.overrideWithValue(
            Membership(tenantId: 't1', tenantName: 'Gupta', role: role),
          ),
          openingBalanceImporterProvider.overrideWithValue(importer),
          importFilePickerProvider.overrideWithValue(() async => picked),
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

  setUp(() {
    importer = _Importer();
    picked = null;
  });

  Future<void> paste(WidgetTester t, String text) async {
    await t.enterText(find.byKey(const ValueKey('ob-paste')), text);
    await t.ensureVisible(find.byKey(const ValueKey('ob-read-paste')));
    await t.tap(find.byKey(const ValueKey('ob-read-paste')));
    await t.pumpAndSettle();
  }

  testWidgets('pasted table: preview, totals, import, done', (t) async {
    await pump(t);
    await paste(
      t,
      'Name\tVillage\tAmount\tType\n'
      'Ramesh\tRampura\t15000\tDr\n'
      'Sita\tRampura\t4000\tCr\n',
    );
    expect(find.text('₹15,000'), findsWidgets);
    expect(find.text('Import 2 balances'), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('ob-import')));
    await t.tap(find.byKey(const ValueKey('ob-import')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('ob-confirm')));
    await t.pumpAndSettle();
    expect(importer.imported!.entries, 2);
    expect(find.text('Opening balances imported'), findsOneWidget);
  });

  testWidgets('a row with no Dr/Cr is an error until a side is chosen', (
    t,
  ) async {
    await pump(t);
    await paste(t, 'Name,Amount\nRamesh,500\n');
    expect(
      find.textContaining('Not clear if this is udhaar or jama'),
      findsOneWidget,
    );
    expect(
      t.widget<MkButton>(find.byKey(const ValueKey('ob-import'))).onPressed,
      isNull,
    );
    await t.tap(find.byKey(const ValueKey('ob-side-udhaar')));
    await t.pumpAndSettle();
    expect(find.textContaining('Not clear'), findsNothing);
    expect(find.text('Import 1 balances'), findsOneWidget);
  });

  testWidgets('problem rows can be skipped explicitly', (t) async {
    await pump(t);
    await paste(t, 'Name,Amount,Type\nRamesh,100,Dr\n,5,Dr\n');
    expect(find.textContaining('Name is missing.'), findsOneWidget);
    expect(find.text('Import 1 balances, skip 1 problem rows'), findsOneWidget);
  });

  testWidgets('existing party that already has an opening balance is refused', (
    t,
  ) async {
    importer = _Importer(
      existing: const [
        ExistingParty(
          id: 'p1',
          code: 'F-1',
          name: 'Ramesh',
          village: 'Rampura',
          hasOpeningBalance: true,
        ),
      ],
    );
    await pump(t);
    await paste(t, 'Name,Village,Amount,Type\nRamesh,Rampura,100,Dr\n');
    expect(
      find.text('This party already has an opening balance.'),
      findsOneWidget,
    );
    expect(
      t.widget<MkButton>(find.byKey(const ValueKey('ob-import'))).onPressed,
      isNull,
    );
  });

  testWidgets('a picked CSV file is read', (t) async {
    picked = PickedFile(
      'baki.csv',
      utf8.encode('﻿Name,Amount,Type\nRamesh,100,Dr\n'),
    );
    await pump(t);
    await t.tap(find.byKey(const ValueKey('ob-pick-file')));
    await t.pumpAndSettle();
    expect(find.text('baki.csv'), findsOneWidget);
    expect(find.text('Import 1 balances'), findsOneWidget);
  });

  testWidgets('an old .xls file gets a clear message', (t) async {
    picked = PickedFile('old.xls', utf8.encode('x'));
    await pump(t);
    await t.tap(find.byKey(const ValueKey('ob-pick-file')));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('ob-read-error')), findsOneWidget);
  });

  testWidgets('a failed import shows why and nothing is claimed done', (
    t,
  ) async {
    importer = _Importer(result: const OpeningStale(3));
    await pump(t);
    await paste(t, 'Name,Amount,Type\nRamesh,100,Dr\n');
    await t.ensureVisible(find.byKey(const ValueKey('ob-import')));
    await t.tap(find.byKey(const ValueKey('ob-import')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('ob-confirm')));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('ob-failure')), findsOneWidget);
    expect(find.text('Opening balances imported'), findsNothing);
  });

  testWidgets('a munshi cannot import', (t) async {
    await pump(t, role: MemberRole.munshi);
    expect(find.byKey(const ValueKey('ob-pick-file')), findsNothing);
  });
}
