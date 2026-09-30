import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/crops/data/crops_repository.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/features/crops/presentation/crop_detail_screen.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_screen.dart';
import 'package:mandi_khata_app/features/crops/presentation/mandi_breakdown_view.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

import '../settings/settings_screen_test.dart' show FakeSettingsRepository;

const ctx = WriteContext(
  tenantId: 't1',
  userId: 'u1',
  deviceId: 'd1',
  deviceCode: 'W1',
);

/// In-memory crops with the real validation and permission rules.
class FakeCropsRepository implements CropsRepository {
  final crops = <Crop>[];
  final _changed = StreamController<void>.broadcast();

  Stream<T> _live<T>(T Function() read) {
    StreamSubscription<void>? changes;
    late final StreamController<T> out;
    out = StreamController<T>(
      onListen: () {
        changes = _changed.stream.listen((_) => out.add(read()));
        out.add(read());
      },
      onCancel: () => changes?.cancel(),
    );
    return out.stream;
  }

  @override
  Stream<List<Crop>> watchAll(
    String tenantId, {
    bool includeInactive = false,
  }) => _live(
    () => [
      for (final c in crops)
        if (includeInactive || c.isActive) c,
    ],
  );

  @override
  Stream<Crop?> watchOne(String tenantId, String id) => _live(() {
    for (final c in crops) {
      if (c.id == id) return c;
    }
    return null;
  });

  Crop _from(String id, CropInput input, int sort) {
    final n = input.normalised();
    return Crop(
      id: id,
      code: n.code,
      nameEn: n.nameEn,
      nameHi: n.nameHi,
      namePa: n.namePa,
      stdRate: n.stdRate,
      unit: 'qtl',
      sortOrder: sort,
      isActive: n.isActive,
    );
  }

  @override
  Future<CropSaveResult> create(
    WriteContext ctx,
    CropInput input, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.settingsManage)) return const CropNotPermitted();
    final errors = input.validate();
    if (errors.isNotEmpty) return CropInvalid(errors);
    if (crops.any((c) => c.code == input.code.trim())) {
      return const CropCodeTaken();
    }
    final id = 'crop-${input.code.trim()}';
    crops.add(_from(id, input, crops.length * 10 + 10));
    _changed.add(null);
    return CropSaved(id);
  }

  @override
  Future<CropSaveResult> update(
    WriteContext ctx,
    String id,
    CropInput input, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    if (!can(Permission.settingsManage)) return const CropNotPermitted();
    final i = crops.indexWhere((c) => c.id == id);
    if (i < 0) return const CropNotFound();
    crops[i] = _from(id, input, crops[i].sortOrder);
    _changed.add(null);
    return CropSaved(id);
  }
}

class _FixedTenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

const wheat = Crop(
  id: 'crop-wheat',
  code: 'wheat',
  nameEn: 'Wheat',
  nameHi: 'गेहूं',
  namePa: 'ਕਣਕ',
  unit: 'qtl',
  stdRate: Money.rupees(2585),
  sortOrder: 10,
  isActive: true,
);

const guar = Crop(
  id: 'crop-guar',
  code: 'guar',
  nameEn: 'Guar',
  unit: 'qtl',
  sortOrder: 20,
  isActive: false,
);

