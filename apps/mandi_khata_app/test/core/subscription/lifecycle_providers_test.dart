import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/subscription/entitlement_token.dart';
import 'package:mandi_khata_app/core/subscription/subscription_models.dart';
import 'package:mandi_khata_app/core/subscription/subscription_providers.dart';
import 'package:mandi_khata_app/core/tenant/membership_repository.dart';

class _FakeToken extends EntitlementTokenStore {
  _FakeToken(this.claims);
  final EntitlementClaims? claims;

  @override
  EntitlementClaims? build() => claims;
}

PlanInfo plan({String code = 'mandi_pro'}) => PlanInfo.fromRow({
  'code': code,
  'name': 'Mandi Pro',
  'max_users': 5,
  'max_devices': 5,
  'modules': '{"khata":true,"arrivals":true,"karza":true,"accounting":true}',
  'limits': '{}',
  'default_settings': '{"mandi.commission_pct":"2"}',
  'is_public': 1,
  'is_active': 1,
});

SubscriptionBundle bundle({
  String status = 'active',
  String periodEnd = '2027-06-01T00:00:00.000Z',
  String updatedAt = '2027-05-01T00:00:00.000Z',
  bool withPlan = true,
}) => SubscriptionBundle(
  subscription: SubscriptionInfo.fromRow({
    'plan_code': 'mandi_pro',
    'status': status,
    'current_period_end': periodEnd,
    'grace_days': 7,
    'updated_at': updatedAt,
  }),
  plans: withPlan ? [plan()] : const [],
  addonCatalog: const [],
);

EntitlementClaims claims({
  required SubscriptionStatus status,
  DateTime? issuedAt,
  DateTime? periodEnd,
  Entitlements? entitlements,
}) => EntitlementClaims(
  tenantId: 't1',
  planCode: 'mandi_pro',
  terms: SubscriptionTerms(status: status, currentPeriodEnd: periodEnd),
  entitlements: entitlements ?? Entitlements.unrestricted,
  issuedAt: issuedAt ?? DateTime.utc(2027, 5, 20),
  validUntil: null,
);

ProviderContainer make({
  SubscriptionBundle? bundleValue,
  DateTime? now,
  DateTime? lastSynced,
  EntitlementClaims? token,
}) {
  final c =
      ProviderContainer(
          overrides: [
            subscriptionBundleProvider.overrideWith(
              (ref) => Stream.value(bundleValue),
            ),
            clockNowProvider.overrideWithValue(
              now ?? DateTime.utc(2027, 5, 15),
            ),
            lastSyncedAtProvider.overrideWithValue(lastSynced),
            offlineToleranceDaysProvider.overrideWith((ref) => Stream.value(7)),
            entitlementTokenStoreProvider.overrideWith(() => _FakeToken(token)),
          ],
        )
        // Auto-dispose providers: keep the inputs alive between reads.
        ..listen(subscriptionBundleProvider, (_, _) {})
        ..listen(offlineToleranceDaysProvider, (_, _) {});
  addTearDown(c.dispose);
  return c;
}

Future<void> settle(ProviderContainer c) async {
  await c.read(subscriptionBundleProvider.future);
  await c.read(offlineToleranceDaysProvider.future);
}

