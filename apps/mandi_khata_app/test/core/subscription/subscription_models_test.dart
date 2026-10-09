import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/subscription/subscription_models.dart';

Map<String, Object?> planRow({
  String code = 'mandi_basic',
  Object? modules = '{"khata":true,"arrivals":true}',
  Object? limits = '{"parties":2000}',
  int? maxUsers = 2,
  int? maxDevices = 2,
  Object? defaults = '{}',
}) => {
  'code': code,
  'name': 'Mandi Basic',
  'price_monthly_paise': 99900,
  'price_yearly_paise': 999000,
  'max_users': maxUsers,
  'max_devices': maxDevices,
  'modules': modules,
  'limits': limits,
  'default_settings': defaults,
  'is_public': 1,
  'is_active': 1,
  'sort_order': 10,
};

Map<String, Object?> subRow({
  String status = 'active',
  Object? addons = '[]',
  Object? overrides = '{}',
}) => {
  'plan_code': 'mandi_basic',
  'billing_cycle': 'yearly',
  'status': status,
  'trial_ends_at': null,
  'current_period_end': '2027-06-01T00:00:00.000Z',
  'grace_days': 7,
  'grace_until': null,
  'cancelled_at': null,
  'cancelled_readonly_days': 90,
  'addons': addons,
  'overrides': overrides,
  'discount_pct': 10,
  'discount_note': 'friend',
};

void main() {
  test('a plan row becomes a PlanSpec', () {
    final p = PlanInfo.fromRow(planRow());
    expect(p.code, 'mandi_basic');
    expect(p.spec.modules, {'khata': true, 'arrivals': true});
    expect(p.spec.limits, {'parties': 2000});
    expect(p.priceMonthly, const Money(99900));
    expect(p.isPublic, isTrue);
  });

  test('unreadable JSON in a plan grants nothing and never throws', () {
    final p = PlanInfo.fromRow(planRow(modules: 'not json', limits: '[1]'));
    expect(p.spec.modules, isEmpty);
    expect(p.spec.limits, isEmpty);
  });

  test('a subscription row keeps terms, add-ons and overrides', () {
    final s = SubscriptionInfo.fromRow(
      subRow(
        addons: jsonEncode([
          {'code': 'extra_user', 'qty': 2},
          {'code': 'bad'},
        ]),
        overrides: '{"modules":{"shop":true},"limits":{"users":9}}',
      ),
    );
    expect(s.terms.status, SubscriptionStatus.active);
    expect(s.terms.currentPeriodEnd, DateTime.utc(2027, 6));
    expect(s.addons, [(code: 'extra_user', qty: 2)]);
    expect(s.overrides.modules, {'shop': true});
    expect(s.overrides.limits, {'users': 9});
    expect(s.billingCycle, 'yearly');
    expect(s.discountPct, 10);
  });

  test('the bundle resolves plan + add-ons + overrides', () {
    final bundle = SubscriptionBundle(
      subscription: SubscriptionInfo.fromRow(
        subRow(
          addons: '[{"code":"extra_user","qty":3}]',
          overrides: '{"modules":{"shop":true}}',
        ),
      ),
      plans: [PlanInfo.fromRow(planRow())],
      addonCatalog: [
        AddonInfo.fromRow(const {
          'code': 'extra_user',
          'name': 'Extra user',
          'grants_limits': '{"users":1}',
          'grants_modules': '{}',
        }),
      ],
    );
    final e = bundle.entitlements;
    expect(e.limit('users'), 5);
    expect(e.module('shop'), isTrue);
    expect(e.module('karza'), isFalse);
  });

  test('a missing plan grants nothing', () {
    final bundle = SubscriptionBundle(
      subscription: SubscriptionInfo.fromRow(subRow()),
      plans: const [],
      addonCatalog: const [],
    );
    expect(bundle.entitlements.module('khata'), isFalse);
  });

  test('plan defaults keep only valid settings', () {
    final bundle = SubscriptionBundle(
      subscription: SubscriptionInfo.fromRow(subRow()),
      plans: [
        PlanInfo.fromRow(
          planRow(
            defaults:
                '{"mandi.commission_pct":"2",'
                '"interest.rate_pa":"nope","made.up":1}',
          ),
        ),
      ],
      addonCatalog: const [],
    );
    expect(bundle.planDefaults, {'mandi.commission_pct': '2'});
  });
}
