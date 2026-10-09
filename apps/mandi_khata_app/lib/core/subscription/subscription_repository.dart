import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;
import 'package:mandi_khata_app/core/audit/audit_writer.dart';
import 'package:mandi_khata_app/core/subscription/subscription_models.dart';
import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

/// How many of each counted thing the business has.
@immutable
class SubscriptionUsage {
  const SubscriptionUsage({
    required this.users,
    required this.devices,
    required this.parties,
  });

  final int users;
  final int devices;
  final int parties;

  int of(String limitKey) => switch (limitKey) {
    'users' => users,
    'devices' => devices,
    'parties' => parties,
    _ => 0,
  };

  @override
  bool operator ==(Object other) =>
      other is SubscriptionUsage &&
      other.users == users &&
      other.devices == devices &&
      other.parties == parties;

  @override
  int get hashCode => Object.hash(users, devices, parties);
}

/// A request for a plan change (manual billing until Razorpay).
@immutable
class PlanRequestRow {
  const PlanRequestRow({
    required this.id,
    required this.status,
    required this.createdAt,
    this.planCode,
    this.note,
    this.handledNote,
  });

  final String id;
  final String status;
  final String? planCode;
  final String? note;
  final String? handledNote;
  final DateTime? createdAt;

  bool get pending => status == 'pending';
}

/// Support staff looked at this business (read-only), shown to the owner.
@immutable
class SupportSessionRow {
  const SupportSessionRow({
    required this.id,
    required this.who,
    required this.reason,
    required this.startedAt,
  });

  final String id;
  final String who;
  final String reason;
  final DateTime? startedAt;
}

/// A message from the platform.
@immutable
class AnnouncementRow {
  const AnnouncementRow({
    required this.id,
    required this.severity,
    required this.titles,
    required this.bodies,
    this.planCodes,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String severity;
  final Map<String, String> titles;
  final Map<String, String> bodies;
  final List<String>? planCodes;
  final DateTime? startsAt;
  final DateTime? endsAt;

  String title(String lang) => _pick(titles, lang) ?? titles['en'] ?? '';
  String body(String lang) => _pick(bodies, lang) ?? bodies['en'] ?? '';

  static String? _pick(Map<String, String> m, String lang) {
    final v = m[lang];
    return v == null || v.trim().isEmpty ? null : v;
  }

  /// Shown at [now] to a business on [plan].
  bool visible(DateTime now, String? plan) {
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && now.isAfter(endsAt!)) return false;
    final codes = planCodes;
    if (codes != null && codes.isNotEmpty && !codes.contains(plan)) {
      return false;
    }
    return true;
  }
}

DateTime? _time(Object? v) =>
    v is String && v.isNotEmpty ? DateTime.tryParse(v)?.toUtc() : null;

/// Plans, subscription and everything around billing, from the local
/// (synced) database. Offline-first like the rest of the app.
class SubscriptionRepository {
  SubscriptionRepository(this._db);

  final PowerSyncDatabase _db;

  static const _bundleTables = {'tenant_subscriptions', 'plans', 'plan_addons'};

  Future<SubscriptionBundle?> loadBundle(String tenantId) async {
    final sub = await _db.getOptional(
      'SELECT * FROM tenant_subscriptions WHERE tenant_id = ?',
      [tenantId],
    );
    if (sub == null) return null;
    final plans = await _db.getAll('SELECT * FROM plans');
    final addons = await _db.getAll('SELECT * FROM plan_addons');
    return SubscriptionBundle(
      subscription: SubscriptionInfo.fromRow(sub),
      plans: [for (final r in plans) PlanInfo.fromRow(r)]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      addonCatalog: [for (final r in addons) AddonInfo.fromRow(r)]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
    );
  }

  Stream<SubscriptionBundle?> watchBundle(String tenantId) =>
      _db.onChange(_bundleTables).asyncMap((_) => loadBundle(tenantId));

  /// Users, devices and parties in use (filtered by [tenantId]).
  Stream<SubscriptionUsage> watchUsage(String tenantId) => _db
      .onChange(const {'tenant_members', 'devices', 'parties'})
      .asyncMap((_) async {
        final row = await _db.get(
          'SELECT (SELECT count(*) FROM tenant_members '
          'WHERE tenant_id = ?1 AND is_active = 1) AS u, '
          '(SELECT count(*) FROM devices '
          'WHERE tenant_id = ?1 AND revoked_at IS NULL) AS d, '
          '(SELECT count(*) FROM parties '
          'WHERE tenant_id = ?1 AND deleted_at IS NULL) AS p',
          [tenantId],
        );
        return SubscriptionUsage(
          users: row['u']! as int,
          devices: row['d']! as int,
          parties: row['p']! as int,
        );
      });

