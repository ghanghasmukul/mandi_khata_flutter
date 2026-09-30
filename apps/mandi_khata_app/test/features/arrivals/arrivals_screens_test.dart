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
import 'package:mandi_khata_app/features/arrivals/data/lots_repository.dart';
import 'package:mandi_khata_app/features/arrivals/domain/lot.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrival_wizard.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_providers.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/arrivals_screen.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/lot_detail_screen.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/lot_form_screen.dart';
import 'package:mandi_khata_app/features/arrivals/presentation/lot_preview_panel.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/features/parties/domain/party.dart';
import 'package:mandi_khata_app/features/parties/presentation/parties_providers.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

import '../crops/crops_screens_test.dart' show FakeCropsRepository, wheat;
import '../parties/parties_screens_test.dart' show FakePartiesRepository;
import '../settings/settings_screen_test.dart' show FakeSettingsRepository;

const ctx = WriteContext(
  tenantId: 't1',
  userId: 'u1',
  deviceId: 'd1',
  deviceCode: 'W1',
);

/// Records what the screens ask for; lots are whatever the test puts in.
class FakeLotsRepository implements LotsRepository {
  final lots = <Lot>[];
  final saved = <({LotDraft draft, String? id, bool post})>[];
  final reversed = <String>[];
  final cancelled = <String>[];
  LotSaveResult? nextResult;
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
  Map<String, Object?> get planDefaults => const {};

  @override
  Stream<List<Lot>> watchAll(String tenantId, LotFilter filter) => _live(
    () => [
      for (final l in lots)
        if ((filter.status == null || l.status == filter.status) &&
            (filter.from == null || l.entryDate >= filter.from!) &&
            (filter.to == null || l.entryDate <= filter.to!))
          l,
    ],
  );

  @override
  Stream<Lot?> watchOne(String tenantId, String id) => _live(() {
    for (final l in lots) {
      if (l.id == id) return l;
    }
    return null;
  });

  @override
  Stream<List<LedgerEntry>> watchEntries(String tenantId, String lotId) =>
      Stream.value(const []);

  @override
  Future<String> previewNextLotNo(WriteContext ctx) async => 'L-W1-0007';

  @override
  Future<LotSaveResult> save(
    WriteContext ctx,
    LotDraft draft, {
    required bool Function(Permission) can,
    String? id,
    bool post = true,
    DateTime? now,
  }) async {
    saved.add((draft: draft, id: id, post: post));
    return nextResult ??
        LotSaved(
          id ?? 'lot-new',
          'L-W1-0007',
          post && draft.qtlMilli != null && draft.rate != null
              ? LotStatus.posted
              : LotStatus.draftFor(qtlMilli: draft.qtlMilli, rate: draft.rate),
        );
  }

  @override
  Future<LotSaveResult> reverse(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    reversed.add(id);
    return LotSaved(id, 'L-W1-0001', LotStatus.reversed);
  }

  @override
  Future<LotSaveResult> cancel(
    WriteContext ctx,
    String id, {
    required bool Function(Permission) can,
    DateTime? now,
  }) async {
    cancelled.add(id);
    return LotSaved(id, 'L-W1-0001', LotStatus.reversed);
  }
}

class _FixedTenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

const gurmeet = Party(
  id: 'p-gurmeet',
  code: 'F-1',
  name: 'Gurmeet Singh',
  roles: {PartyRole.farmer},
  village: 'Bhucho',
);
const bansal = Party(
  id: 'p-bansal',
  code: 'B-1',
  name: 'Bansal Traders',
  roles: {PartyRole.buyer},
);

final today = LedgerDate.fromDateTime(DateTime.now());

Lot postedLot({String id = 'lot-1', LotStatus status = LotStatus.posted}) =>
    Lot(
      id: id,
      lotNo: 'L-W1-0001',
      entryDate: today,
      farmerId: gurmeet.id,
      farmerName: gurmeet.name,
      cropId: wheat.id,
      cropCode: 'wheat',
      cropName: const {'en': 'Wheat'},
      bags: 18,
      qtlMilli: 8640,
      qtlFromBags: false,
      rate: const Money.rupees(2425),
      status: status,
      snapshot: MandiConfig.resolve(SettingsResolver(const [])),
      gross: const Money(2095200),
      commission: const Money(52380),
      netToFarmer: const Money(1983276),
      buyerTotal: const Money(2095200),
      postedAt: DateTime.utc(2026, 4, 10),
    );

