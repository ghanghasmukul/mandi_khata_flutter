import 'package:khata_core/khata_core.dart';
import 'package:test/test.dart';

void main() {
  const pro = PlanSpec(
    code: 'mandi_pro',
    modules: {
      'khata': true,
      'arrivals': true,
      'karza': true,
      'accounting': true,
    },
    maxUsers: 5,
    maxDevices: 5,
    limits: {'parties': null},
  );
  const basic = PlanSpec(
    code: 'mandi_basic',
    modules: {'khata': true, 'arrivals': true},
    maxUsers: 2,
    maxDevices: 2,
    limits: {'parties': 2000},
  );
  const extraUser = AddonSpec(code: 'extra_user', grantsLimits: {'users': 1});
  const extraDevice = AddonSpec(
    code: 'extra_device',
    grantsLimits: {'devices': 1},
    maxQuantity: 3,
  );
  const karzaPack = AddonSpec(code: 'karza', grantsModules: {'karza': true});

  group('plan only', () {
    test('modules missing from the plan are off', () {
      final e = Entitlements.resolve(basic);
      expect(e.module('khata'), isTrue);
      expect(e.module('shop'), isFalse);
      expect(e.module('unknown'), isFalse);
    });

    test('users and devices come from the shortcut columns', () {
      final e = Entitlements.resolve(basic);
      expect(e.limit('users'), 2);
      expect(e.limit('devices'), 2);
      expect(e.limit('parties'), 2000);
    });

    test('null / missing limit is unlimited', () {
      final e = Entitlements.resolve(pro);
      expect(e.limit('parties'), isNull);
      expect(e.limit('anything'), isNull);
      expect(e.canAdd('parties', 1000000), isTrue);
    });

    test('a null max_users is unlimited', () {
      final e = Entitlements.resolve(const PlanSpec(code: 'x'));
      expect(e.limit('users'), isNull);
      expect(e.canAdd('users', 99), isTrue);
    });
  });

  group('add-ons', () {
    test('a unit adds to the limit', () {
      final e = Entitlements.resolve(
        basic,
        addons: const [AddonPurchase(extraUser, 3)],
      );
      expect(e.limit('users'), 5);
      expect(e.limit('devices'), 2);
    });

    test('quantity is capped by the add-on maximum', () {
      final e = Entitlements.resolve(
        basic,
        addons: const [AddonPurchase(extraDevice, 10)],
      );
      expect(e.limit('devices'), 5);
    });

    test('unlimited stays unlimited and zero quantity changes nothing', () {
      final e = Entitlements.resolve(
        pro,
        addons: const [
          AddonPurchase(extraUser, 2),
          AddonPurchase(extraDevice, 0),
        ],
      );
      expect(e.limit('parties'), isNull);
      expect(e.limit('users'), 7);
      expect(e.limit('devices'), 5);
    });

    test('a module add-on switches a module on', () {
      final e = Entitlements.resolve(
        basic,
        addons: const [AddonPurchase(karzaPack, 1)],
      );
      expect(e.module('karza'), isTrue);
    });

    test('an add-on never creates a limit the plan did not have', () {
      const odd = AddonSpec(code: 'odd', grantsLimits: {'godowns': 2});
      final e = Entitlements.resolve(
        basic,
        addons: const [AddonPurchase(odd, 1)],
      );
      expect(e.limit('godowns'), isNull);
    });
  });

  group('overrides', () {
    test('win over plan and add-ons, both ways', () {
      final e = Entitlements.resolve(
        pro,
        addons: const [
          AddonPurchase(karzaPack, 1),
          AddonPurchase(extraUser, 1),
        ],
        overrides: const EntitlementOverrides(
          modules: {'karza': false, 'shop': true},
          limits: {'users': 10, 'devices': null},
        ),
      );
      expect(e.module('karza'), isFalse);
      expect(e.module('shop'), isTrue);
      expect(e.limit('users'), 10);
      expect(e.limit('devices'), isNull);
    });

    test('fromJson ignores values of the wrong type', () {
      final o = EntitlementOverrides.fromJson(const {
        'modules': {'shop': true, 'karza': 'yes', 3: true},
        'limits': {'users': 4, 'devices': 'many', 'parties': -1, 'x': null},
      });
      expect(o.modules, {'shop': true});
      expect(o.limits, {'users': 4, 'x': null});
      expect(EntitlementOverrides.fromJson('nope').modules, isEmpty);
      expect(EntitlementOverrides.fromJson(null).limits, isEmpty);
    });
  });

  group('limits', () {
    test('canAdd and state at the edges', () {
      final e = Entitlements.resolve(basic);
      expect(e.canAdd('users', 1), isTrue);
      expect(e.canAdd('users', 2), isFalse);
      expect(e.state('users', 1), LimitState.ok);
      expect(e.state('users', 2), LimitState.atLimit);
      expect(e.state('users', 3), LimitState.over);
      expect(e.state('parties', 2001), LimitState.over);
      expect(Entitlements.resolve(pro).state('parties', 5000), LimitState.ok);
    });
  });

  group('business switch', () {
    test('can turn a module off, never on', () {
      final e = Entitlements.resolve(basic);
      expect(e.moduleOn('khata', switchOn: true), isTrue);
      expect(e.moduleOn('khata', switchOn: false), isFalse);
      expect(e.moduleOn('shop', switchOn: true), isFalse);
    });
  });

  test('json round trip and unrestricted', () {
    final e = Entitlements.resolve(basic);
    final back = Entitlements.fromJson(e.toJson());
    expect(back.module('arrivals'), isTrue);
    expect(back.limit('parties'), 2000);
    expect(Entitlements.none.module('khata'), isFalse);
    expect(Entitlements.unrestricted.module('shop'), isTrue);
    expect(Entitlements.fromJson(5).modules, isEmpty);
  });

  test('validPlanDefaults drops invalid and null values', () {
    final out = validPlanDefaults({
      'a': 1,
      'b': 2,
      'c': null,
    }, (k, v) => k == 'a');
    expect(out, {'a': 1});
  });
}
