import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mk_admin/src/api.dart';
import 'package:mk_admin/src/businesses_screen.dart';
import 'package:mk_admin/src/form_fields.dart';
import 'package:mk_admin/src/resources.dart';
import 'package:mk_admin/src/tenant_detail.dart';
import 'package:mk_ui/mk_ui.dart';

class FakeApi implements AdminApi {
  FakeApi(this.responses);

  final Map<String, Object?> responses;
  final List<({String action, Map<String, Object?> params})> calls = [];

  @override
  Future<Object?> call(
    String action, [
    Map<String, Object?> params = const {},
  ]) async {
    calls.add((action: action, params: params));
    return responses[action];
  }

  Map<String, Object?> last(String action) =>
      calls.lastWhere((c) => c.action == action).params;
}

Widget app(FakeApi api, Widget home) => ProviderScope(
  overrides: [adminApiProvider.overrideWithValue(api)],
  child: MaterialApp(
    theme: MkTheme.light(),
    home: Scaffold(body: home),
  ),
);

const Map<String, Object?> plans = {
  'plans': [
    {
      'code': 'mandi_pro',
      'name': 'Mandi Pro',
      'price_monthly_paise': 99900,
      'price_yearly_paise': 999000,
      'max_users': 5,
      'max_devices': 5,
      'modules': {'khata': true, 'karza': true},
      'limits': <String, Object?>{},
      'default_settings': <String, Object?>{},
      'is_public': true,
      'is_active': true,
      'sort_order': 20,
    },
    {
      'code': 'combo',
      'name': 'Combo',
      'modules': <String, Object?>{},
      'limits': <String, Object?>{},
    },
  ],
  'addons': [
    {'code': 'extra_user', 'name': 'Extra user'},
  ],
};

Map<String, Object?> sub({String status = 'trial'}) => {
  'plan_code': 'mandi_pro',
  'status': status,
  'billing_cycle': 'monthly',
  'trial_ends_at': '2026-01-01T00:00:00+00:00',
  'current_period_end': null,
  'grace_days': 7,
  'grace_until': null,
  'discount_pct': 0,
  'discount_note': null,
  'addons': <Object?>[],
  'overrides': <String, Object?>{},
};