  /// A public platform setting as an int (JSON number), or [fallback].
  Stream<int> watchIntSetting(String key, int fallback) => _db
      .watch(
        'SELECT value FROM platform_settings WHERE key = ?',
        parameters: [key],
        triggerOnTables: const {'platform_settings'},
      )
      .map((rows) {
        if (rows.isEmpty) return fallback;
        final v = rows.first['value'];
        return v is String ? int.tryParse(v) ?? fallback : fallback;
      });

  Stream<List<PlanRequestRow>> watchRequests(String tenantId) => _db
      .watch(
        'SELECT * FROM plan_requests WHERE tenant_id = ? '
        'ORDER BY created_at DESC',
        parameters: [tenantId],
        triggerOnTables: const {'plan_requests'},
      )
      .map(
        (rows) => [
          for (final r in rows)
            PlanRequestRow(
              id: r['id']! as String,
              status: (r['status'] as String?) ?? 'pending',
              planCode: r['requested_plan_code'] as String?,
              note: r['note'] as String?,
              handledNote: r['handled_note'] as String?,
              createdAt: _time(r['created_at']),
            ),
        ],
      );

  Stream<List<SupportSessionRow>> watchSupportSessions(String tenantId) => _db
      .watch(
        'SELECT * FROM support_sessions WHERE tenant_id = ? '
        'ORDER BY started_at DESC LIMIT 20',
        parameters: [tenantId],
        triggerOnTables: const {'support_sessions'},
      )
      .map(
        (rows) => [
          for (final r in rows)
            SupportSessionRow(
              id: r['id']! as String,
              who: (r['admin_label'] as String?) ?? '',
              reason: (r['reason'] as String?) ?? '',
              startedAt: _time(r['started_at']),
            ),
        ],
      );

  Stream<List<AnnouncementRow>> watchAnnouncements() => _db
      .watch(
        'SELECT * FROM announcements WHERE is_active = 1 '
        'ORDER BY created_at DESC',
        triggerOnTables: const {'announcements'},
      )
      .map(
        (rows) => [
          for (final r in rows)
            AnnouncementRow(
              id: r['id']! as String,
              severity: (r['severity'] as String?) ?? 'info',
              titles: {
                'en': (r['title_en'] as String?) ?? '',
                'hi': (r['title_hi'] as String?) ?? '',
                'pa': (r['title_pa'] as String?) ?? '',
              },
              bodies: {
                'en': (r['body_en'] as String?) ?? '',
                'hi': (r['body_hi'] as String?) ?? '',
                'pa': (r['body_pa'] as String?) ?? '',
              },
              planCodes: _planCodes(r['plan_codes']),
              startsAt: _time(r['starts_at']),
              endsAt: _time(r['ends_at']),
            ),
        ],
      );

  static List<String>? _planCodes(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    try {
      final v = jsonDecode(raw);
      if (v is List) return [for (final e in v) e.toString()];
    } on FormatException {
      // Postgres array literal: {a,b}
      final inner = raw.replaceAll(RegExp('[{}"]'), '');
      if (inner.isEmpty) return null;
      return inner.split(',');
    }
    return null;
  }

  /// Asks the platform for a plan (or add-on) change. Allowed even when the
  /// business is locked, so an owner can always ask to come back; the server
  /// exempts `plan_requests` from the lock.
  Future<String> requestPlan(
    WriteContext ctx, {
    String? planCode,
    String? billingCycle,
    List<({String code, int qty})> addons = const [],
    String? note,
    DateTime? now,
  }) async {
    final when = now ?? DateTime.now();
    final at = when.toUtc().toIso8601String();
    final id = const Uuid().v4();
    final addonJson = jsonEncode([
      for (final a in addons) {'code': a.code, 'qty': a.qty},
    ]);
    final trimmed = note?.trim();
    await _db.writeTransaction((tx) async {
      await tx.execute(
        'INSERT INTO plan_requests (id, tenant_id, requested_plan_code, '
        'billing_cycle, addons, note, status, created_by, created_at, '
        'updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          id,
          ctx.tenantId,
          planCode,
          billingCycle,
          addonJson,
          if (trimmed == null || trimmed.isEmpty) null else trimmed,
          'pending',
          ctx.userId,
          at,
          at,
        ],
      );
      await AuditWriter.record(
        tx,
        ctx,
        table: 'plan_requests',
        rowId: id,
        action: AuditAction.insert,
        after: {
          'requested_plan_code': planCode,
          'billing_cycle': billingCycle,
          'addons': addons.map((a) => {'code': a.code, 'qty': a.qty}).toList(),
        },
        at: when,
      );
    });
    return id;
  }
}
