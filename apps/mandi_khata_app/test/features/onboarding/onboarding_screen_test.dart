import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/settings/settings_providers.dart';
import 'package:mandi_khata_app/core/settings/settings_repository.dart';
import 'package:mandi_khata_app/core/sync/sync_providers.dart';
import 'package:mandi_khata_app/core/tenant/active_tenant.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';
import 'package:mandi_khata_app/features/crops/domain/crop.dart';
import 'package:mandi_khata_app/features/crops/presentation/crops_providers.dart';
import 'package:mandi_khata_app/features/onboarding/data/onboarding_repository.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_providers.dart';
import 'package:mandi_khata_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:mandi_khata_app/l10n/generated/app_localizations.dart';
import 'package:mk_ui/mk_ui.dart';

class _Actions implements OnboardingActions {
  final calls = <String>[];
  final settings = <String, Object>{};
  Set<String>? crops;
  Map<String, Object?>? business;

  @override
  Future<OnboardingSaveFailure?> saveBusiness(
    Map<String, Object?> columns,
  ) async {
    business = columns;
    calls.add('business');
    return null;
  }

  @override
  Future<OnboardingSaveFailure?> saveCrops(Set<String> ids) async {
    crops = ids;
    calls.add('crops');
    return null;
  }

  @override
  Future<SettingWriteFailure?> saveSettings(Map<String, Object> v) async {
    settings.addAll(v);
    calls.add('settings');
    return null;
  }

  @override
  Future<SettingWriteFailure?> saveLanguage(String code) async {
    calls.add('language:$code');
    return null;
  }

  @override
  Future<void> markProgress(int finished) async => calls.add('step:$finished');

  @override
  Future<SettingWriteFailure?> complete() async {
    calls.add('complete');
    return null;
  }

  @override
  Future<SettingWriteFailure?> skip() async {
    calls.add('skip');
    return null;
  }
}

class _Tenant extends ActiveTenant {
  @override
  String? build() => 't1';
}

const _wheat = Crop(
  id: 'c1',
  code: 'wheat',
  nameEn: 'Wheat',
  unit: 'qtl',
  sortOrder: 1,
  isActive: true,
);
const _guar = Crop(
  id: 'c2',
  code: 'guar',
  nameEn: 'Guar',
  unit: 'qtl',
  sortOrder: 2,
  isActive: false,
);