void main() {
  test('no subscription yet: the app stays open and unrestricted', () async {
    final c = make();
    await settle(c);
    expect(c.read(lifecycleProvider).access, AccessLevel.full);
    expect(c.read(subscriptionReadOnlyProvider), isFalse);
    expect(c.read(entitlementsProvider).module('shop'), isTrue);
    expect(c.read(planSettingDefaultsProvider), isEmpty);
    expect(c.read(planSummaryProvider), isNull);
  });

  test(
    'an active plan in its period: full access, plan modules only',
    () async {
      final c = make(bundleValue: bundle());
      await settle(c);
      expect(c.read(lifecycleProvider).effective, SubscriptionStatus.active);
      expect(c.read(subscriptionReadOnlyProvider), isFalse);
      final e = c.read(entitlementsProvider);
      expect(e.module('karza'), isTrue);
      expect(e.module('shop'), isFalse);
      expect(e.limit('users'), 5);
      expect(c.read(planSettingDefaultsProvider), {
        'mandi.commission_pct': '2',
      });
      expect(c.read(planSummaryProvider)!.name, 'Mandi Pro');
    },
  );

  test('overdue within grace: still writable, with a banner', () async {
    final c = make(
      bundleValue: bundle(),
      now: DateTime.utc(2027, 6, 3),
      lastSynced: DateTime.utc(2027, 6, 3),
    );
    await settle(c);
    final s = c.read(lifecycleProvider);
    expect(s.effective, SubscriptionStatus.grace);
    expect(s.canWrite, isTrue);
    expect(s.needsBanner, isTrue);
  });

  test('grace over and synced: read-only', () async {
    final c = make(
      bundleValue: bundle(),
      now: DateTime.utc(2027, 6, 20),
      lastSynced: DateTime.utc(2027, 6, 20),
    );
    await settle(c);
    expect(c.read(lifecycleProvider).access, AccessLevel.readOnly);
    expect(c.read(subscriptionReadOnlyProvider), isTrue);
  });

  test('offline past grace: held off, then read-only until a sync', () async {
    final held = make(
      bundleValue: bundle(),
      now: DateTime.utc(2027, 6, 12),
      lastSynced: DateTime.utc(2027, 5, 30),
    );
    await settle(held);
    expect(
      held.read(lifecycleProvider).reason,
      LifecycleReason.confirmWithServer,
    );
    expect(held.read(subscriptionReadOnlyProvider), isFalse);

    final stale = make(
      bundleValue: bundle(),
      now: DateTime.utc(2027, 6, 30),
      lastSynced: DateTime.utc(2027, 5, 30),
    );
    await settle(stale);
    expect(stale.read(lifecycleProvider).reason, LifecycleReason.syncRequired);
    expect(stale.read(subscriptionReadOnlyProvider), isTrue);
  });

  test(
    'a plan that has not synced yet grants everything, not nothing',
    () async {
      final c = make(bundleValue: bundle(withPlan: false));
      await settle(c);
      expect(c.read(entitlementsProvider).module('shop'), isTrue);
    },
  );

  test('a newer signed token beats the synced row', () async {
    // The local row (edited by hand?) says active until June; the server's
    // newer token says locked.
    final c = make(
      bundleValue: bundle(),
      token: claims(
        status: SubscriptionStatus.locked,
        issuedAt: DateTime.utc(2027, 5, 14),
      ),
    );
    await settle(c);
    expect(c.read(lifecycleProvider).access, AccessLevel.readOnly);
  });

  test('an older token never overrides a newer synced row', () async {
    final c = make(
      bundleValue: bundle(updatedAt: '2027-05-14T00:00:00.000Z'),
      token: claims(
        status: SubscriptionStatus.locked,
        issuedAt: DateTime.utc(2027, 5),
      ),
    );
    await settle(c);
    expect(c.read(lifecycleProvider).access, AccessLevel.full);
  });

  test("token entitlements replace the row's when the token wins", () async {
    final c = make(
      bundleValue: bundle(),
      token: claims(
        status: SubscriptionStatus.active,
        entitlements: const Entitlements(modules: {'khata': true}),
      ),
    );
    await settle(c);
    expect(c.read(entitlementsProvider).module('karza'), isFalse);
  });

  group('Membership in read-only mode', () {
    const owner = Membership(
      tenantId: 't1',
      tenantName: 'T',
      role: MemberRole.owner,
    );

    test('writes are refused, looking is not', () {
      final ro = owner.withReadOnly(readOnly: true);
      expect(ro.can(Permission.partiesManage), isFalse);
      expect(ro.can(Permission.paymentsCreate), isFalse);
      expect(ro.can(Permission.adminManage), isFalse);
      expect(ro.can(Permission.financeView), isTrue);
      expect(ro.can(Permission.auditView), isTrue);
      expect(ro.can(Permission.shopViewProfit), isTrue);
    });

    test('the role is still honoured for billing and export', () {
      final ro = owner.withReadOnly(readOnly: true);
      expect(ro.canIgnoringLock(Permission.adminManage), isTrue);
      final munshi = const Membership(
        tenantId: 't1',
        tenantName: 'T',
        role: MemberRole.munshi,
      ).withReadOnly(readOnly: true);
      expect(munshi.canIgnoringLock(Permission.adminManage), isFalse);
    });

    test('writable again after renewal', () {
      final ro = owner.withReadOnly(readOnly: true);
      expect(
        ro.withReadOnly(readOnly: false).can(Permission.partiesManage),
        isTrue,
      );
      expect(owner.withReadOnly(readOnly: false), same(owner));
      expect(ro == owner, isFalse);
    });
  });
}