void main() {
  late FakeCropsRepository crops;
  late FakeSettingsRepository settings;

  setUp(() {
    crops = FakeCropsRepository()..crops.addAll(const [wheat, guar]);
    settings = FakeSettingsRepository();
  });

  Future<void> pump(
    WidgetTester tester,
    MemberRole role, {
    String start = '/crops',
  }) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: start,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(
          path: '/crops',
          builder: (_, _) => const CropsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, s) =>
                  CropDetailScreen(cropId: s.pathParameters['id']!),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cropsRepositoryProvider.overrideWith((ref) async => crops),
          settingsRepositoryProvider.overrideWith((ref) async => settings),
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

  Finder tileOf(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(Wrap)).first;

  Finder fieldIn(String label) =>
      find.descendant(of: tileOf(label), matching: find.byType(TextField));

  /// The amount on a line of the example breakdown.
  String exampleLine(WidgetTester tester, String label) {
    final row = find
        .ancestor(
          of: find.descendant(
            of: find.byType(MandiBreakdownView),
            matching: find.textContaining(label),
          ),
          matching: find.byType(Row),
        )
        .first;
    return tester
        .widget<Text>(
          find.descendant(of: row, matching: find.byType(Text)).last,
        )
        .data!;
  }

  group('list', () {
    testWidgets('inactive crops are hidden until asked for', (tester) async {
      await pump(tester, MemberRole.owner);
      expect(find.text('Wheat'), findsOneWidget);
      expect(find.text('wheat · ₹2,585/qtl'), findsOneWidget);
      expect(find.text('Guar'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('crops-show-inactive')));
      await tester.pumpAndSettle();
      expect(find.text('Guar'), findsOneWidget);
      expect(find.text('Not in use'), findsOneWidget);
    });

    testWidgets('names follow the app language', (tester) async {
      await pump(tester, MemberRole.owner);
      final context = tester.element(find.byType(CropsScreen));
      expect(
        wheat.nameIn(Localizations.localeOf(context).languageCode),
        'Wheat',
      );
      expect(wheat.nameIn('pa'), 'ਕਣਕ');
      expect(guar.nameIn('hi'), 'Guar');
    });

    testWidgets('owner adds a crop (Ctrl+N); the code follows the name', (
      tester,
    ) async {
      await pump(tester, MemberRole.owner);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('Add crop'), findsWidgets);

      Finder field(String key) => find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(TextField),
      );
      await tester.tap(find.byKey(const ValueKey('crop-save')));
      await tester.pumpAndSettle();
      expect(find.text('Enter the English name.'), findsOneWidget);

      await tester.enterText(field('crop-name-en'), 'Paddy PR-131');
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(field('crop-code')).controller!.text,
        'paddy_pr_131',
      );
      await tester.enterText(field('crop-name-hi'), 'धान PR-131');
      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey('crop-rate')),
          matching: find.byType(TextField),
        ),
        '2369',
      );
      await tester.tap(find.byKey(const ValueKey('crop-save')));
      await tester.pumpAndSettle();

      final added = crops.crops.last;
      expect(added.code, 'paddy_pr_131');
      expect(added.nameHi, 'धान PR-131');
      expect(added.stdRate, const Money.rupees(2369));
      // Opens the new crop's page.
      expect(find.text('Mandi charges for this crop'), findsOneWidget);
    });

    testWidgets('a used code is refused', (tester) async {
      await pump(tester, MemberRole.owner);
      await tester.tap(find.text('Add crop'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey('crop-name-en')),
          matching: find.byType(TextField),
        ),
        'Wheat',
      );
      await tester.tap(find.byKey(const ValueKey('crop-save')));
      await tester.pumpAndSettle();
      expect(
        find.text('A crop with this code already exists.'),
        findsOneWidget,
      );
      expect(crops.crops, hasLength(2));
    });

    testWidgets('a munshi cannot add crops', (tester) async {
      await pump(tester, MemberRole.munshi);
      expect(find.text('Add crop'), findsNothing);
    });
  });

  group('crop page', () {
    testWidgets('example uses the crop MSP and system defaults', (
      tester,
    ) async {
      await pump(tester, MemberRole.owner, start: '/crops/crop-wheat');
      // 20 bags × 50 kg = 10 qtl @ ₹2,585 = ₹25,850
      expect(
        find.text('Example: 20 bags · 10 qtl @ ₹2,585/qtl'),
        findsOneWidget,
      );
      expect(exampleLine(tester, 'Gross'), '₹25,850');
      // 2.5% = 646.25; palledari 240; bardana 160; tulai 30; fee 258.50
      expect(exampleLine(tester, 'Arhat (commission)'), '-₹646.25');
      expect(exampleLine(tester, 'Net to farmer'), '₹24,515.25');
      expect(
        find.descendant(
          of: tileOf('Commission (arhat) %'),
          matching: find.textContaining('App default'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a per-crop value beats the business value', (tester) async {
      settings.rows.add(
        const SettingRow(
          scope: SettingScope.tenant,
          key: 'mandi.commission_pct',
          value: '2',
        ),
      );
      await pump(tester, MemberRole.owner, start: '/crops/crop-wheat');
      expect(
        find.descendant(
          of: tileOf('Commission (arhat) %'),
          matching: find.textContaining('From business setting'),
        ),
        findsOneWidget,
      );
      expect(exampleLine(tester, 'Arhat (commission)'), '-₹517');

      await tester.enterText(fieldIn('Commission (arhat) %'), '2.25');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final row = settings.rows.firstWhere(
        (r) => r.key == 'mandi.commission_pct.wheat',
      );
      expect((row.scope, row.value), (SettingScope.tenant, '2.25'));
      expect(
        find.descendant(
          of: tileOf('Commission (arhat) %'),
          matching: find.textContaining('Set here'),
        ),
        findsOneWidget,
      );
      // 2.25% of 25,850 = 581.625 → 581.63
      expect(exampleLine(tester, 'Arhat (commission)'), '-₹581.63');
    });

    testWidgets('who pays: the mandi fee moves to the buyer', (tester) async {
      await pump(tester, MemberRole.owner, start: '/crops/crop-wheat');
      await tester.tap(
        find.byKey(const ValueKey('edit-mandi.charges_borne_by')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('payer-mandi_fee')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buyer').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('payers-save')));
      await tester.pumpAndSettle();

      final row = settings.rows.single;
      expect(row.key, 'mandi.charges_borne_by.wheat');
      expect(row.value, {
        'commission': 'farmer',
        'palledari': 'farmer',
        'bardana': 'farmer',
        'tulai': 'farmer',
        'mandi_fee': 'buyer',
        'cess': 'farmer',
      });
      expect(find.text('Mandi fee: Buyer'), findsOneWidget);
      // Fee no longer deducted: 25,850 − (646.25 + 240 + 160 + 30)
      expect(exampleLine(tester, 'Net to farmer'), '₹24,773.75');
      expect(exampleLine(tester, 'Buyer pays'), '₹26,108.50');
    });

    testWidgets('cess list: add a row, bad rows are refused', (tester) async {
      await pump(tester, MemberRole.owner, start: '/crops/crop-wheat');
      await tester.tap(find.byKey(const ValueKey('edit-mandi.cess')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('cess-add')));
      await tester.pumpAndSettle();
      Finder input(String key) => find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(TextField),
      );
      await tester.enterText(input('cess-pct-0'), '2');
      await tester.tap(find.byKey(const ValueKey('cess-save')));
      await tester.pumpAndSettle();
      expect(find.text('Invalid value'), findsOneWidget);
      expect(settings.rows, isEmpty);

      await tester.enterText(input('cess-name-0'), 'RDF');
      await tester.tap(find.byKey(const ValueKey('cess-save')));
      await tester.pumpAndSettle();
      expect(settings.rows.single.key, 'mandi.cess.wheat');
      expect(settings.rows.single.value, [
        {'name': 'RDF', 'pct': '2'},
      ]);
      // 2% of 25,850
      expect(exampleLine(tester, 'RDF'), '-₹517');
    });

    testWidgets('a munshi sees the crop read-only', (tester) async {
      await pump(tester, MemberRole.munshi, start: '/crops/crop-wheat');
      expect(find.byKey(const ValueKey('crop-edit')), findsNothing);
      expect(
        tester.widget<TextField>(fieldIn('Commission (arhat) %')).enabled,
        isFalse,
      );
      final edit = tester.widget<IconButton>(
        find.byKey(const ValueKey('edit-mandi.cess')),
      );
      expect(edit.onPressed, isNull);
    });

    testWidgets('owner switches a crop off from its page', (tester) async {
      await pump(tester, MemberRole.owner, start: '/crops/crop-wheat');
      await tester.tap(find.byKey(const ValueKey('crop-edit')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('crop-active')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('crop-save')));
      await tester.pumpAndSettle();
      expect(crops.crops.first.isActive, isFalse);
      expect(find.textContaining('Not in use'), findsOneWidget);
    });

    testWidgets('unknown crop', (tester) async {
      await pump(tester, MemberRole.owner, start: '/crops/nope');
      expect(find.text('This crop no longer exists.'), findsOneWidget);
    });
  });
}