void main() {
  late _Actions actions;

  Future<void> pump(
    WidgetTester tester, {
    List<Crop> crops = const [_wheat, _guar],
    int finished = 0,
    String status = 'not_started',
    MemberRole role = MemberRole.owner,
  }) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const OnboardingScreen()),
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
          onboardingActionsProvider.overrideWithValue(actions),
          onboardingFinishedProvider.overrideWithValue(finished),
          onboardingStatusProvider.overrideWithValue(status),
          tenantRowProvider.overrideWith(
            (ref) => Stream.value({
              'name': 'Gupta Traders',
              'state_code': '03',
              'mandi_name': 'Khanna',
            }),
          ),
          settingsResolverProvider(
            businessTarget,
          ).overrideWithValue(SettingsResolver(const [])),
          cropListProvider(
            includeInactive: true,
          ).overrideWith((ref) => Stream.value(crops)),
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

  setUp(() => actions = _Actions());

  Future<void> next(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const ValueKey('step-next')));
    await tester.tap(find.byKey(const ValueKey('step-next')));
    await tester.pumpAndSettle();
  }

  testWidgets('step 1 checks the details, saves, and moves on', (t) async {
    await pump(t);
    expect(find.text('Step 1 of 7'), findsOneWidget);
    // Prefilled from the business row.
    expect(find.text('Gupta Traders'), findsOneWidget);

    await t.enterText(find.byKey(const ValueKey('biz-gstin')), '27BAD');
    await next(t);
    expect(find.text('This GSTIN is not valid.'), findsOneWidget);
    expect(actions.calls, isEmpty);

    await t.enterText(
      find.byKey(const ValueKey('biz-gstin')),
      '27aapfu0939f1zv',
    );
    await t.enterText(
      find.byKey(const ValueKey('biz-phone')),
      '+91 98140-22110',
    );
    await next(t);
    expect(actions.business, containsPair('gstin', '27AAPFU0939F1ZV'));
    expect(actions.business, containsPair('phone', '9814022110'));
    expect(actions.calls, ['business', 'step:1']);
    expect(find.text('Step 2 of 7'), findsOneWidget);
  });

  testWidgets('resumes at the stored step and goes back', (t) async {
    await pump(t, finished: 2, status: 'in_progress');
    expect(find.text('Step 3 of 7'), findsOneWidget);
    // Crops: the active ones start ticked.
    final wheat = t.widget<CheckboxListTile>(
      find.byKey(const ValueKey('crop-wheat')),
    );
    final guar = t.widget<CheckboxListTile>(
      find.byKey(const ValueKey('crop-guar')),
    );
    expect(wheat.value, isTrue);
    expect(guar.value, isFalse);

    await t.tap(find.byKey(const ValueKey('step-back')));
    await t.pumpAndSettle();
    expect(find.text('Step 2 of 7'), findsOneWidget);
  });

  testWidgets('crops: at least one, saved as ids', (t) async {
    await pump(t, finished: 2, status: 'in_progress');
    await t.tap(find.byKey(const ValueKey('crops-none')));
    await t.pump();
    await next(t);
    expect(find.text('Choose at least one crop.'), findsOneWidget);
    expect(actions.crops, isNull);

    await t.tap(find.byKey(const ValueKey('crop-guar')));
    await t.pump();
    await next(t);
    expect(actions.crops, {'c2'});
    expect(find.text('Step 4 of 7'), findsOneWidget);
  });

  testWidgets('no crops synced yet: the wizard does not trap the owner', (
    t,
  ) async {
    await pump(t, crops: const [], finished: 2, status: 'in_progress');
    expect(find.byKey(const ValueKey('crops-empty')), findsOneWidget);
    await next(t);
    expect(actions.crops, isNull);
    expect(find.text('Step 4 of 7'), findsOneWidget);
  });

  testWidgets('charges are stored as exact paise and decimal strings', (
    t,
  ) async {
    await pump(t, finished: 3, status: 'in_progress');
    // System defaults are prefilled.
    expect(find.text('2.5'), findsOneWidget);
    await t.enterText(
      find.byKey(const ValueKey('charge-mandi.palledari_per_bag')),
      '12.55',
    );
    await t.enterText(
      find.byKey(const ValueKey('charge-mandi.commission_pct')),
      '3',
    );
    await next(t);
    expect(actions.settings['mandi.palledari_per_bag'], 1255);
    expect(actions.settings['mandi.commission_pct'], '3');
    expect(actions.settings['mandi.bardana_per_bag'], 800);
    expect(find.text('Step 5 of 7'), findsOneWidget);
  });

  testWidgets('a bad charge is flagged and nothing is saved', (t) async {
    await pump(t, finished: 3, status: 'in_progress');
    await t.enterText(
      find.byKey(const ValueKey('charge-mandi.tulai_per_qtl')),
      '2.555',
    );
    await next(t);
    expect(find.text('Enter a valid number.'), findsOneWidget);
    expect(actions.settings, isEmpty);
  });

  testWidgets('interest: per-100-per-month converts, stored as % a year', (
    t,
  ) async {
    await pump(t, finished: 4, status: 'in_progress');
    expect(
      find.text(
        'Saved only for now. Interest is calculated in a later update.',
      ),
      findsOneWidget,
    );
    expect(find.text('Interest rate (% per year)'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('interest-unit-month')));
    await t.pump();
    // 18% a year reads as 1.5 per 100 per month, and the label says so.
    expect(find.text('1.5'), findsOneWidget);
    expect(find.text('Interest rate (₹ per 100 per month)'), findsOneWidget);
    expect(find.text('Interest rate (% per year)'), findsNothing);
    await t.tap(find.byKey(const ValueKey('interest-unit-pa')));
    await t.pump();
    expect(find.text('Interest rate (% per year)'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('interest-unit-month')));
    await t.pump();
    await next(t);
    expect(actions.settings['interest.rate_pa'], '18');
    expect(actions.settings['interest.rate_unit_display'], 'per100_per_month');
    expect(find.text('Step 6 of 7'), findsOneWidget);
  });

  testWidgets('last step finishes and offers the import', (t) async {
    await pump(t, finished: 6, status: 'in_progress');
    expect(find.text('Step 7 of 7'), findsOneWidget);
    await next(t);
    expect(actions.calls, ['complete']);
    expect(find.byKey(const ValueKey('done-import')), findsOneWidget);
  });

  testWidgets('skip leaves the wizard', (t) async {
    await pump(t);
    await t.ensureVisible(find.byKey(const ValueKey('onboarding-skip')));
    await t.tap(find.byKey(const ValueKey('onboarding-skip')));
    await t.pumpAndSettle();
    expect(actions.calls, ['skip']);
  });

  testWidgets('only the owner can run it', (t) async {
    await pump(t, role: MemberRole.munshi);
    expect(
      find.text('Only the business owner can run the setup.'),
      findsOneWidget,
    );
  });

  testWidgets('a finished wizard re-run starts at step 1', (t) async {
    await pump(t, finished: 7, status: 'completed');
    expect(find.text('Step 1 of 7'), findsOneWidget);
  });
}