Lot arrivedLot() => Lot(
  id: 'lot-2',
  lotNo: 'L-A1-0002',
  entryDate: today,
  farmerId: gurmeet.id,
  farmerName: gurmeet.name,
  cropId: wheat.id,
  cropCode: 'wheat',
  cropName: const {'en': 'Wheat'},
  bags: 12,
  qtlFromBags: false,
  status: LotStatus.arrived,
);

void main() {
  late FakeLotsRepository lots;
  late FakePartiesRepository parties;
  late FakeCropsRepository crops;
  late FakeSettingsRepository settings;

  setUp(() {
    lots = FakeLotsRepository();
    parties = FakePartiesRepository()..parties.addAll(const [gurmeet, bansal]);
    crops = FakeCropsRepository()..crops.add(wheat);
    settings = FakeSettingsRepository();
  });

  Future<void> pump(
    WidgetTester tester,
    String start, {
    MemberRole role = MemberRole.owner,
    Size size = const Size(1400, 1600),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: start,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(
          path: '/arrivals',
          builder: (_, _) => const ArrivalsScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, _) => const LotFormScreen()),
            GoRoute(
              path: ':id',
              builder: (_, s) =>
                  LotDetailScreen(lotId: s.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, s) =>
                      LotFormScreen(lotId: s.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lotsRepositoryProvider.overrideWith((ref) async => lots),
          partiesRepositoryProvider.overrideWith((ref) async => parties),
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

  Finder field(String label) => find.descendant(
    of: find
        .ancestor(of: find.text(label), matching: find.byType(Column))
        .first,
    matching: find.byType(TextField),
  );

  Future<void> pickFarmer(WidgetTester tester) async {
    await tester.enterText(field('Farmer'), 'gur');
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();
  }

  Future<void> pickWheat(WidgetTester tester) async {
    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wheat').last);
    await tester.pumpAndSettle();
  }

  group('desktop lot form', () {
    testWidgets('keyboard entry, live calculation, F10 posts', (tester) async {
      await pump(tester, '/arrivals/new');
      expect(find.text('Lot L-W1-0007'), findsOneWidget);

      await pickFarmer(tester);
      expect(find.text('Gurmeet Singh'), findsOneWidget);
      await pickWheat(tester);
      await tester.enterText(field('Bags'), '18');
      await tester.enterText(field('Qtl'), '8.64');
      await tester.enterText(field('Rate'), '2425');
      await tester.pumpAndSettle();

      final panel = find.byType(LotPreviewPanel);
      expect(
        find.descendant(of: panel, matching: find.text('₹19,832.76')),
        findsWidgets,
      );
      expect(find.text('Save & post (F10)'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.f10);
      await tester.pumpAndSettle();
      final s = lots.saved.single;
      expect(s.post, isTrue);
      expect(s.draft.farmerId, gurmeet.id);
      expect(s.draft.cropId, wheat.id);
      expect(s.draft.bags, 18);
      expect(s.draft.qtlMilli, 8640);
      expect(s.draft.rate, const Money.rupees(2425));
      expect(find.text('Lot L-W1-0007 posted to the khata'), findsOneWidget);
      expect(find.byType(LotDetailScreen), findsOneWidget);
    });

    testWidgets('weight from bags × bag weight', (tester) async {
      await pump(tester, '/arrivals/new');
      await pickFarmer(tester);
      await pickWheat(tester);
      await tester.enterText(field('Bags'), '18');
      await tester.tap(find.byKey(const ValueKey('lot-qtl-from-bags')));
      await tester.pumpAndSettle();
      // 18 bags × 50 kg (default) = 9 qtl.
      expect(find.text('9.00'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('lot-save')));
      await tester.pumpAndSettle();
      expect(lots.saved.single.draft.qtlMilli, 9000);
      expect(lots.saved.single.draft.qtlFromBags, isTrue);
    });

    testWidgets('buyer-borne charges ask for a buyer before posting', (
      tester,
    ) async {
      settings.rows.add(
        const SettingRow(
          scope: SettingScope.tenant,
          key: 'mandi.charges_borne_by',
          value: {'mandi_fee': 'buyer'},
        ),
      );
      await pump(tester, '/arrivals/new');
      await pickFarmer(tester);
      await pickWheat(tester);
      await tester.enterText(field('Qtl'), '8.64');
      await tester.enterText(field('Rate'), '2425');
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('preview-problem-buyerRequired')),
        findsOneWidget,
      );
    });

    testWidgets('missing farmer and crop are flagged, nothing saved', (
      tester,
    ) async {
      await pump(tester, '/arrivals/new');
      await tester.tap(find.byKey(const ValueKey('lot-save')));
      await tester.pumpAndSettle();
      expect(find.text('Pick the farmer'), findsOneWidget);
      expect(find.text('Pick the crop'), findsOneWidget);
      expect(lots.saved, isEmpty);
    });

    testWidgets('an incomplete lot saves without posting; hold keeps it open', (
      tester,
    ) async {
      await pump(tester, '/arrivals/new');
      await pickFarmer(tester);
      await pickWheat(tester);
      expect(find.byKey(const ValueKey('lot-hold')), findsNothing);
      await tester.enterText(field('Qtl'), '8.64');
      await tester.enterText(field('Rate'), '2425');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('lot-hold')));
      await tester.pumpAndSettle();
      expect(lots.saved.single.post, isFalse);
    });
  });

  group('gate wizard (phone)', () {
    testWidgets('farmer → crop and bags → confirm saves an arrival', (
      tester,
    ) async {
      await pump(tester, '/arrivals/new', size: const Size(400, 900));
      expect(find.byType(ArrivalWizard), findsOneWidget);
      final next = find.byKey(const ValueKey('wizard-next'));
      expect(tester.widget<MkButton>(next).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'gur');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gurmeet Singh'));
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('wizard-crop-wheat')));
      await tester.enterText(field('Bags'), '12');
      await tester.pumpAndSettle();
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.text('Lot L-W1-0007'), findsOneWidget);
      expect(find.text('Weight and rate are added at the counter.'), findsOne);

      await tester.tap(next);
      await tester.pumpAndSettle();
      final s = lots.saved.single;
      expect(s.draft.bags, 12);
      expect(s.draft.qtlMilli, isNull);
      expect(s.draft.rate, isNull);
      expect(find.text('Lot L-W1-0007 saved'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('wizard-farmer-1')),
        findsOneWidget,
        reason: 'back to step 1 for the next tractor',
      );
    });
  });

  group('list', () {
    testWidgets('shows lots, status and totals of live lots', (tester) async {
      lots.lots.addAll([
        postedLot(),
        arrivedLot(),
        postedLot(id: 'lot-3', status: LotStatus.reversed),
      ]);
      await pump(tester, '/arrivals');
      expect(find.text('Posted'), findsWidgets);
      expect(find.text('Arrived'), findsWidgets);
      final totals = find.byKey(const ValueKey('lots-totals'));
      expect(
        find.descendant(of: totals, matching: find.text('2')),
        findsOneWidget,
        reason: 'the reversed lot is not counted',
      );
      expect(
        find.descendant(of: totals, matching: find.text('₹19,832.76')),
        findsOneWidget,
      );
    });

    testWidgets('empty with a New arrival button', (tester) async {
      await pump(tester, '/arrivals');
      expect(find.text('No lots for these filters'), findsOneWidget);
      await tester.tap(find.widgetWithText(MkButton, 'New arrival'));
      await tester.pumpAndSettle();
      expect(find.byType(LotFormScreen), findsOneWidget);
    });
  });

  group('detail', () {
    testWidgets('posted lot: calculation from snapshot; owner reverses', (
      tester,
    ) async {
      lots.lots.add(postedLot());
      await pump(tester, '/arrivals/lot-1');
      expect(find.text('₹19,832.76'), findsWidgets);
      expect(find.byKey(const ValueKey('lot-edit')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('lot-reverse')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('lot-confirm')));
      await tester.pumpAndSettle();
      expect(lots.reversed, ['lot-1']);
      expect(find.text('Lot L-W1-0001 reversed'), findsOneWidget);
    });

    testWidgets('a munshi cannot reverse', (tester) async {
      lots.lots.add(postedLot());
      await pump(tester, '/arrivals/lot-1', role: MemberRole.munshi);
      expect(find.byKey(const ValueKey('lot-reverse')), findsNothing);
    });

    testWidgets('open lot: munshi adds weight & rate or cancels', (
      tester,
    ) async {
      lots.lots.add(arrivedLot());
      await pump(tester, '/arrivals/lot-2', role: MemberRole.munshi);
      expect(find.text('Add weight & rate'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('lot-cancel')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('lot-confirm')));
      await tester.pumpAndSettle();
      expect(lots.cancelled, ['lot-2']);
    });

    testWidgets('editing an arrival loads it into the form', (tester) async {
      lots.lots.add(arrivedLot());
      await pump(tester, '/arrivals/lot-2/edit');
      expect(find.text('Gurmeet Singh'), findsOneWidget);
      await tester.enterText(field('Qtl'), '6');
      await tester.enterText(field('Rate'), '2400');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.f10);
      await tester.pumpAndSettle();
      final s = lots.saved.single;
      expect(s.id, 'lot-2');
      expect(s.draft.bags, 12);
      expect(s.draft.qtlMilli, 6000);
    });
  });
}