void main() {
  group('FormValues', () {
    test('rupees become paise, modules a map, JSON is parsed', () {
      final v = FormValues(plansResource.fields, null);
      v.text['code']!.text = 'x';
      v.text['name']!.text = 'X';
      v.text['price_monthly_paise']!.text = '999.50';
      v.text['limits']!.text = '{"parties": 100}';
      v.modules['modules']!['shop'] = true;
      final r = v.read();
      expect(r.error, isNull);
      expect(r.values!['price_monthly_paise'], 99950);
      expect(r.values!['limits'], {'parties': 100});
      expect((r.values!['modules']! as Map)['shop'], true);
      expect((r.values!['modules']! as Map)['karza'], false);
      expect(r.values!['max_users'], isNull);
      v.dispose();
    });

    test('says which field is wrong', () {
      final v = FormValues(plansResource.fields, null);
      expect(v.read().error, contains('Code'));
      v.text['code']!.text = 'x';
      v.text['name']!.text = 'X';
      v.text['limits']!.text = '{oops';
      expect(v.read().error, contains('JSON'));
      v.text['limits']!.text = '';
      v.text['max_users']!.text = 'five';
      expect(v.read().error, contains('whole number'));
      v.dispose();
    });

    test('editing an existing row shows paise as rupees', () {
      final v = FormValues(plansResource.fields, {
        'code': 'a',
        'name': 'A',
        'price_monthly_paise': 99900,
        'modules': {'shop': true},
      });
      expect(v.text['price_monthly_paise']!.text, '999.0');
      expect(v.modules['modules']!['shop'], isTrue);
      v.dispose();
    });
  });

  testWidgets('a resource lists its rows and saves a new one', (tester) async {
    final api = FakeApi({'plans_list': plans, 'plan_upsert': {}});
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(api, ResourceScreen(config: plansResource)));
    await tester.pumpAndSettle();
    expect(find.text('Mandi Pro'), findsOneWidget);
    expect(find.text('₹999'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('new-plan_upsert')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('field-code')), 'shop2');
    await tester.enterText(find.byKey(const ValueKey('field-name')), 'Shop 2');
    await tester.enterText(
      find.byKey(const ValueKey('field-price_monthly_paise')),
      '499',
    );
    await tester.tap(find.byKey(const ValueKey('save-resource')));
    await tester.pumpAndSettle();

    final sent = api.last('plan_upsert');
    expect(sent['code'], 'shop2');
    expect(sent['price_monthly_paise'], 49900);
    expect(sent['is_active'], true);
  });

  testWidgets('a field error stops the save', (tester) async {
    final api = FakeApi({'plans_list': plans, 'plan_upsert': {}});
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(api, ResourceScreen(config: plansResource)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('new-plan_upsert')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-resource')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Code is needed'), findsOneWidget);
    expect(api.calls.where((c) => c.action == 'plan_upsert'), isEmpty);
  });

  testWidgets('businesses: filter by status, total MRR', (tester) async {
    final api = FakeApi({
      'overview': [
        {
          'tenant_id': 't1',
          'name': 'Sandhu Traders',
          'status': 'active',
          'access': 'full',
          'plan_code': 'mandi_pro',
          'users': 2,
          'devices': 1,
          'parties': 40,
          'ledger_entries': 500,
          'mrr_paise': 99900,
        },
        {
          'tenant_id': 't2',
          'name': 'Gupta Seeds',
          'status': 'trial',
          'access': 'full',
          'plan_code': 'trial',
          'users': 1,
          'devices': 1,
          'parties': 3,
          'ledger_entries': 9,
          'mrr_paise': 0,
        },
      ],
    });
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(api, const BusinessesScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Sandhu Traders'), findsOneWidget);
    expect(find.text('Gupta Seeds'), findsOneWidget);
    expect(find.text('MRR ₹999'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('business-search')),
      'gupta',
    );
    await tester.pumpAndSettle();
    expect(find.text('Sandhu Traders'), findsNothing);
    expect(find.text('Gupta Seeds'), findsOneWidget);
  });

  group('tenant detail', () {
    Future<FakeApi> open(WidgetTester tester) async {
      final api = FakeApi({
        'tenant_detail': {
          'tenant': {'name': 'Sandhu Traders', 'state_code': '03'},
          'subscription': sub(),
          'entitlements': {
            'modules': {'khata': true},
            'limits': {'users': 5},
          },
          'requests': <Object?>[],
          'admin_log': <Object?>[],
          'settings': [
            {'key': 'interest.method', 'value': 'simple'},
          ],
        },
        'plans_list': plans,
        'update_subscription': {},
        'set_tenant_setting': {'ok': true},
      });
      tester.view.physicalSize = const Size(1400, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        app(api, const TenantDetailScreen(tenantId: 't1', name: 'Sandhu')),
      );
      await tester.pumpAndSettle();
      return api;
    }

    testWidgets('only changed subscription fields are sent', (tester) async {
      final api = await open(tester);
      await tester.enterText(find.byKey(const ValueKey('sub-discount')), '10');
      await tester.enterText(
        find.byKey(const ValueKey('sub-note')),
        'friend of the family',
      );
      await tester.tap(find.byKey(const ValueKey('sub-save')));
      await tester.pumpAndSettle();
      final sent = api.last('update_subscription');
      expect(sent['tenant_id'], 't1');
      expect(sent['changes'], {'discount_pct': 10});
      expect(sent['note'], 'friend of the family');
    });

    testWidgets('extend trial moves the end date by seven days', (
      tester,
    ) async {
      final api = await open(tester);
      await tester.tap(find.text('Extend trial 7 days'));
      await tester.pumpAndSettle();
      final changes =
          api.last('update_subscription')['changes']! as Map<String, Object?>;
      expect(changes['status'], 'trial');
      // The trial of the fixture ended in the past, so seven days from now.
      final end = DateTime.parse(changes['trial_ends_at']! as String);
      final days = end.difference(DateTime.now().toUtc()).inDays;
      expect(days, inInclusiveRange(6, 7));
    });

    testWidgets('add-ons and overrides are saved together', (tester) async {
      final api = await open(tester);
      await tester.enterText(
        find.byKey(const ValueKey('addon-extra_user')),
        '3',
      );
      await tester.enterText(find.byKey(const ValueKey('limit-users')), '12');
      await tester.enterText(
        find.byKey(const ValueKey('limit-parties')),
        'unlimited',
      );
      await tester.tap(find.byKey(const ValueKey('entitlements-save')));
      await tester.pumpAndSettle();
      final changes =
          api.last('update_subscription')['changes']! as Map<String, Object?>;
      expect(changes['addons'], [
        {'code': 'extra_user', 'qty': 3},
      ]);
      expect(changes['overrides'], {
        'limits': {'users': 12, 'parties': null},
      });
    });

    testWidgets("a default is set on the customer's behalf", (tester) async {
      final api = await open(tester);
      await tester.enterText(
        find.byKey(const ValueKey('default-key')),
        'interest.method',
      );
      await tester.enterText(
        find.byKey(const ValueKey('default-value')),
        '"compound"',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('default-save')));
      await tester.pumpAndSettle();
      final sent = api.last('set_tenant_setting');
      expect(sent['key'], 'interest.method');
      expect(sent['value'], 'compound');
    });

    testWidgets('support view asks for a reason first', (tester) async {
      final api = await open(tester);
      api.responses['support_start'] = {
        'session_id': 's1',
        'snapshot': {
          'access': 'full',
          'counts': {
            'members': 1,
            'devices': 1,
            'parties': 2,
            'ledger_entries': 3,
          },
          'members': <Object?>[],
          'recent_entries': <Object?>[],
          'recent_audit': <Object?>[],
        },
      };
      api.responses['support_end'] = {'ok': true};
      await tester.tap(find.byKey(const ValueKey('support-start')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('support-reason')),
        'fix a report',
      );
      await tester.tap(find.byKey(const ValueKey('support-confirm')));
      await tester.pumpAndSettle();
      expect(api.last('support_start')['reason'], 'fix a report');
      expect(find.textContaining('read-only'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(api.last('support_end')['session_id'], 's1');
    });
  });
}
