import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:khata_core/khata_core.dart';
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/db/powersync_schema.dart';
import 'package:mandi_khata_app/core/subscription/subscription_repository.dart';
import 'package:powersync/powersync.dart';

const t1 = '11111111-1111-4111-8111-111111111111';
const t2 = '22222222-2222-4222-8222-222222222222';
const ctx = WriteContext(
  tenantId: t1,
  userId: 'user-a',
  deviceId: 'device-w1',
  deviceCode: 'W1',
);

void main() {
  late Directory dir;
  late PowerSyncDatabase db;
  late SubscriptionRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mk_sub_test');
    db = PowerSyncDatabase(schema: powerSyncSchema, path: '${dir.path}/t.db');
    await db.initialize();
    repo = SubscriptionRepository(db);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  Future<void> seedPlans() async {
    await db.execute(
      'INSERT INTO plans (id, code, name, price_monthly_paise, max_users, '
      'max_devices, modules, limits, is_public, is_active, sort_order) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, 1, ?)',
      [
        'p1',
        'mandi_basic',
        'Mandi Basic',
        99900,
        2,
        2,
        '{"khata":true,"arrivals":true}',
        '{"parties":2000}',
        10,
      ],
    );
    await db.execute(
      'INSERT INTO plan_addons (id, code, name, grants_limits, is_active) '
      "VALUES ('a1', 'extra_user', 'Extra user', '{\"users\":1}', 1)",
    );
  }

  Future<void> seedSubscription(String tenant, {String status = 'active'}) =>
      db.execute(
        'INSERT INTO tenant_subscriptions (id, tenant_id, plan_code, status, '
        'current_period_end, grace_days, addons, overrides, billing_cycle) '
        "VALUES (?, ?, 'mandi_basic', ?, '2027-06-01T00:00:00.000Z', 7, "
        "'[{\"code\":\"extra_user\",\"qty\":2}]', '{}', 'monthly')",
        ['s-$tenant', tenant, status],
      );

  test('loadBundle joins the subscription with plans and add-ons', () async {
    await seedPlans();
    await seedSubscription(t1);
    final bundle = await repo.loadBundle(t1);
    expect(bundle, isNotNull);
    expect(bundle!.plan!.name, 'Mandi Basic');
    expect(bundle.entitlements.limit('users'), 4);
    expect(bundle.entitlements.module('arrivals'), isTrue);
    expect(bundle.entitlements.module('shop'), isFalse);
    expect(bundle.subscription.terms.status, SubscriptionStatus.active);
  });

  test('another business has no subscription of its own to read', () async {
    await seedPlans();
    await seedSubscription(t1);
    expect(await repo.loadBundle(t2), isNull);
  });

  test('watchBundle updates when the subscription changes', () async {
    await seedPlans();
    await seedSubscription(t1);
    final seen = <SubscriptionStatus?>[];
    final sub = repo
        .watchBundle(t1)
        .listen((b) => seen.add(b?.subscription.terms.status));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await db.execute(
      "UPDATE tenant_subscriptions SET status = 'locked' WHERE tenant_id = ?",
      [t1],
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await sub.cancel();
    expect(seen.first, SubscriptionStatus.active);
    expect(seen.last, SubscriptionStatus.locked);
  });

  test(
    'usage counts only this business, active members, live devices',
    () async {
      await db.execute(
        'INSERT INTO tenant_members (id, tenant_id, user_id, role, is_active) '
        "VALUES ('m1', ?1, 'u1', 'owner', 1), ('m2', ?1, 'u2', 'munshi', 0), "
        "('m3', ?2, 'u3', 'owner', 1)",
        [t1, t2],
      );
      await db.execute(
        'INSERT INTO devices (id, tenant_id, user_id, device_code, platform, '
        "revoked_at) VALUES ('d1', ?1, 'u1', 'W1', 'windows', NULL), "
        "('d2', ?1, 'u1', 'A1', 'android', '2027-01-01T00:00:00Z')",
        [t1],
      );
      await db.execute(
        'INSERT INTO parties (id, tenant_id, code, name, deleted_at) VALUES '
        "('p1', ?1, 'P1', 'A', NULL), ('p2', ?1, 'P2', 'B', '2027-01-01'), "
        "('p3', ?2, 'P3', 'C', NULL)",
        [t1, t2],
      );
      final usage = await repo.watchUsage(t1).first;
      expect(usage.users, 1);
      expect(usage.devices, 1);
      expect(usage.parties, 1);
      expect(usage.of('users'), 1);
      expect(usage.of('unknown'), 0);
    },
  );

  test('requestPlan writes the request and its audit row together', () async {
    final id = await repo.requestPlan(
      ctx,
      planCode: 'combo',
      billingCycle: 'yearly',
      addons: [(code: 'extra_user', qty: 2)],
      note: '  please call  ',
      now: DateTime.utc(2027, 5),
    );
    final row = await db.get('SELECT * FROM plan_requests WHERE id = ?', [id]);
    expect(row['tenant_id'], t1);
    expect(row['requested_plan_code'], 'combo');
    expect(row['billing_cycle'], 'yearly');
    expect(row['status'], 'pending');
    expect(row['note'], 'please call');
    expect(jsonDecode(row['addons']! as String), [
      {'code': 'extra_user', 'qty': 2},
    ]);
    final audit = await db.getAll(
      "SELECT * FROM audit_log WHERE table_name = 'plan_requests'",
    );
    expect(audit.single['row_id'], id);
    expect(audit.single['action'], 'insert');
    // Queued for upload as one local transaction.
    final crud = await db.getAll('SELECT data FROM ps_crud');
    expect(crud, hasLength(2));
  });

  test('requests of this business are listed newest first', () async {
    await repo.requestPlan(ctx, planCode: 'a', now: DateTime.utc(2027, 5));
    await repo.requestPlan(ctx, planCode: 'b', now: DateTime.utc(2027, 6));
    await db.execute(
      'INSERT INTO plan_requests (id, tenant_id, status, created_at) '
      "VALUES ('x', ?, 'pending', '2027-07-01')",
      [t2],
    );
    final rows = await repo.watchRequests(t1).first;
    expect(rows.map((r) => r.planCode), ['b', 'a']);
    expect(rows.every((r) => r.pending), isTrue);
  });

  test('platform settings: int value or fallback', () async {
    expect(await repo.watchIntSetting('offline_tolerance_days', 7).first, 7);
    await db.execute(
      'INSERT INTO platform_settings (id, key, value, is_public) '
      "VALUES ('k1', 'offline_tolerance_days', '3', 1)",
    );
    expect(await repo.watchIntSetting('offline_tolerance_days', 7).first, 3);
  });

  test('announcements: translated, timed and per plan', () async {
    await db.execute(
      'INSERT INTO announcements (id, title_en, title_hi, body_en, severity, '
      'plan_codes, starts_at, ends_at, is_active) VALUES '
      "('n1', 'Hello', 'नमस्ते', 'Body', 'warning', '[\"combo\"]', "
      "'2027-05-01T00:00:00Z', '2027-05-31T00:00:00Z', 1)",
    );
    final a = (await repo.watchAnnouncements().first).single;
    expect(a.title('hi'), 'नमस्ते');
    expect(a.title('pa'), 'Hello'); // falls back to English
    expect(a.body('hi'), 'Body');
    expect(a.severity, 'warning');
    expect(a.visible(DateTime.utc(2027, 5, 10), 'combo'), isTrue);
    expect(a.visible(DateTime.utc(2027, 5, 10), 'shop'), isFalse);
    expect(a.visible(DateTime.utc(2027, 4, 30), 'combo'), isFalse);
    expect(a.visible(DateTime.utc(2027, 6), 'combo'), isFalse);
  });

  test('support sessions of the business are listed', () async {
    await db.execute(
      'INSERT INTO support_sessions (id, tenant_id, admin_user_id, '
      'admin_label, reason, started_at) VALUES '
      "('s1', ?1, 'a', 'Support', 'Fix report', '2027-05-01T00:00:00Z'), "
      "('s2', ?2, 'a', 'Support', 'Other', '2027-05-01T00:00:00Z')",
      [t1, t2],
    );
    final rows = await repo.watchSupportSessions(t1).first;
    expect(rows.single.reason, 'Fix report');
  });
}
